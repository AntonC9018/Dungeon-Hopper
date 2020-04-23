-- this file will include means of transforming 
-- a provided piece of input into action objects
--

local Decorator = require 'logic.decorators.decorator'
local None = require 'logic.action.actions.none'
local AttackDigMove = require 'logic.action.actions.attackdigmove'

local PlayerControl = class('PlayerControl', Decorator)

function PlayerControl:activate(player, direction)

    local action

    if direction.x == 0 and direction.y == 0 then
        action = None()
    else
        action = AttackDigMove()
        action:setDirection(direction)
    end

    player.nextAction = action
end

return PlayerControl