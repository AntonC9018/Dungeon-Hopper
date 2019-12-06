--
-- entity.lua
--
-- This is the base class for any entity in the game


-- Decorator stuff
function Entity:isDecorated(decorator)
    return table.some(self.decorators, decorator)
end