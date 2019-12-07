local funcs = {}

funcs.checkApplyCycle = function(nameCheck, nameApply)
    return function(self)
        local event = Event(self, action)

        self.chains[nameCheck]:pass(event, Chain.checkPropagate)

        if event.propagate then    
            self.chains[nameApply]:pass(event, Chain.checkPropagate)
        end

        return event
    end
end

return funcs