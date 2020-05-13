local utils = require "@decorators.utils" 
local Changes = require "render.changes"
local Decorator = require '@decorators.decorator'

local Interactable = class('Interactable', Decorator)

Interactable.affectedChains = {
    { "checkInteracted", 
        {
        }
    },
    { "beInteracted", 
        {
            -- do this for a test
            function(event)
                print('success')
                event.actor:die()
            end
        }
    }
}

Interactable.activate =
    utils.checkApplyCycle("checkInteracted", "beInteracted")


return Interactable