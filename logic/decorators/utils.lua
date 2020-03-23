local utils = {}

utils.checkApplyCycle = function(nameCheck, nameApply)
    return function(self, action)
        local event = Event(self, action)

        self.chains[nameCheck]:pass(event, Chain.checkPropagate)

        if event.propagate then
            self.chains[nameApply]:pass(event, Chain.checkPropagate)
        end        

        return event
    end
end



utils.armor = function(event)
    local actor = event.actor
    local protectionModifier = actor.baseModifiers.protection

    event.attack.damage = 
        clamp(
            event.attack.damage - protectionModifier.armor, 
            1, 
            protectionModifier.maxDamage or math.huge
        )
        
    if event.attack.pierce > protectionModifier.pierce then
        event.attack.damage = 0  
    end
end

utils.nothing = function(event)    
end

return utils