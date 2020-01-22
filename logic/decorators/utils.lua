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

utils.nothing = function(event)    
end

return utils