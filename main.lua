local initGlobals = InitGlobals
function InitGlobals()
    initGlobals()

    function newThread(func)
        local co = coroutine.create(func)
        local result, err = coroutine.resume(co)
        if not result then
            print(err)
        end
        return result
    end
    
    function EndTimer(timer)
        PauseTimer(timer)
        DestroyTimer(timer)
    end
    
    function wait(time)
        local timer = CreateTimer()
        local co = coroutine.running()
    
        TimerStart(timer, time, false, function()
            coroutine.resume(co)
        end)
    
        coroutine.yield()
    
        EndTimer(timer)
    end
    
    function getHandledCallback(callback)
        return function()
            local result, err = pcall(callback)
            if not result then
                print(err)
            end
            return result
        end
    end
    
    function getHandledThread(callback)
        return function()
            return newThread(getHandledCallback(callback))
        end
    end
    
    local _TimerStart = TimerStart
    TimerStart = function(whichTimer, timeout, periodic, handlerFunc)
        _TimerStart(whichTimer, timeout, periodic, getHandledThread(handlerFunc))
    end

    function setTimeout(time, func, noDestroy)
        return TimerStart(CreateTimer(), time, false, function()
            func()
            if  not noDestroy then
                EndTimer(GetExpiredTimer())
            end
        end)
    end

    function setInterval(time, func)
        return TimerStart(CreateTimer(), time, true, func)
    end
    
    local _TriggerAddAction = TriggerAddAction
    TriggerAddAction = function(whichTrigger, actionFunc)
        return _TriggerAddAction(whichTrigger, getHandledThread(actionFunc))
    end
    
    local _Condition = Condition
    Condition = function(func)
        return _Condition(getHandledThread(func))
    end
    
    local _Filter = Filter
    Filter = function(func)
        return _Condition(getHandledThread(func))
    end
    
    local _ForForce = ForForce
    ForForce = function(whichForce, callback)
        _ForForce(whichForce, getHandledThread(callback))
    end
    
    local _ForGroup = ForGroup
    ForGroup = function(whichGroup, callback)
        _ForGroup(whichGroup, getHandledThread(callback))
    end
    
    local function getFilter(filterFunc)
        local filter
        if  typeof(filterFunc, 'function') then
            filter = Filter(filterFunc)
        else
            filter = filterFunc
        end
        return filter
    end
    
    local _EnumDestructablesInRect = EnumDestructablesInRect
    EnumDestructablesInRect = function(r, filterFunc, actionFunc)
        _EnumDestructablesInRect(r, getFilter(filterFunc), getHandledThread(actionFunc))
    end
    
    local _EnumItemsInRect = EnumItemsInRect
    EnumItemsInRect = function(r, filterFunc, actionFunc)
        _EnumItemsInRect(r, getFilter(filterFunc), getHandledThread(actionFunc))
    end

    setTimeout(0., function()
        require 'modules.wts-parser.index'
        require 'modules.hot-reload.index'
        require(HOT_RELOAD_START_MODULE)
        compiletime(function()
            local args = ceres.getScriptArgs()
            local script_name = 'watch-wc3-script-for-changes.lua'
            local targetMapPath = ceres.layout.targetDirectory .. args[2] .. '.' .. args[4]
            local command = 'lua ' .. script_name .. ' ' .. ceres.layout.targetDirectory .. ' ' .. args[2] .. ' ' .. args[4] .. ' "' .. ceres.runConfig.mapDataDir .. MAP_NAME .. HOT_RELOAD_POSTFIX .. '"'
            if  arg.value('--flag') == 'hot-reload' then
                ceres.runMap(targetMapPath)
                os.execute(command)
            end
        end)
    end)
end