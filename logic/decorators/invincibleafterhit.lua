
local Decorator = require 'logic.decorators.decorator'
local InvincibleAfterHit = class('InvincibleHandler', Decorator)

function InvincibleAfterHit:__construct(instance)
    self.invincible = 0

    -- print(ins(instance.chains, { depth = 1))

    instance.chains.beHit:addHandler(
        function(e) 
            self.invincible = 
                self.invincible > 0 and self.invincible or 2 
            
        end)

    instance.chains.defence:addHandler(
        function(e) 
            if self.invincible > 0 then
                event.propagate = false
            end
             
        end)
    
    instance.chains.tick:addHandler( 
        function() 
            if self.invincible > 0 then
                self.invincible = self.invincible - 1
            end
        end)
end

return InvincibleAfterHit