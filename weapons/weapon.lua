local Animated = require('animated')

local Weapon = Animated:new{
    run_and_gun = false,
    hit_all = false
}


function Weapon:listenAlpha()
    self.sprite:addEventListener("sprite", function(event)
        if event.phase == "began" then
            self.sprite:toFront()
            self.sprite.alpha = 1
        elseif event.phase == "ended" then
            self.sprite.alpha = 0
        end
    end)
end


function Weapon:orient(dir)
    self.sprite.rotation = angleBetween({ 1, 0 }, dir)     
end



function Weapon:attemptAttack(dir, t, w, owner)

    local hits = {}

    self.sprite.x = dir[1] + owner.x
    self.sprite.y = dir[2] + owner.y

    self:orient(dir)

    local ihat = dir
    local jhat = rotateHalfPi(dir)

    local dirs = {}

    for i = 1, #self.pattern do

        local dir = dot(self.pattern[i], ihat, jhat)
        
        local x, y = owner.x + dir[1], owner.y + dir[2]

        if         
            -- not out of bounds
            x <= #w.entities_grid and
            x > 0 and 
            y <= #w.entities_grid[x] and
            y > 0 and
            -- there is somebody
            w.entities_grid[x][y] and 
            w.entities_grid[x][y] ~= owner 
        
        then

            local att = owner:getAttack():setDir(dir)

            local obj = {
                enemy = w.entities_grid[x][y],
                attack = att,
                pattern = self.pattern[i],
                t = t,
                owner = owner,
                w = w
            }

            self:modify(obj)
            
            self:attack(obj)
            

            if not self.hit_all then
                t:set('hit')
                return { w.entities_grid[x][y] }
            else
                table.insert(hits, w.entities_grid[x][y])
            end
        end
    end

    if #hits > 0 then 
        t:set('hit')
        return hits
    end

    return false
end

function Weapon:modify()
end

function Weapon:attack(obj)
    obj.enemy:takeHit(obj.attack, obj.w)
end

function Weapon:playAudio()
    audio.play(self.audio['swipe'])
end

function Weapon:play_animation(t)
    self:anim(t, 'swipe')
end

return Weapon