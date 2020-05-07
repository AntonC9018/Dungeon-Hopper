local Item = class('Item')

local id = 1

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

function Item:getItemId()
    return self.id
end

return Item