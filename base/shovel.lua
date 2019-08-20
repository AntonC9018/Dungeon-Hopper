local Displayable = require('base.displayable')

-- TODO: inherit from item
local Shovel = class("Shovel", Displayable)

Shovel.scale = 1 / UNIT
Shovel.frail = false
Shovel.pos = vec(0, 0)
Shovel.offset = vec(0, 0)

Shovel.att_base = {
    dig = 1
}

-- function Shovel:__construct(o, w, s)
function Shovel:__construct(w)
    self.world = w
    -- self:createSprite(o, s)
    -- self:listenAlpha()
    -- self.sprite.alpha = 0
end

function Shovel:attemptDig(a, t)

    local ps = a.actor:getPointsFromDirection(a.dir)

    for i = 1, #ps do
        local x, y = ps[i]:comps()
        self:digAt(x, y, a, t)
    end

end

function Shovel:digAt(x, y, a, t)
    local cell = self.world.grid[x][y]
    if cell.wall then
        cell.wall:takeHit(a)
        t:set('dug')
        if not cell.wall then
            t:set('dug_out')
        end
    end
end


function Shovel:listenAlpha()
    self.sprite:addEventListener("sprite", function(event)
        if event.phase == "began" then
            self.sprite:toFront()
            self.sprite.alpha = 1
        elseif event.phase == "ended" then
            self.sprite.alpha = 0
        end
    end)
end

function Shovel:playAudio()
    audio.play(AM[class.name(self)].audio['dig'])
end

function Shovel:playAnimation(t, ts)
    self:anim(ts, 'dig')
end

function Shovel:orient(dir, i)
    local a = vec(1, 0):angleBetween(dir)
    self.sprite.rotation = a * 180 / math.pi
end

function Shovel:getItemType()
    return 'shovel'
end

return Shovel