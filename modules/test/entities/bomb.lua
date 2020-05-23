local retouch = require('@retouchers.utils').retouch
local Explode = require '.handlers.explode'
local Die = require '.actions.die'
local IncState = require '.actions.incstate'

-- Bombs create explosions
local Bomb = class("Bomb", Entity)

-- select layer
Bomb.layer = Layers.misc

-- select base stats
Bomb.baseModifiers = {
    attack = {
        damage = 1,
        pierce = 1,
        source = 'explosion',
        power  = 1
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
Bomb.sequenceSteps = {    
    { -- first step: increment state
        action = IncState,
        repet = 2
    },    
    {
        action = Die
    }
}


-- apply decorators
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
local function setBase(event)
    event.expl =        event.actor:getStat(StatTypes.Explosion)
    event.expl.attack = event.actor:getStat(StatTypes.Attack)
    event.expl.push =   event.actor:getStat(StatTypes.Push)
end

Retouchers.Algos.simple(Bomb)
retouch(Bomb, 'die', { setBase, Ranks.HIGH })
retouch(Bomb, 'die', Explode.dynamic)


return Bomb