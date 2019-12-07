--
-- entity.lua
--
-- This is the base class for any entity in the game


-- Decorator stuff
function Entity:isDecorated(decorator)
    return table.some(self.decorators, decorator)
end

function Entity:executeMove(action)
    return false
end

function Entity:executeAttack(action)
    return false
end

function Entity:beAttacked(action)
    return false
end

function Entity:bePushed(action)
    return false
end

function Entity:beStatused(action)
    return false
end