require 'modules.native-types.index'
require 'modules.other-functions.index'
require 'modules.lua-lib.index'

local u = CreateUnit(Player(0), FourCC('hpea'), 0, 0, 0)
-- local u = GetEnumUnit()


Unit = {
	getEnum = function()
		return handleHandle('НУЛЕВОЙ ХЕНДЛ ВЫБРАННОГО ЮНИТА', GetEnumUnit())
	end,
	triggered = function()
		return handleHandle('НУЛЕВОЙ ХЕНДЛ ТРИГГЕРНОГО ЮНИТА', GetTriggerUnit())
	end,
	getName = function(whichUnit)
		handleHandle('НУЛЕВОЙ ХЕНДЛ ЮНИТА ПРИ ПОЛУЧЕНИИ ЕГО ИМЕНИ', whichUnit)
		return GetUnitName(whichUnit)
	end
}

local trig = CreateTrigger()
TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_ATTACKED)
TriggerAddAction(trig, function()
	print(Unit.getName(Unit.getEnum()))
end)