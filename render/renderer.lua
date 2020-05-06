-- This is a simple graphics object manager for now
--
-- The graphics is done in a completely separate file, see graphics.manager
local Graphics = require "engine.graphics"

local Renderer = class("Renderer")
local Changes = require 'render.changes'

function Renderer:__construct(assetManager)
    self.graphics = Graphics(assetManager)
    self.assets = assetManager
    self.renderObjects = {}
    self.currentStates = {}
    self.players = {}
    self.states = {{}}
end


function Renderer:addRenderEntity(gameObject)
    -- printf("Adding game object of type %s", class.name(gameObject)) -- debug
    local spriteType = self.assets:getObjectType(gameObject)
    local spriteId = self.graphics:createSpriteOfType(spriteType)

    local renderObject = 
        {
            id = gameObject.id,
            layer = gameObject.layer,
            spriteId = spriteId
        }

    table.insert(self.renderObjects, renderObject)

    -- add the object to the current states
    -- that is, the immediate position, orientation, state number, 
    self.currentStates[gameObject.id] = 
        {
            pos = gameObject.pos,
            orientaion = gameObject.orientation,
            state = gameObject.state
        }
end


-- for now, just draw the final versions
function Renderer:pushChanges(beatChanges)
    -- each change is a 
    -- {
    --      id: id of the renderEntity/gameObject,
    --      pos: vec,
    --      orientation: vec,
    --      state: number,
    --      event: the name of the event. see render\changes.lua
    -- }
    -- the beatChanges array containts a table for each of the phases
    -- that table has all changes to object states as they happened in order
    -- so beatChanges is like { { ... changes }, { ... }, { ... }, ... }
    
    -- print(ins(beatChanges, { depth = 4 })) -- debug

    -- TODO:
    -- A list of final states and animation identificators for each frame
    -- For every phase of the beat, the list of renderObjects should be sorted according to
    -- the y position on the grid. This position must be saved on this
    -- final state object. Also, the necessary exact animations (you are getting just a list 
    -- of all changes, so, for example, a hit doesn't necessarily mean the hit animation should 
    -- be started, as it might as well mean there was a hit + a move, which means 
    -- a dash or something should be started) and state transitions
    -- (that is, the object states, like with head and without, which uses 
    -- different sprites) should be computed and put together. What matters is that
    -- in the end, Graphics should get the image number and the exact position.
    -- No other information (also rotation maybe).

    self.states = {{}}

    -- just draw the last state for now
    for i, changes in ipairs(beatChanges) do
        for j, change in ipairs(changes) do
            self.states[1][change.id] = change
        end
    end

end

function Renderer:setAsPlayer(id)
    self.players[#self.players + 1] = id
end

function Renderer:unsetPlayer(id)
    for i = 1, #self.players do
        if self.players[i] == id then
            table.remove(self.players, i)
            return
        end
    end
end

function Renderer:getCenterPointBetweenPlayers()
    local centerPoint = Vec(0, 0);
    if #self.players == 0 then
        return centerPoint
    end
    for i = 1, #self.players do
        centerPoint = 
            centerPoint + self.currentStates[self.players[i]].pos
    end
    return centerPoint * 1 / #self.players 
end


-- called each frame
function Renderer:update(time)

    -- TODO: do some interpolation between states (left to be figured out)
    -- for now, just use the latest states
    for i = 1, #self.renderObjects do
        local obj = self.renderObjects[i]
        local newState = self.states[#self.states][obj.id]
        if newState ~= nil then
            self.currentStates[obj.id] = newState
        end 
    end
    
    -- sort the render objects based on current y position and layer
    -- TODO: sort them just once the moment a new phase starts 
    self:sortRenderObjects()

    -- TODO: move them to the front only once the phase starts
    for i, obj in ipairs(self.renderObjects) do
        self.graphics:resetZ()
        self.graphics:toFront(obj.spriteId)
    end

    -- figure out the center point between the players
    local centerPoint = 
        self:getCenterPointBetweenPlayers()

    self.graphics:setCenter(centerPoint)

    -- Change position and stuff of all objects
    for i, obj in ipairs(self.renderObjects) do
        
        -- debug
        if self.currentStates[obj.id].event == Changes.Dead then
            self.graphics:removeObject(
                obj.spriteId
            )
        end

        self.graphics:updateObject(
            obj.spriteId,
            self.currentStates[obj.id]
        )
    end
end


function Renderer:sortRenderObjects()

    table.sort( 
        self.renderObjects, 

        function(objA, objB) 
            local currentA = self.currentStates[objA.id]
            local currentB = self.currentStates[objB.id]
            local yDifference = currentA.pos.y - currentB.pos.y
            
            if yDifference == 0 then
                return objA.layer < objB.layer
            end

            return yDifference > 0                 
        end
    )

end




return Renderer