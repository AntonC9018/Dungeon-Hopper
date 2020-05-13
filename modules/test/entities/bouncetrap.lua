local Trap = require '.base.trap'
local Bouncing = require '.decorators.bouncing'
local TrapRetouchers = require '.retouchers.trap'
local utils = require '.base.utils'

-- Class definition
local BounceTrap = class("BounceTrap", Trap)

-- Set up chains
copyChains(Trap, BounceTrap)

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