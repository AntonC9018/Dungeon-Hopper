local Weapon = require('base.weapon')

local Whip = class('Whip', Weapon)

Whip.scale = 1 / UNIT

Whip.att_base = {
    dmg = 1
}

Whip.pattern = { vec(1, 0), vec(1, 1), vec(1, -1), vec(1, 2), vec(1, -2) }
Whip.knockb = { vec(1, 0), vec(0, 1), vec(0, -1), vec(0, 1), vec(0, -1) }
Whip.reach = { false, false, false, 2, 3 }

function Whip:__construct(...)
    Weapon.__construct(self, ...)

    self.swipe = self:createSprite({
        {
            name = "swipe1",
            start = 1,
            count = 3,
            time = 1000,
            loopCount = 1
        },
        {
            name = "swipe2",
            start = 4,
            count = 3,
            time = 1000,
            loopCount = 1
        },
        {
            name = "swipe3",
            start = 7,
            count = 3,
            time = 1000,
            loopCount = 1
        }
    })
    self:listenAlpha()
    self.swipe.anchorX = 1 / 6
    self.swipe.anchorY = 0.5
    self.swipe.alpha = 0
end

function Whip:playAnimation(t, ts)
    local hit = t['hits'][1]

    self:orient(t.hits)
    self:position(t.hits)

    if hit.index == 1 then
        self:anim(ts, 'swipe1')
    elseif
        hit.index == 2 or hit.index == 3
    then
        self:anim(ts, 'swipe2')
    else
        self:anim(ts, 'swipe3')
    end

end

function Whip:orient(hits)
    local knb = self:getKnockb(hits[1].index)

    local a =
        vec(1, 0):angleBetween( hits[1].turn.final.facing ) +
        vec(1, 0):angleBetween( knb )

    self.swipe.rotation = math.deg(a)

    if knb.y >= 0 then
        self.swipe.yScale = -1 * self.scale
    else
        self.swipe.yScale = self.scale
    end
end

function Whip:position(hits)
    local ps = hits[1].action.actor:getPointsFromDirection(hits[1].turn.final.facing)
    local avg_pos = average(ps)

    self.sprite.x = avg_pos.x
    self.sprite.y = avg_pos.y
end

return Whip