--
-- gameobject.lua
--
-- This is the base class of all game objects in the game.
-- A game object is any object that exists in the world, at some specific position

local None = require '@action.actions.none'
local Emitter = require("lib.emitter")
local History = require '@history.history'
local GameObject = class("GameObject")

-- fallback options
GameObject.layer = Layers.misc
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

    self.nextAction = nil

    self.enclosingEvent = nil
    self.didAction = false
    self.dead = false

    if self.chainTemplate ~= nil then
        self:applyDecorators()
    end

    self.history = History(self)

    -- this is a blackbox object for entities themself
    -- it is managed solely by tinkers
    self.tinkerData = {}
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
    return self.layer == Layers.player
end

function GameObject:registerEvent(code)
    self.world:registerEvent(self, code)
    self.history:registerEvent(code)
end


return GameObject
