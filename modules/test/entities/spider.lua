local Entity = require "@base.entity"
local Cell = require "world.cell"
local Binding = require '.decorators.binding'

local Spider = class("Spider", Entity)

Spider.layer = Layers.real

-- Set up all decorators
Decorators.Start(Spider)
decorate(Spider, Decorators.Acting)
decorate(Spider, Decorators.Sequential)
decorate(Spider, Decorators.Killable)
decorate(Spider, Decorators.Ticking)
decorate(Spider, Decorators.Attackable)
decorate(Spider, Decorators.Moving)
decorate(Spider, Decorators.Pushable)
decorate(Spider, Decorators.Statused)
decorate(Spider, Decorators.WithHP)
decorate(Spider, Decorators.Displaceable)
decorate(Spider, Decorators.DynamicStats)
decorate(Spider, Binding)
Retouchers.Algos.general(Spider)

-- Set up sequence
local Handlers = require '@action.handlers.basic'
local utils = require '@action.handlers.utils'
local Action = require '@action.action'
local None = require '@action.actions.none'

local BindAction = Action.fromHandlers(
    'BindAction',
    {
        utils.activateDecorator('Binding'),
        Handlers.Move
    }
)

local steps = {
    {
        action = BindAction,
        movs = require "@sequence.movs.diagonal",
        fail = 1,
        checkSuccess = function(event)
            event.success = event.actor.decorators.Binding:isActivated()
        end
    },
    {
        action = None,
        checkSuccess = function(event)
            event.success = event.actor.decorators.Binding:isActivated()
            event.index = 2
        end,
        fail = 1
    }
}

Spider.sequenceSteps = steps


-- Retouch
Retouchers.Skip.blockedMove(Spider)


Spider.baseModifiers = {

    resistance = {
        armor = 0,
        push = 0,
        pierce = 1,
        bind = 3
    },

    status = {
        bind = 2
    },

    hp = {
        amount = 3
    }
}

return Spider