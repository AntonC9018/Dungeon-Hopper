-- Status effect
--
--
-- Abstraction for e.g. freezing, poison etc.
--
-- These are at the basic level just wrapped tinkers 
--
-- Methods:
--      1. apply(entity, amount). Called when an entity gets the status effect
--         that is, his current amount of it becomes the new amount having been 
--         0 previously 
--      
--      2. reapply(entity, amount). Called when an entities' amount of the 
--         status effect is set to amount having not been 0 previously.
--      
--      3. wearOff(entity). Called when the amount becomes 0 (at tick event)
--
--      4. free(entity). Called right before the entity does an action the
--         next turn after the effect wore off.
--
--
-- Status effects are stateless, but they may use StoreTinkers for state.
local Status = class('Status')

-- when you instantiate a Status object, you're passing it the tinkers array
-- (by default), though subclasses may be created that may override this
function Status:__construct(tinker)
    self.tinker = tinker
end

function Status:apply(entity, amount)
    self.tinker:tink(entity)
end

-- don't do anything
function Status:reapply(entity, amount)
end

function Status:wearOff(entity)
    self.tinker:untink(entity)
end

-- don't do anything
function Status:free(entity)
end

-- default amount = 2
Status.amount = 2
-- default overlay method: reset
local Overlay = require 'logic.status.overlay'
Status.overlay = Overlay.RESET 


return Status