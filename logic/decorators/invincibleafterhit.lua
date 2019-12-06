local invincible = function(event)
    event.propagate = false
    return event
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
            return event
        end)

    instance.chains.defence:addHandler(
        function(e) 
            if self.invincible > 0 then
                event.propagate = false
            end
            return event 
        end)
    
    instance.emitter:on("reset", 
        function() 
            if self.invincible > 0 then
                self.invincible = self.invincible - 1
            end
        end)
end


local InvincibleAfterAttack = function(entityClass)
    
    local template = entityClass.chainTemplate

    entityClass.__emitter:on("create", 
        function(instance) 
            local inv = InvincibleHandler(instance)      
        end
    )
end