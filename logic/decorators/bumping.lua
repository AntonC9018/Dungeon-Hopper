-- TODO: This decorator has basically no purpose and should be transfromed into a function
local Decorator = require 'logic.decorators.decorator'
local utils = require 'logic.decorators.utils'
local Changes = require "render.changes"
local Move = require("logic.action.handlers.basic").Move
local Ranks = require 'lib.chains.ranks'
local Numbers = require 'lib.chains.numbers'

local Bumping = class('Bumping', Decorator)

local function bump(event)
    local pos, newPos = event.actor.pos, event.newPos
    if 
        newPos.x == pos.x
        and newPos.y == pos.y
    then
        event.actor.world:registerChange(event.actor, Changes.Bump)
    end
end

Bumping.affectedChains = {
    { "displace", 
        { 
            -- TODO: probably define priority numbers for all handlers
            -- that are defined by the standart decorators and put them
            -- in a separate file 
            { bump, Numbers.rankMap[Ranks.MEDIUM] - 20 }
        } 
    }
}

return Bumping