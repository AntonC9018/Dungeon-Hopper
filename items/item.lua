local Item = class('Item')

local id = 1

Item.tinker = {
    tink = function() end,
    untink = function() end
}

function Item:__construct(tinker)
    self.id = id
    id = id + 1
    self.tinker = tinker
end

function Item:beEquipped(entity)
    self.tinker:tink(entity)
end

function Item:beUnequipped(entity)
    self.tinker:untink(entity)
    -- spawn the entity back
    entity.world:createDroppedItem( self.id, entity.pos )
end

function Item:beDestroyed(entity)
    self.tinker:untink(entity)
end

function Item:getItemId()
    return self.id
end

return Item