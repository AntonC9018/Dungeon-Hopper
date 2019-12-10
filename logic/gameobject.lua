--
-- gameobject.lua
--
-- This is the base class of all game objects in the game.
-- A game object is any object that exists in the world, at some specific position

local Action = require("action")
local Cell = require("cell")

local GameObject = class("GameObject")

-- fallback options
GameObject.layer = Cell.Layers.misc
GameObject.priority = 0
GameObject.actionAlgorithm = 
    function(self) end

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
    self.didAction = false
end


-- get the next action based on the game state
-- the default is doing nothing
function GameObject:calculateAction()
    self.nextAction = Action.None()
end

function GameObject:executeAction()
    self.doingAction = true
    self.actionAlgorithm(self)
    self.doingAction = false
    self.didAction = true 
end

return GameObject
