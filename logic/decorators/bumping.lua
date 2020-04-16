
local Decorator = require 'logic.decorators.decorator'
local Bumping = class('Bumping', Decorator)

local function bump(event)



end

Bumping.affectedChains = {
    { "failAction", { bump } }
}

return Bumping