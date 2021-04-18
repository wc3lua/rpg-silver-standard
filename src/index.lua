require 'modules.other-functions.index'
require 'modules.native-types.index'
require 'modules.lua-lib.index'

local h = Handle.get(GetEnumUnit())

print(getType(h))

print(h.handle)

print(Handle.getId(h))