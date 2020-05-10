local Entity = require 'logic.base.entity'
local Action = require 'logic.action.action'
local handlerUtils = require 'logic.action.handlers.utils' 
local Trap = require 'modules.test.base.trap'
local Combos = require 'modules.test.decorators.combos'

-- Class definition
local BounceTrap = class("BounceTrap", Trap)
Combos.BounceTrap(BounceTrap)

-- define our custom action that calls the new decorator's activation
local BounceAction = Action.fromHandlers(
    'BounceAction',
    handlerUtils.activateDecorator('Bouncing')
)

-- override calculateAction. Return our custom action
function BounceTrap:calculateAction()
    local action = BounceAction()
    -- set the orientation right away since it won't change
    action.direction = self.orientation
    self.nextAction = action
end


BounceTrap.baseModifiers = {
    push = {
        power = 1,
        distance = 1,
        source = 'bounce'
    },
    hp = {
        amount = 1
    }
}


return BounceTrap