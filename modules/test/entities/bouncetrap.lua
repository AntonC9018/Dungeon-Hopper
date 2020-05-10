local Entity = require 'logic.base.entity'
local Action = require 'logic.action.action'
local handlerUtils = require 'logic.action.handlers.utils' 
local Trap = require 'modules.test.base.trap'
local Bouncing = require 'modules.test.decorators.bouncing'
local TrapRetouchers = require 'modules.test.retouchers.trap'
local Entity = require 'logic.base.entity'
local decorate = require 'logic.decorators.decorate'

-- Class definition
local BounceTrap = class("BounceTrap", Trap)

-- Set up chains
Entity.copyChains(Trap, BounceTrap)
decorate(BounceTrap, Bouncing)    
TrapRetouchers.bePushedOnBounce(BounceTrap)
TrapRetouchers.tickUnpress(BounceTrap)

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