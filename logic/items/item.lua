local Item = class('Item')

Item.tinker = {
    tink = function() end,
    untink = function() end
}

-- the id is set by the modloader
Item.id = 0

function Item:__construct(tinker)
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