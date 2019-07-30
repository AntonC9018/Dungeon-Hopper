local Weapon = require('base.weapon')

local EnemyWeapon = class('EnemyWeapon', Weapon)

-- the enemy can attack if in the process it touches any walls
-- it would attempt to break those walls instead 
-- or bump into them, for that matter
EnemyWeapon.ignore_walls = false

-- whether to be able to hit only the player while
-- attacking multiple tiles
EnemyWeapon.just_player = false

-- attack only if targeted the player
EnemyWeapon.just_when_player = true

-- whether to attack walls instead of bumping
EnemyWeapon.attack_walls = false




function EnemyWeapon:testAttack(a, pa, t)

    t._in = true -- we hack this so that t is not applied

    -- save the position, because we may end up moving
    local pos = a.actor.pos
    -- do the attack fictitiously, without real consequences
    local h = self:attemptAttack(a, t)
    -- restore the previous position
    a.actor:restorePos(pos, t)

    if not self.ignore_walls then
        for i = 1, #h do
            -- the cell is the third element in hits array
            local cell = h[i][3]
            if cell.wall then
                return h, 'block'
            end
        end
    end

    local function playerIndex()
        for i = 1, #h do
            if h[i][3].entity and h[i][3].entity:isPlayer() then
                return i
            end
        end
        return false
    end

    local function askToMove()
        local y = true
        for i = 1, #h do
            if 
                h[i][3].entity and not 
                h[i][3].entity.moved and not 
                h[i][3].entity.doing_action 
            then
                -- ask the entity to move if it has not
                h[i][3]:act(pa)
                y = false
            end
        end
        return y
    end

    local function notPlayer()
        -- check if all enemies have moved
        -- make them move if they have not
        if not askToMove() then
            -- redo the iteration (for the current action)
            return h, false             
        
        else
            -- bump into the entity
            return h, 'entity'
        end
    end

    -- now it either ignores blocks or no blocks were found

    -- no hits registered
    if #h == 0 then
        -- in this case the enemy will attempt to move
        -- or it will just attack the empty space
        return h, 'free'
    end


    local i = playerIndex()

    -- If attacking only if the player has been targeted 
    if self.just_when_player then
        -- among the tiles it attacked there is a player
        if i then
            -- attacking only the player
            if self.just_player then
                return { h[i] }, 'player'
            -- attacking all enemies
            else
                return h, 'player'
            end
        end
    -- attacking just the player
    else
        if i then 
            return self.just_player and { h[i] } or h, 'player'
        else
            -- attack 
            return h, 'entity'
        end
    end
    
    return notPlayer()  
end

-- this ensures the attack is done fictitiously
function EnemyWeapon:attack()
end

function EnemyWeapon:act(a, h, t)
    a.actor.facing = a.dir

    Weapon.orient(self, a.dir, h[1] and h[1][5] or 1)
    for i = 1, #h do
        Weapon.attack(self, unpack(h[i]))
    end
    t:set('hit')
end

function EnemyWeapon:orient() end

return EnemyWeapon