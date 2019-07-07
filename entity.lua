Entity = Animated:new{}

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

-- numerical states (decremented each loop)
Entity.stunned = 0
Entity.stuck = 0
Entity.confused = 0
Entity.on_fire = 0
Entity.frozen = 0
Entity.invincible = 0

-- Stats
Entity.hp = {} -- list of health points (red, blue, yellow, hell knows)
Entity.dig = 0 -- level of dig (how hard are the walls it can dig)
Entity.dmg = 0 -- damage
Entity.armor = 0 -- damage reduction (down to 0.5 hp)

-- -ing stats
Entity.pushing = 0
Entity.stunning = 0
Entity.confusing = 0
Entity.tinying = 0
Entity.poisoning = 0
Entity.firing = 0

-- _res stats
-- numerical stats
Entity.dmg_res = 0 -- minimal amount of damage to punch through
Entity.push_res = 0
Entity.expl_res = 0
Entity.stun_res = 0
Entity.confusion_res = 0
Entity.stuck_res = 0
Entity.tiny_res = 0
Entity.poison_res = 0
Entity.fire_res = 0
-- boolean stats
Entity.slide_res = false


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
    self.bounces = {}
end

function Entity:tickAll()
    self.stunned = self.stunned - 1
    self.stuck = self.stuck - 1
    self.confused = self.confused - 1
    self.on_fire = self.on_fire - 1
    self.frozen = self.frozen - 1
    self.invincible = self.invincible - 1
end