local Displayable = require('base.displayable')
local Entity = require('base.entity')

local Item = class('Item', Entity)

Item.item_slot = 'none'
Item.socket_type = 'item'


function Item:__construct(world)
    self.world = world
end


Item.create = function(self, world, x, y, im1, im2)

    local item = self(world)

    if x and y then
        item.pos = Vec(x, y)
    end

    if im2 then
        item.sprite_picked = item:createImage( unpack(im2) )
        item.sprite_picked.alpha = 0
    end

    if im1 then
        -- im1 is necessary for creating a dropped sprite
        item.sprite_dropped = item:createImage( unpack(im1) )
        item.sprite_dropped.alpha = 0
    end

    return item

end


Item.createDropped = function(self, world, x, y, im1, im2)

    assert(x and y and x > 0 and y > 0, 'Position not specified')

    local item = self(world)

    item.pos = Vec(x, y)

    if im2 then
        item.sprite_picked = item:createImage( unpack(im2) )
        item.sprite_picked.alpha = 0
    end

    -- im1 is necessary for creating a dropped sprite
    item.sprite_dropped = item:createImage( unpack(im1) )

    item.dropped = true

    return item
end


Item.createUndropped = function(self, world, x, y, im1, im2)

    local item = self(world)

    if x and y then
        item.pos = Vec(x, y)
    end

    -- an image for undropped is not necessary
    if im2 then
        item.sprite_picked = item:createImage( unpack(im2) )
        item.sprite_dropped.alpha = 1
    end

    -- an image for the dropped version is not necessary either
    if im1 then
        item.sprite_dropped = item:createImage( unpack(im1) )
        item.sprite_dropped.alpha = 0
    else
        -- the item must be destroyed if it ever be dropped
        item.drop = function()
            item.dead = true
        end
    end

    return item

end



function Item:pickup(pos)

    assert(self.dropped == true or self.dropped == nil, 'Cannot pick up an undropped item')

    self.sprite_dropped.alpha = 0
    self.world:removeFromGrid(self)
    if pos then
        self.pos = pos
        self.sprite_picked.alpha = 1
        self.sprite_picked.x = pos.x
        self.sprite_picked.y = pos.y
        self.sprite = self.sprite_picked
    end

    self.dropped = false
end


function Item:drop(pos)

    assert(self.dropped == false or self.dropped == nil, 'Cannot drop an already dropped item')

    self.pos = pos
    self.sprite_dropped.alpha = 1
    self.sprite = self.sprite_dropped
    if self.sprite_picked then
        self.sprite_picked = 0
    end
    self.world:resetInGrid(self)

    self.dropped = true

end

function Item:getItemSlot()
    return self.item_slot
end

return Item