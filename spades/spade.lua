local Animated = require('animated')

local Spade = Animated:new{
    -- move, then dig
    move_dig = false,
    -- dig, then move
    dig_move = false,
    hit_all = false,
    pattern = {{ 1, 0 }},
    dig = 1,
    spade = true,
    frail = false
}


function Spade:listenAlpha()
    self.sprite:addEventListener("sprite", function(event)
        if event.phase == "began" then
            self.sprite:toFront()
            self.sprite.alpha = 1
        elseif event.phase == "ended" then
            self.sprite.alpha = 0
        end
    end)
end


function Spade:orient(dir)
    self.sprite.rotation = angleBetween({ 1, 0 }, dir) / math.pi * 180    
end



function Spade:attemptDig(dir, t, w, owner)

    local digs = {}

    -- self.sprite.x = dir[1] + owner.x
    -- self.sprite.y = dir[2] + owner.y

    -- self:orient(dir)

    local ihat = dir
    local jhat = rotateHalfPi(dir)

    for i = 1, #self.pattern do

        local dir = dot(self.pattern[i], ihat, jhat)

        local ps = patternDirToPoints(dir, owner, w)

        for j = 1, #ps do
        
            local x, y = ps[j][1], ps[j][2]

            if         
                -- there is a wall
                w.walls[x][y]
            
            then

                local obj = {
                    wall = w.walls[x][y],
                    p = ps[j],
                    pattern = self.pattern[i],
                    owner = owner,
                    t = t,
                    w = w
                }

                local dug = self:dig(obj)

                if dug then

                    if not self.dig_all then
                        t:set('dug')
                        return true
                    else
                        table.insert(digs, obj)
                    end

                end
            end
        end
    end

    if #digs > 0 then 
        t:set('dug')
        return digs
    end

    return false
end

function Spade:dig(obj)
    -- TODO: enhance
    if self.dig > obj.wall.dig_res then
        obj.w.walls[obj.ps[1]][obj.ps[2]] = false
        return true
    end
    return false
end

function Spade:playAudio()
    -- if self.destroyed then        
    --     audio.play(self.audio['destroyed'])
    -- else
    --     audio.play(self.audio['dig'])
    -- end
end

function Spade:playAnimation(t)
    -- self:anim(t, 'dig')
end

function Spade:destroy()
    self.destroyed = true
end

return Spade