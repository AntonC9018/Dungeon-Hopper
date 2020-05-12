local Tile = require 'modules.test.base.tile'
local decorate = require('logic.decorators.decorate')
local Decorators = require 'logic.decorators.decorators'
local Action = require 'logic.action.action'
local handlerUtils = require 'logic.action.handlers.utils' 
local utils = require 'modules.test.base.utils'

local Coals = class("Coals", Tile)

Decorators.Start(Coals)
decorate(Coals, Decorators.Acting)
decorate(Coals, Decorators.Attacking)
decorate(Coals, Decorators.Ticking)

Decorators.Attackable.registerAttackSource('Coals')

utils.redirectActionToHandler(Coals, 'executeBurn')

-- TODO: refactor into a decorator
function Coals:executeBurn(action)
    local real = self.world.grid:getRealAt(self.pos)
    if self.savedTarget == real then
        return self.executeAttack(action, { real })
    else
        self.savedTarget = real
    end
    return { success = true }
end

local Algos = require 'logic.retouchers.algos'
Algos.simple(Coals)

Coals.baseModifiers = {
    attack = {
        damage = 2,
        pierce = 5,
        source = 'coals' -- Decorators.Attackable.AttackSourceTypes.Coals
    }
}

return Coals