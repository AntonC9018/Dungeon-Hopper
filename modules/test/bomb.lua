local Entity = require "logic.base.entity"
local Cell = require "world.cell"

-- Bombs create explosions
local Bomb = class("Bomb", Entity)

-- select layer
Bomb.layer = Cell.Layers.misc

-- select base stats
Bomb.baseModifiers = {
    attack = {
        damage = 1,
        pierce = 1
    },
    push = {
        power = 2,
        distance = 1
    },
    resistance = {
        minDamage = 0,
        armor = 2 
    },
    explosion = {
        radius = 1,
        power = 1
    },
    hp = {
        amount = 1
    }   
}


-- make a sequence, if you are coding an enemy
local Actions = require 'modules.test.actions.all'

Bomb.sequenceSteps = {    
    { -- first step: increment state
        action = Actions.IncState,
        repet = 2
    },    
    {
        action = Actions.Die
    }
}


-- apply decorators
local decorate = require ("logic.decorators.decorator").decorate
local Decorators = require "logic.decorators.decorators"

Decorators.Start(Bomb)
decorate(Bomb, Decorators.Acting)
decorate(Bomb, Decorators.Sequential)
-- decorate(Bomb, Decorators.Attackable)
decorate(Bomb, Decorators.Killable)
-- decorate(Bomb, Decorators.Pushable)
-- decorate(Bomb, Decorators.Displaceable)
decorate(Bomb, Decorators.DynamicStats)
-- decorate(Bomb, Decorators.WithHP)
decorate(Bomb, Decorators.Ticking)
-- ...


-- apply retouchers
local Algos = require 'logic.retouchers.algos'
local retouch = require('logic.retouchers.utils').retouch
local Explode = require 'modules.test.handlers.explode'
local DynamicStats = require 'logic.decorators.dynamicstats'
local StatTypes = DynamicStats.StatTypes
local Ranks = require 'lib.chains.ranks'

local function setBase(event)
    event.expl =        event.actor:getStat(StatTypes.Explosion)
    event.expl.attack = event.actor:getStat(StatTypes.Attack)
    event.expl.push =   event.actor:getStat(StatTypes.Push)

end

Algos.player(Bomb)
retouch(Bomb, 'die', { setBase, Ranks.HIGH })
retouch(Bomb, 'die', Explode.dynamic)


return Bomb