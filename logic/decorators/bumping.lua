
local Decorator = require 'logic.decorators.decorator'
local utils = require 'logic.decorators.utils'
local Changes = require "render.changes"
local Move = require("logic.action.handlers.basic").Move

local Bumping = class('Bumping', Decorator)

Bumping.affectedChains = {
    { "failAction", {  } }
}

return Bumping