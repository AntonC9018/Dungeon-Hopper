--
-- gameobject.lua
--
-- This is the base class of all game objects in the game.
-- A game object is any object that exists in the world, at some specific position

local None = require '@action.actions.none'
local Cell = require("world.cell")
local Emitter = require("lib.emitter")

local GameObject = class("GameObject")

-- fallback options
GameObject.layer = Cell.Layers.misc
GameObject.priority = 0


local id = 0

local function generateId()
    id = id + 1
    return tostring(id)
end

-- every game object must have a position coordinate pair
function GameObject:init(pos, world)
    self.id = generateId()
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
    -- self.emitter = Emitter()

    if self.chainTemplate ~= nil then
        self:applyDecorators()
    end
end


-- get the next action based on the game state
-- the default is doing nothing
function GameObject:calculateAction()
    self.nextAction = None()
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


return GameObject
