Entity = Animated:new{}

local DEBUFFS = {'stun', 'confuse', 'tiny', 'poison', 'fire', 'freeze'}

local SPECIAL = {'push', 'pierce'}



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
-- Entity.bounces = {} -- pushing, bounces and such


function Entity:reset()
    self.displaced = false
    self.bumped = false
    self.hit = false
    self.hurt = false
    self.dug = false
    self.last_a = self.cur_a
    self.cur_a = false
    self.bounces = {}
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


function Entity:bounce(dir, w)

    local t = #self.bounces > 0 and self.bounces or ({ self.x, self.y })
    local x, y = t[1] + dir[1], t[2] + dir[2]

    if not w.walls[x][y] then

        if w.enemGrid[x][y] == w.player then
            w.takeHit(self)

        elseif not w.enemGrid[x][y] then
            table.insert(self.bounces, { x, y })
        
        else
            table.insert(self.bounces, { self.x, self.y })
        end
    end

end