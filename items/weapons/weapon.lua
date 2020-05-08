
local Target = require "items.weapons.target"
local Attackableness = require "logic.enums.attackableness"
local Item = require 'items.item'

-- Another available option: hitAll
local General = require "items.weapons.chains.general"

-- TODO: inherit from item
local Weapon = class("Weapon", Item)

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


function Weapon:getTargets(actor, action)

    local map = {}

    local ihat = action.direction
    local jhat = ihat:rotate(-math.pi / 2)

    local world = actor.world
    
    -- for first, add things to the map.
    for i = 1, #self.pattern.pieces do
        local piece = self.pattern:get(i):transform(ihat, jhat)
        local coord = actor.pos + piece.pos
        local entity = world.grid:getOneFromTopAt(coord)
        -- see logic.enums.attackableness
        local attackableness = 
            entity ~= nil
                and entity:getAttackableness(actor)
                or Attackableness.NO

        map[i] = Target(entity, piece, i, attackableness)
    end
    
    -- after that, analyze it
    local event = Event(actor, action)
    event.targets = map

    if self.check(event) then
        return event.targets
    end

    self.chain:pass(event, self.check)

    return event.targets
end

return Weapon