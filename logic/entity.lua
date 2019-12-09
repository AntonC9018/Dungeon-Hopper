--
-- entity.lua
--
-- This is the base class for any entity in the game


-- Decorator stuff
function Entity:isDecorated(decorator)
    return table.some(self.decorators, decorator)
end

function Entity:executeMove(action)
    return nil
end

function Entity:executeAttack(action)
    return nil
end

function Entity:beAttacked(action)
    return nil
end

function Entity:bePushed(action)
    return nil
end

function Entity:beStatused(action)
    return nil
end


-- make these a bit more efficient
function Entity:isAttackableOnlyWhenNextToAttacker()
    return self:isDecorated(Decorators.AttackableOnlyWhenNextToAttacker)  
end

function Entity:isAttackable()
    return self:isDecorated(Decorators.Attackable)
end

return Entity