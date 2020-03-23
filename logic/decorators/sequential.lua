
local utils = require "utils" 
local Sequence = require "logic.action.sequence.sequence"

local Decorator = require 'decorator'
local Sequential = class('Sequential', Decorator)

local function Sequential:activate(actor)
    actor.nextAction = actor.sequence:nextAction()
end

return Sequential