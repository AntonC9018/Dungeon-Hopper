local Event = class("Event")

function Event:__construct(actor, action)
    self.entity = actor
    self.action = action

    self.propagate = true
end


return Event 