
local Target = require "target"
local General = require "general"

-- TODO: inherit from item
local Weapon = class("Weapon")

-- A weapon must have a pattern
-- for the sake of argument, a fallback pattern is presented here
local Pattern = require("pattern")
Weapon.pattern = Pattern()
Weapon.pattern:add( Vec(1, 0), Vec(1, 0), false )

Weapon.check = General.check
Weapon.chain = General.chain
Weapon.hitAll = false

function Weapon:posFromAction(actor, action)

    local actor = action.entity

    local map = {}

    local ihat = actor.orientation
    local jhat = ihat:rotate(-math.pi / 2)

    local world = actor.world

    
    -- for first, add things to the map.
    for i = 1, #self.pattern do
        local piece = self.pattern:get(i):transform(ihat, jhat)
        local coord = actor.pos + piece.pos
        local thing = world:getOneFromTopAt(coord)
        table.insert(map, Target(thing, piece, i))
    end
    
    -- after that, analyze it
    local event = Event(actor, action)
    event.targets = map

    self.chain:pass(event, self.check)

    return event.targets
end

return Weapon