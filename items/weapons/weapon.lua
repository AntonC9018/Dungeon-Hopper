
local Target = require "items.weapons.target"
local General = require "items.weapons.general"
local Attackableness = require "logic.enums.attackableness"

-- TODO: inherit from item
local Weapon = class("Weapon")

-- A weapon must have a pattern
-- for the sake of argument, a fallback pattern is presented here
local Pattern = require("items.weapons.pattern")
Weapon.pattern = Pattern()
-- attack directly in front, 
-- apply push in the same direction,
-- do not care about the previous attacks 
-- (that is, attack even if some previous attacks were blocked by e.g. a wall)
Weapon.pattern:add( Vec(1, 0), Vec(1, 0), false )

Weapon.check = General.check
Weapon.chain = General.chain
Weapon.hitAll = false

function Weapon:posFromAction(actor, action)

    local actor = action.actor

    local map = {}

    local ihat = actor.orientation
    local jhat = ihat:rotate(-math.pi / 2)

    local world = actor.world

    
    -- for first, add things to the map.
    for i = 1, #self.pattern do
        local piece = self.pattern:get(i):transform(ihat, jhat)
        local coord = actor.pos + piece.pos
        local thing = world:getOneFromTopAt(coord)
        -- see logic.enums.attackableness
        local attackableness = thing:getAttackableness(actor)
        table.insert(map, Target(thing, piece, i, attackableness))
    end
    
    -- after that, analyze it
    local event = Event(actor, action)
    event.targets = map
    event.hitAll = self.hitAll

    self.chain:pass(event, self.check)

    return event.targets
end

return Weapon