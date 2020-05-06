local Tinker = require 'logic.tinkers.tinker'

local function forbidAction(event)
    event.propagate = false
end

return Tinker({
    { 'checkAction', forbidAction }
})