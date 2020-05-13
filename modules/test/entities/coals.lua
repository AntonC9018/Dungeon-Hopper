local Tile = require '.base.tile'
local Action = require '@action.action'
local handlerUtils = require '@action.handlers.utils' 
local utils = require '.base.utils'

local Coals = class("Coals", Tile)

Decorators.Start(Coals)
decorate(Coals, Decorators.Acting)
decorate(Coals, Decorators.Attacking)
decorate(Coals, Decorators.Ticking)

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

Retouchers.Algos.simple(Coals)

Coals.baseModifiers = {
    attack = {
        damage = 2,
        pierce = 5,
        source = 'coals' -- Decorators.Attackable.AttackSourceTypes.Coals
    }
}

return Coals