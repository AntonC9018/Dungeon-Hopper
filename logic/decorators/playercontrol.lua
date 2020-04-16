-- this file will include means of transforming 
-- a provided piece of input into action objects
--

local Decorator = require 'logic.decorators.decorator'
local AttackMoveAction = require 'logic.action.actions.attackmove'

local PlayerControl = class('PlayerControl', Decorator)

function PlayerControl:activate(player, direction)
    local base = player.baseModifiers
    -- for now, create the current action as a AttackMove action
    local action = AttackMoveAction(
        {
            direction = direction, 
            attack = base.attack,
            move = base.move
        }
    )

    player.nextAction = action
    player.isActionSet = true
end

return PlayerControl