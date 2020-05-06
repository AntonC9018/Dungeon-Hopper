display.setDefault('magTextureFilter', 'nearest')
display.setDefault('minTextureFilter', 'nearest')

local Graphics = class("Graphics")

local UNIT = 32
local SCALE = 16

function Graphics:__construct(assets)
    self.assets = assets
    -- TODO: make this into a list of wrappers
    -- each wrapper world contain a map of all possible events
    -- to sprite sheets etc.
    self.sprites = {}
end

local id = 0

function Graphics:generateId()
    id = id + 1
    return tostring(id)
end

function Graphics:createSpriteOfType(spriteType)
    local id = self.generateId()
    local filepath = self.assets.loadedSprites[spriteType].image
    self.sprites[id] = display.newImage(filepath)
    return id
end

function Graphics:resetZ()
    -- in case of corona renderer, it does nothing
end

function Graphics:toFront(id)
    self.sprites[id]:toFront()
end

function Graphics:setCenter(vec)
    -- just shift everything by vec
    self.offset = -vec
end

function Graphics:updateObject(id, state)
    local obj = self.sprites[id]
    local newCoords = (self.offset + state.pos) * UNIT
    obj.x = newCoords.x + display.contentCenterX
    obj.y = newCoords.y + display.contentCenterY
end

function Graphics:removeObject(id)
    self.sprites[id].alpha = 0
end


return Graphics