local Event = class("Event")

function Event:__construct(actor, action)
    self.actor = actor
    self.action = action

    self.propagate = true
end


return Event 