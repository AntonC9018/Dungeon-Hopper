local Entity = require('base.entity')
local Displayable = require('base.displayable')
local Modifiable = require('logic.modifiable')
local Stats = require('logic.stats')
local HP = require('logic.hp')

local Wall = class('Wall', Entity)

Wall.zIndex = 8
Wall.socket_type = 'wall'


Wall.priority = 0
Wall.offset = Vec(0, -3 / 16)

Wall.dmg_thresh = 10

Wall.def_base = {
    dig = 1,
    push = 9999
}

Wall.hp_base = {
    type = "red",
    am = 1
}

function Wall:__construct(...)
    Entity.__construct(self, ...)
    self:createImage(1, UNIT, 2 * UNIT)
end

function Wall:isWall()
    return true
end

function Wall:applyDebuffs() end

function Wall:calcDmg(s, a)
    if s:get('dig') > 0 then
        return 2
    else
        return Entity.calcDmg(self, s, a)
    end
end


function Wall:act() self.moved = true end

function Wall:playAnimation(cb)

    if self.dead then
        self:_die()
    end

    cb()
end


function Wall:_die()
    self.sprite:removeSelf()
end

return Wall