-- block attacks from front
local Tinker = require '@tinkers.tinker'

-- here is a little problem I'll have to figure out
--
-- basically, what we want is 
-- a customizable contructor for shields so that you can pass it
-- the direction to block relative to the entity, amount of damage
-- that would destroy it and the pierce level it gives you
-- 
-- Summary: Shield(relativeDirection, damage, pierce)
--    
-- This shield has to work by adding handlers onto the 'defence' chain
-- There is no problem with tinking, though there is one with untinking
-- The untinking should be done via the destruction of the item in
-- inventory, if there is one, and then untinking of the handler. Now I'm
-- realizing there also has to be a way of removing items without dropping 
-- them. There are two ways of achieving this last point that I can think
-- of:
--      1. implement a remove and an unequip method on the entity (maybe as
--         a decorator);
--      2. make items remove themselves from the inventory. The problem is
--         the current code does it in the other direction: removing
--         a specific item is done by accessing the inventory.
-- 
-- I think the remove() and unequip() methods make most sense.
--
-- So now back to the main question: how do I destroy the item from within the
-- tinker's handler?
--      1. use a refTinker that would have a reference to the item (bad)
--      2. define a new type of tinkers that would have a reference
--         to the item instead of the tinker (better).
--      3. the generator would provide a reference to the item, or be
--         defined within the shield constructor (+++)
--
-- So the workflow would be as follows:
--      1. The entities' equip method is activated, which abstractizes the way the
--         entity stores their items, that is, no storing or an inventory;
--      2. The item's beEquipped method is activated, which tinks the tinker;
--      3. When it is time to remove the item, it is done through the handler by
--         doing `event.actor:unequip(item)` or `event.actor:remove(item)` or
--         `self` instead of `item` if the handlers are defined within the item's
--         constructor scope.
--      4. The item untinks the tinker and spawn stuff in world if needed.
--
-- The key thing to keep in mind is that items (that is, their logic and the tinker)
-- are actually stateless. There is just one instance of the item in the game.
-- The item constructor is used for instantiating these items, but not spawning
-- of the items in the world. So the shield constructor will be called just once
-- for each TYPE of shield there is.

local Shield = class("Shield", Item)

function Shield:__construct(relativeDirection, damage, pierce, resReduction)

    relativeDirection = relativeDirection or Vec(1, 0)
    damage = damage or math.huge
    pierce = pierce or 0
    resReduction = resReduction or 0

    -- convert relative direction to an angle
    local angle = Vec.angleBetween( Vec(1, 0), relativeDirection ) + math.pi
    

    local function block(event)
        -- get the relative direction
        local dir = event.actor.orientation:rotate(angle):normComps()

        if event.action.direction:equals(dir) then
            event.resistance:add('pierce', pierce)
            -- see if the shield should
            if event.action.attack.damage >= damage then
                -- remove the item. Note the item is `self`, since
                -- the handler is defined within the shield constructor
                event.actor:removeItem(self)
            end
        end
    end

    local function reducePushRes(event)
        -- get the relative direction
        local dir = event.actor.orientation:rotate(angle):normComps()

        if event.action.direction:equals(dir) then
            event.resistance = event.resistance - resReduction
        end
    end

    -- make the tinker
    local tinker = Tinker({
        { 'defence',   { block,         Ranks.MEDIUM } },
        { 'checkPush', { reducePushRes, Ranks.MEDIUM } }
    })

    -- activate the base constructor
    Item.__construct(self, tinker)

end

-- for now use the second slot
Shield.slot = InventorySlots.body

-- return a test shield for now
return Shield( Vec(1, 0), 2, 2, 1 )