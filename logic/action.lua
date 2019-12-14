-- 
-- action.lua
--
-- This file contains the Action class, which is anything an object
-- plans to do or does that may change the game state.

local Action = class("Action")

Action.Types = 
{
    ATTACK = 1,
    MOVE = 2,
    DIG = 3,
    ATTACK_MOVE = 4,
    ATTACK_DIG = 5,
    ATTACK_DIG_MOVE = 6,
    NONE = 7,
    SPECIAL = 8
}


function Action:getPlayerChain()
    return self.chains.player
end

function Action:getNonPlayerChain()
    return self.chains.nonPlayer
end


-- Action.chain = {
--     player = Chain(),
--     nonPlayer = Chain()
-- }

return Action