Weapon = Animated:new{
    run_and_gun = false,
    hit_all = true
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

    if          dir[1] ==  1 then self.sprite.rotation = 0
       elseif   dir[2] ==  1 then self.sprite.rotation = 90
       elseif   dir[1] == -1 then self.sprite.rotation = 180
       elseif   dir[2] == -1 then self.sprite.rotation = 270 
       else self.sprite.rotation = 0 end       
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

            local att = owner:getAttack()

            self:modify(att, self.pattern[i], dir, owner)
            
            self:attack(w.entities_grid[x][y], att, self.pattern[i], dir, owner)
            

            if not self.hit_all then
                t:setResult('hit')
                return w.entities_grid[x][y]
            else
                table.insert(hits, w.entities_grid[x][y])
            end
        end
    end

    if #hits > 0 then 
        t:setResult('hit')
        return hits
    end

    return false
end

function Weapon:modify()
end

function Weapon:attack(en, att)
    en:takeHit(att)
end

function Weapon:playAudio()
    audio.play(self.audio['swipe'])
end

function Weapon:play_animation(t)
    self:anim(t, 'swipe')
end
