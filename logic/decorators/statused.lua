local utils = require "logic.decorators.utils" 
local Changes = require "render.changes"

-- TODO: implement these methods
local checkStatus = utils.nothing
local applyStatus = utils.nothing
local checkStatuses = utils.nothing

local Decorator = require 'logic.decorators.decorator'
local Statused = class('Statused', Decorator)

Statused.affectedChains = {
    { "checkStatus", 
        { 
            checkStatus
        }
    },
    { "applyStatus", 
        { 
            applyStatus,
            utils.regChangeFunc(Changes.Status)
        } 
    }
}

Statused.activate = 
    utils.checkApplyCycle("checkStatus", "applyStatus")


return Statused