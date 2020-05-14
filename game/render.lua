
local assets = require('render.assets')()
local renderer = require('render.renderer')(assets)

local function registerTypes()
    -- register all assets
    for _, t in ipairs(Entities) do
        local assetType = assets:getObjectType(t)
        assets:registerGameObjectType(assetType)
    end
    local DroppedItem = require '@items.droppeditem'
    local assetType = assets:getObjectType(DroppedItem)
    assets:registerGameObjectType(assetType)
    
end

return {
    renderer = renderer,
    assets = assets,
    registerTypes = registerTypes
}