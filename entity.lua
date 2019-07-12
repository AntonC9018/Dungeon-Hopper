Entity = Animated:new{}

local DEBUFFS = {'stun', 'confuse', 'tiny', 'poison', 'fire', 'freeze'}

local SPECIAL = {'push', 'pierce'}


function Entity:new(...)
    local o = Animated.new(self, ...)
    o.history = {}
    o.prev_pos = {}
    return o
end

-- states
-- game logic states
Entity.displaced = false -- TODO: change to number of tile?
Entity.bumped = false
Entity.hit = false -- TODO: change to number of guys hit?
Entity.hurt = false -- TODO: change to damage taken?
Entity.dead = false
Entity.dug = false -- dug a tile this loop

-- boolean states
Entity.sliding = false
Entity.levitating = false

-- these two are a bit special 
Entity.stuck = 0
Entity.invincible = 0

-- Stats
Entity.hp = {} -- list of health points (red, blue, yellow, hell knows)
Entity.dig = 0 -- level of dig (how hard are the walls it can dig)
Entity.dmg = 0 -- damage
Entity.armor = 0 -- damage reduction (down to 0.5 hp)


-- set up default values for debuff properties
for i = 1, #DEBUFFS do
    -- _ed stats, decremented each loop
    Entity[DEBUFFS[i]..'_ed'] = 0
    -- _ing stats
    Entity[DEBUFFS[i]..'_ing'] = 0
    -- _res stats
    Entity[DEBUFFS[i]..'_res'] = 0
    -- _amount stats. Amount of an effect in an attack
    -- For example, the amount of seconds the attacked is gonna burn
    Entity[DEBUFFS[i]..'_amount'] = 0
end

-- Do the same for special effects
for i = 1, #SPECIAL do
    Entity[SPECIAL[i]..'_ing'] = 0
    Entity[SPECIAL[i]..'_res'] = 0
    Entity[SPECIAL[i]..'_amount'] = 0
end

-- numerical stats
Entity.dmg_res = 0 -- minimal amount of damage to punch through

-- these are a bit special
-- normal attacks cannot apply these
Entity.explode_res = 0
Entity.stuck_res = 0
Entity.slide_res = 0

-- vector values
-- direction the thing is pointing
-- Entity.facing = { 0, 0 } -- this is an object, so do not modify it inside some method!
-- Entity.last_a = {} -- last action
-- Entity.cur_a = {} -- current action
-- Entity.history = {} -- pushing, history and such


function Entity:reset()
    self.displaced = false
    self.bumped = false
    self.hit = false
    self.hurt = false
    self.dug = false
    self.last_a = self.cur_a
    self.cur_a = false
    self.prev_pos = { x = self.x, y = self.y }
    self.history = {}
end

-- Decrement all debuffs
function Entity:tickAll()
    
    for i = 1, #DEBUFFS do
        self[DEBUFFS[i]..'_ed'] = math.max(self[DEBUFFS[i]..'_ed'] - 1, 0)
    end

    self.stuck = math.max(self.stuck - 1, 0)
    self.invincible = math.max(self.invincible - 1, 0)
end

-- return the actual damage dealt from an attack
function Entity:calculateAttack(from)
    return math.max(
        -- take armor into consideration
        math.max(from.dmg - self.armor, 0.5) -
        -- resist damage if not pierced through
        (self.pierce_res < from.pierce_ing and 0 or self.dmg_res), 0)
end

-- update _ed parameters 
function Entity:applyDebuffs(from)

    for i = 1, #DEBUFFS do
        if  from[DEBUFFS[i]..'_amount'] > 0 and 
            self[DEBUFFS[i]..'_res'] < from[DEBUFFS[i]..'_ing'] 
            then   
                -- reset the debuff count  
                self[DEBUFFS[i]..'_ed'] = from[DEBUFFS[i]..'_amount']
            end
    end
end

function Entity:loseHP(dmg)

    self.health = self.health - dmg

    if (self.health <= 0) then
        self.dead = true     

    end
end


function Entity:bounce(trap, w)

    local x, y = self.x + trap.dir[1], self.y + trap.dir[2]

    self:unsetPositions(w)

    if not w.walls[x][y] then

        -- we're an enemy and we intend to attack
        if w.entities_grid[x][y] == w.player and self ~= w.player and 
            contains(self:getSeqStep(), 'attack') then

                w.entities_grid[x][y].takeHit(self)
                table.insert(self.history, { x, y, trap })        
                self.hit = true

            elseif not w.entities_grid[x][y] then
                self.x, self.y = x, y

                table.insert(self.history, { x, y, trap })        
            else
                table.insert(self.history, { self.x, self.y, trap })
            end
    else
        table.insert(self.history, { self.x, self.y, trap })
    end

    if self.x == self.prev_pos.x and self.y == self.prev_pos.y then

    end

    self:resetPositions(w)
end


function Entity:unsetPositions(w)
    local ps = self:getPositions()
    for i = 1, #ps do
        w.entities_grid[ps[i][1]][ps[i][2]] = false
    end
end


function Entity:resetPositions(w)
    local ps = self:getPositions()
    for i = 1, #ps do
        w.entities_grid[ps[i][1]][ps[i][2]] = self
    end
end


function Entity:getPositions()
    local t = {}
    for i = 0, self.size[1] do
        for j = 0, self.size[2] do
            table.insert(t, { self.x + i, self.y + j })
        end
    end
    return t
end

-- get all adjacent positions
function Entity:getAdjacentPositions()
    local t = {}

    for i = -1, self.size[1] + 1 do
        table.insert(t, { self.x + i, self.y - 1 })
        table.insert(t, { self.x + i, self.y + 1 + self.size[2] })
    end

    for j = 0, self.size[1] do
        table.insert(t, { self.x - 1, self.y + j })
        table.insert(t, { self.x + 1 + self.size[1], self.y + j })
    end

    return t
end

-- given a direction, i.e. { 1, 0 }
-- return all positions associated with that direction
-- taking into considerations the sizes of the enemy 
function Entity:getPointsFromDirection(dir)
    local t = {} 

    if dir[1] ~= 0 and dir[2] == 0 then

        if dir[1] > 1 then
            -- right
            for j = 0, self.size[2] do
                table.insert(t, { self.x + self.size[1] + 1, self.y + j })
            end
        else
            -- left
            for j = 0, self.size[2] do
                table.insert(t, { self.x - 1, self.y + j })
            end
        end

    elseif dir[2] ~= 0 and dir[1] == 0 then

        if dir[2] > 1 then
            -- bottom
            for i = 0, self.size[1] do
                table.insert(t, { self.x + i, self.y + self.size[2] + 1 })
            end
        else
            -- top
            for i = 0, self.size[1] do
                table.insert(t, { self.x + i, self.y - 1 })
            end
        end

    else -- got diagnal direction

        if dir[1] > 0 then

            if dir[2] > 0 then
                -- bottom right
                table.insert(t, { self.x + 1 + self.size[1], self.y + 1 + self.size[2] })
            else 
                -- top right
                table.insert(t, { self.x + 1 + self.size[1], self.y - 1 })
            end

        else
            
            if dir[2] > 0 then
                -- bottom left
                table.insert(t, { self.x - 1, self.y + 1 + self.size[2] })
            else
                -- top left
                table.insert(t, { self.x - 1, self.y - 1 })
            end

        end
    end
    return t
end


function Entity:go(dir, w)
    -- delete itself from grid
    self:unsetPositions(w)
    self.x = dir[1] + self.x
    self.y = dir[2] + self.y
    table.insert(self.history, {self.x, self.y})
    self.facing = { dir[1], dir[2] }
    self.displaced = true
    -- shift the position in grid
    self:resetPositions(w)
end