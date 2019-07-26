local Animated = require('animated')

local Weapon = Animated:new{
    -- move, then attack
    move_attack = false,
    -- attack, then move
    attack_move = false,
    hit_all = false,
    frail = false,

    weapon = true
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


function Weapon:orient(dir, pattern)
    self.sprite.rotation = angleBetween({ 1, 0 }, dir) / math.pi * 180    
end



function Weapon:attemptAttack(dir, t, w, owner)

    local hits = {}
    local blocked = {}
    local objectsToHit = {}

    self.sprite.x = dir[1] + owner.x
    self.sprite.y = dir[2] + owner.y

    self:adaptToSize(dir, owner.size)

    local ihat = dir
    local jhat = rotateHalfPi(dir)

    local dirs = {}

    for i = 1, #self.pattern do

        local dir = dot(self.pattern[i], ihat, jhat)
        local knockb_dir = self.knockb and dot(self.knockb[i], ihat, jhat) or dir

        local ps = patternDirToPoints(dir, owner, w)

        for j = 1, #ps do

            local x, y = ps[j][1], ps[j][2]

            if         
                -- there is somebody
                w.entities_grid[x][y] and 
                w.entities_grid[x][y] ~= owner and
                -- can reach to it without meeting a block
                self:canReach(i, blocked, owner, w)
            
            then

                local att = owner:getAttack():setDir(knockb_dir)

                local obj = {
                    enemy = w.entities_grid[x][y],
                    attack = att,
                    dir = dir,
                    pattern = self.pattern[i],
                    t = t,
                    owner = owner,
                    w = w,
                    i = i
                }

                self:modify(obj)
                
                if 
                    -- if attacking a crate/barrel/jug
                    obj.enemy:isObject() and not (
                        -- attacking it straight
                        ((dir[1] == 0 and math.abs(dir[2]) > 0) or 
                        (math.abs(dir[1]) > 0 and dir[2] == 0)) and
                        -- standing right next to it
                        owner:isClose(obj.enemy)
                    )
                then
                    table.insert(objectsToHit, obj)
                else
                    self:orient(dir, self.pattern[i])
                    self:attack(obj)
                    table.insert(hits, w.entities_grid[x][y])
                    t:set('hit')
                end 
            end

            if blocked[i] == nil then
                blocked[i] = false
            end

            blocked[i] = 
                (blocked[i] or
                (w.walls[x][y] or 
                (w.entities_grid[x][y] and 
                 w.entities_grid[x][y]:isObject()) or false)) and true
        end

        if not self.hit_all and t.hit then
            return hits
        end

    end

    if #hits > 0 then 
        t:set('hit')
        for i = 1, #objectsToHit do
            self:attack(objectsToHit[i])
        end
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

function Weapon:playAnimation(t)
    self:anim(t, 'swipe')
end

function Weapon:adaptToSize(dir, size)
    if 
        math.abs(dir[1]) > 0 and dir[2] == 0
    then    
        self.sprite.y = self.sprite.y + size[2] / 2
    end

    if 
        math.abs(dir[2]) > 0 and dir[1] == 0
    then    
        self.sprite.x = self.sprite.x + size[1] / 2
    end

end

function Weapon:canReach(i, b)
    if not self.reach or (self.reach and not self.reach[i]) then return true end
    return not b[self.reach[i]]
end

return Weapon