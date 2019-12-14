local invincible = function(event)
    event.propagate = false
    
end


local InvincibleHandler = class("InvincibleHandler")

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


local InvincibleAfterHit = function(entityClass)
    
    local template = entityClass.chainTemplate

    entityClass.__emitter:on("create", 
        function(instance) 
            local inv = InvincibleHandler(instance)      
        end
    )

    table.insert(entityClass.decorators, InvincibleAfterHit)
end4

return InvincibleAfterHit