-- this file will include means of transforming 
-- a provided piece of input into action objects
--
local Decorator = require '@decorators.decorator'
local None = require '@action.actions.none'
local BasicHandlers = require "@action.handlers.basic"
local Action = require "@action.action"
local AttackDigMove = require '@action.actions.attackdigmove'
local handlerUtils = require '@action.handlers.utils' 

local PlayerControl = class('PlayerControl', Decorator)

local PlayerAction = Action.fromHandlers(
    'PlayerAction',
    {
        BasicHandlers.Attack,
        BasicHandlers.Dig,
        handlerUtils.activateDecorator('Interacting'),
        BasicHandlers.Move
    }
)

function PlayerControl:activate(player, direction)

    local action

    if direction.x == 0 and direction.y == 0 then
        action = None()
    else
        action = PlayerAction()
        action:setDirection(direction)
    end

    player.nextAction = action
end

return PlayerControl