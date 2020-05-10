local Entity = require 'logic.base.entity'
local Trap = require 'modules.test.base.trap'
local Bouncing = require 'modules.test.decorators.bouncing'
local TrapRetouchers = require 'modules.test.retouchers.trap'
local Entity = require 'logic.base.entity'
local decorate = require 'logic.decorators.decorate'
local utils = require 'modules.test.base.utils'

-- Class definition
local BounceTrap = class("BounceTrap", Trap)

-- Set up chains
Entity.copyChains(Trap, BounceTrap)
decorate(BounceTrap, Bouncing)    
TrapRetouchers.bePushedOnBounce(BounceTrap)
TrapRetouchers.tickUnpress(BounceTrap)

utils.redirectActionToDecorator(BounceTrap, 'Bouncing')

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