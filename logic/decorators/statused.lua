local utils = require "utils" 

-- TODO: implement these methods
local checkStatus = utils.nothing
local applyStatus = utils.nothing
local checkStatuses = utils.nothing

local Decorator = require 'decorator'
local Statused = class('Statused', Decorator)

Statused.affectedChains = {
    { "checkStatus", { checkStatus }},
    { "applyStatus", { applyStatus } }
}

Statused.activate = 
    utils.checkApplyCycle("checkStatus", "applyStatus")


return Statused