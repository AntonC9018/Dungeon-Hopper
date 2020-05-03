local Ranks = require 'lib.chains.ranks'
local utils = require 'logic.tinkers.utils'

local move = {}

local function moveNotFirstPiece(event)
    if event.targets[1].index ~= 1 then
        event.actor:executeMove(event.action)
    end
end

local function unconditionalMove(event)
    event.actor:executeMove(event.action)
end

move.afterAttack = {
    'attack', { unconditionalMove, Ranks.LOW }
}

move.afterAttackIfNotFirstPiece = {
    'attack', { moveNotFirstPiece, Ranks.LOW }
}


return utils