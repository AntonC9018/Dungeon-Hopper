local Action = require '@action.action'

local function incState(event)
    event.actor.state = event.actor.state + 1
    event.success = true
end

local action = Action.fromHandlers(
    'IncStateAction',
    { incState }
)

return action