local State = require '.enums.pressed'

-- Class definition
local Trap = class('Trap', Entity)

Trap.layer = Layers.trap
Trap.state = State.UNPRESSED

Decorators.Start(Trap)
decorate(Trap, Decorators.WithHP)
decorate(Trap, Decorators.Ticking)
decorate(Trap, Decorators.Attackable)
decorate(Trap, Decorators.Acting)
decorate(Trap, Decorators.DynamicStats)
-- use the player algo
Retouchers.Algos.simple(Trap)
Retouchers.Attackableness.no(Trap)

return Trap