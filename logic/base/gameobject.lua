--
-- gameobject.lua
--
-- This is the base class of all game objects in the game.
-- A game object is any object that exists in the world, at some specific position

local Actions = require 'logic.action.actions.actions'
local Cell = require("world.cell")
local Emitter = require("lib.emitter")

local GameObject = class("GameObject")

-- fallback options
GameObject.layer = Cell.Layers.misc
GameObject.priority = 0

-- every game object must have a position coordinate pair
function GameObject:init(pos, world)
    self.pos = pos
    self.world = world
    self.orientation = Vec(1, 0)
    -- default state is always 1
    -- this is the state in which the object is
    -- examples of states might be:
    --      1. a skeleton with head and without it
    --      2. rider on horse and without one
    self.state = 1
    -- @type Action
    self.nextAction = nil

    self.enclosingEvent = nil
    self.didAction = false

    -- create an emitter
    self.emitter = Emitter()

    self:applyDecorators()
end


-- get the next action based on the game state
-- the default is doing nothing
function GameObject:calculateAction()
    self.nextAction = Action.None()
end

function GameObject:executeAction()
    self.didAction = true 
end

function GameObject:applyDecorators()
    -- initialize chains
    self.chains = self.chainTemplate:init()

    -- initialize decorators
    self.decorators = {}
    for i = 1, #self.decoratorsList do
        local decoratorClass = self.decoratorsList[i]
        -- instantiate the decorator
        self.decorators[class.name(decoratorClass)] = 
            decoratorClass(self)
    end
end

function GameObject:isSized()
    return false
end

function GameObject:isPlayer()
    return self.layer == Cell.Layers.player
end

function GameObject:tick()
    -- TODO:
end

function GameObject:die()
end

return GameObject
