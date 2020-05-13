local Action = require '@action.action'

local function die(event)
    event.actor:die()
end

local action = Action.fromHandlers(
    'DieAction',
    { die }
)

return action