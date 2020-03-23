
local Decorator = require 'decorator'
local InvincibleHandler = class('InvincibleHandler', Decorator)

function InvincibleHandler:__construct(instance)
    self.invincible = 0
    instance.handlers.invincible = self
    
    instance.chains.beHit:addHandler(
        function(e) 
            self.invincible = 
                self.invincible > 0 and self.invincible or 2 
            end
            
        end)

    instance.chains.defence:addHandler(
        function(e) 
            if self.invincible > 0 then
                event.propagate = false
            end
             
        end)
    
    instance.emitter:on("reset", 
        function() 
            if self.invincible > 0 then
                self.invincible = self.invincible - 1
            end
        end)
end

return InvincibleAfterHit