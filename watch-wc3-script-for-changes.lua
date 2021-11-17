local sprintf = string.format

local function writef(fmt, ...)
    io.write(sprintf(fmt, ...))
    io.flush()
end

local function writefln(fmt, ...)
    io.write(sprintf(fmt, ...))
    io.write("\n")
    io.flush()
end

local function errorf(exit_code, fmt, ...)
    io.write('error: ')
    writefln(fmt, ...)
    os.exit(exit_code)
end

local function file_exists(path)
    local f = io.open(path, 'r')
    if f == nil then
        return false
    end
    f:close()
    return true
end

local function read_entire_file_text(path)
    local f, err = io.open(path, 'r')
    if err ~= nil then
        return nil, err
    end
    local text = f:read('*a')
    f:close()
    return text, nil
end

local function write_entire_file(path, content)
    local f = io.open(path, 'w')
    if f == nil then return false end
    if nil == f:write(content) then
        f:close();
        return false
    end
    return nil ~= f:close()
end

local c_script_path
-- print('arg[0]:', arg[0])
-- print(2+#'watch-wc3-script-for-changes.lua')
do
    local s = arg[0]
    s = string.sub(s, 1, -(2+#'watch-wc3-script-for-changes.lua'))
    c_script_path = s
end

local lanes = require 'lanes'.configure()
require 'socket'
-- no sleep function in vanilla Lua
local function sleep_ms(milliseconds)
    -- assume 'sleep_ms' is located in the same directory as this script file
    -- print('path:', c_script_path)
    local s = sprintf('%s\\sleep_ms %d',
        c_script_path,
        milliseconds
    )
    -- lanes.gen('*', function()
    --     os.execute(s)
    --     print(s)
    -- end)()
    -- print(s)
end


local function reload_script(script_text, preload_file)
    local gsub = string.gsub

    local s = script_text
    s = gsub(s, '[\\]', '\\\\')
    s = gsub(s, '[\n]', '\\n')
    s = gsub(s, '["]', '\\"')

    local preload_file_text = sprintf([[
function PreloadFiles takes nothing returns nothing
    call BlzSetAbilityTooltip ('Agyv', "%s", 0)
endfunction
]]
    , s
    )

    if not write_entire_file(preload_file, preload_file_text) then
        return errorf(3, 'could not write to preload file: \'%s\'', preload_file)
    end
end

local function get_ceres_modules(map_script)
    local pat1 = '--[[ start of module '
    local pat2 = '--[[ end of module "src.index" ]]'
    local pos1 = string.find(map_script, pat1, 1, true)
    local pos2 = string.find(map_script, pat2, 1, true)
    return string.sub(map_script, pos1, pos2 + pat2:len() - 1), pos1, pos2
end

function string.cut(s,pattern)
    if pattern == nil then pattern = " " end
    local cutstring = {}
    local i1 = 0
    repeat
        local i2 = nil
        local i2 = string.find(s,pattern,i1+1)
        if i2 == nil then i2 = string.len(s)+1 end
        table.insert(cutstring,string.sub(s,i1+1,i2-1))
        i1 = i2
    until i2 == string.len(s)+1
    return cutstring
end

local function getScriptDir(source)
    if source == nil then
        source = debug.getinfo(1).source
    end
    local pwd1 = (io.popen("echo %cd%"):read("*l")):gsub("\\","/")
    local pwd2 = source:sub(2):gsub("\\","/")
    local pwd = ""
    if pwd2:sub(2,3) == ":/" then
        pwd = pwd2:sub(1,pwd2:find("[^/]*%.lua")-1)
    else
        local path1 = string.cut(pwd1:sub(4),"/")
        local path2 = string.cut(pwd2,"/")
        for i = 1,#path2-1 do
            if path2[i] == ".." then
                table.remove(path1)
            else
                table.insert(path1,path2[i])
            end
        end
        pwd = pwd1:sub(1,3)
        for i = 1,#path1 do
            pwd = pwd..path1[i].."/"
        end
    end
    return pwd
end
local dir = getScriptDir('')
dir = string.gsub(dir, '/', '\\')

local function getFiles(path)
    local files = {}
    for f in io.popen("dir \"" .. path .. "\" /s /b"):lines() do
        table.insert(files, f)
    end
    return files
end

local function main()
    if 4 ~= #arg then
        io.write([[
Usage:
    lua watch-wc3-script-for-changes.lua <script-file-name> <preload-file-name>

Example:
    lua watch-wc3-script-for-changes.lua my-script.lua "c:\users\<user-name>\documents\warcraft iii\custommapdata\my-preload-file-name.txt"
]])
        return os.exit(0)
    end

    local target_directory = arg[1]
    local map_name = arg[2]
    local save_mode = arg[3]
    local script_file = './' .. target_directory .. map_name .. '.' .. save_mode .. '/war3map.lua'
    local ceres_command = 'ceres build -- --map ' .. map_name .. ' --output ' .. save_mode
    local preload_file = arg[4]

    if not file_exists(script_file) then
        return errorf(1, 'file not found: \'%s\'', script_file)
    end

    writefln('watching for changes')
    writefln('    script_file: \'%s\'', script_file)
    writefln('    preload_file: \'%s\'', preload_file)
    writefln('')

    local old_text = '\0'
    local num_reloads = 0

    
    -- socket.sleep(1)
    local iter = 0
	local function reloadThread()
        local old_texts = {}
		while true do
            iter = iter + 1
            -- print('iter:', iter)
            local srcFiles = getFiles(dir .. 'src\\*.lua')
            local scripts = getFiles(dir .. 'modules\\*.lua')
            for _, value in ipairs(srcFiles) do
                table.insert(scripts, value)
            end
            local isChange = false
            for i = 1, #scripts do
                if  old_texts[i] == nil then
                    old_texts[i] ='\0'
                end
                local text, err = read_entire_file_text(scripts[i])
                --if err ~= nil or not pos1 or not pos2 then
                if err ~= nil then
                    print('error scripts')
                    return errorf(2, '%s', err)
                end
                if  text ~= old_texts[i] then
                    old_texts[i] = text
                    isChange = true
                end
            end
            if  isChange then
                os.execute(ceres_command)
                -- print('ok')

                local text, err = read_entire_file_text(script_file)
                local text, pos1, pos2 = get_ceres_modules(text)
                --if err ~= nil or not pos1 or not pos2 then
                if err ~= nil then
                    print('error final script')
                    return errorf(2, '%s', err)
                end
                reload_script(text, preload_file)

                num_reloads = num_reloads + 1
                writefln('reload %s, time %s, script-size: %s bytes',
                    num_reloads,
                    os.date('%H:%M:%S', os.time()),
                    #text
                )
            end
            socket.sleep(1)
    	end
	end
    reloadThread()
end
main()
