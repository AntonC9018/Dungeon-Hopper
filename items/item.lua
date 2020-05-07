local Item = class('Item')

function Item:__construct(droppedItemClass, tinker)
    self.droppedItemClass = droppedItemClass
    self.tinker = tinker
end

function Item:beEquipped(entity)
    self.tinker:tink(entity)
end

function Item:beUnequipped(entity)
    self.tinker:untink(entity)
    -- spawn the entity back
    entity.world:create( self.droppedItemClass, entity.pos )
end

return Item