local Entity = require('base.entity')
local Sequence = require('logic.sequence')
local Action = require('logic.action')
local Turn = require('logic.turn')

local Enemy = class("Enemy", Entity)

Enemy.att_base = {
    dmg = 1,
    pierce = 2
}

Enemy.def_base = {
    push = 2
}

Enemy.weak = true
Enemy.resilient = false
-- Enemy.reach = 1

function Enemy:__construct(...)
    Entity.__construct(self, ...)
    self.moved = false
    self.sees = true
    self.seq = Sequence(self)
end


function Enemy:getAction(player_action)
    if not self.cur_actions then
        self:computeAction(player_action)
    end
    return self.cur_actions
end


function Enemy:computeAction(player_actions)
    local actions = {}   
    local movs = {} 

    local mov = self.seq:mov()
    local pp, sp = self.world.player.pos, self.pos

    if not mov then 
        self.cur_actions = actions

    -- got a custom table of actions
    elseif mov == 'table' then
        movs = mov
        
    
    -- Basic orthogonal movement
    elseif mov == "basic" then
        local gx, gy = pp.x > sp.x, pp.y > sp.y
        local lx, ly = sp.x > pp.x, sp.y > pp.y


        -- So this is basically if-you-look-to-the-left,- 
        -- you-would-prefer-to-go-to-the-left action

        if self.facing.x > 0 then -- looking right
            -- prioritize going to the right
            if gx then table.insert(movs, vec(  1,  0 )) end
            if gy then table.insert(movs, vec(  0,  1 )) end
            if ly then table.insert(movs, vec(  0, -1 )) end
            if lx then table.insert(movs, vec( -1,  0 )) end
        elseif self.facing.x < 0 then -- looking left
            -- prioritize going to the left
            if lx then table.insert(movs, vec( -1,  0 )) end
            if gy then table.insert(movs, vec(  0,  1 )) end
            if ly then table.insert(movs, vec(  0, -1 )) end
            if gx then table.insert(movs, vec(  1,  0 )) end
        elseif self.facing.y > 0 then -- looking down
            --- ...
            if gy then table.insert(movs, vec(  0,  1 )) end
            if gx then table.insert(movs, vec(  1,  0 )) end
            if lx then table.insert(movs, vec( -1,  0 )) end
            if ly then table.insert(movs, vec(  0, -1 )) end
        elseif self.facing.y < 0 then -- looking up
            --- ...
            if ly then table.insert(movs, vec(  0, -1 )) end
            if gx then table.insert(movs, vec(  1,  0 )) end
            if lx then table.insert(movs, vec( -1,  0 )) end
            if gy then table.insert(movs, vec(  0,  1 )) end
        else -- no direction. Default order!
            -- ...
            if gx then table.insert(movs, vec(  1,  0 )) end
            if lx then table.insert(movs, vec( -1,  0 )) end
            if gy then table.insert(movs, vec(  0,  1 )) end
            if ly then table.insert(movs, vec(  0, -1 )) end
        end

    
    elseif mov == "diagonal" then

        local gx, gy = pp.x > sp.x, pp.y > sp.y
        local lx, ly = sp.x > pp.x, sp.y > pp.y

        -- to the left of the player
        if gx then
            if     gy then table.insert(movs,vec( 1,  1 )) 
            elseif ly then table.insert(movs,vec( 1, -1 ))
            else
                -- we're on one X with the player 
                if self.facing.y > 0 then
                    table.insert(movs, vec( 1,  1 ))
                    table.insert(movs, vec( 1, -1 ))
                else
                    table.insert(movs, vec( 1, -1 ))
                    table.insert(movs, vec( 1,  1 ))
                end
            end

        -- to the right of the player
        elseif lx then
            if     gy then table.insert(movs, vec( -1,  1 )) 
            elseif ly then table.insert(movs, vec( -1, -1 ))
            else
                -- we're on one X with the player
                if self.facing.y > 0 then
                    table.insert(movs, vec( -1,  1 ))
                    table.insert(movs, vec( -1, -1 ))
                else
                    table.insert(movs, vec( -1, -1 ))
                    table.insert(movs, vec( -1,  1 ))
                end
            end

        -- on one Y with the player
        -- higher than the player
        elseif gy then
            if self.facing.x > 0 then
                table.insert(movs, vec( -1,  1 ))
                table.insert(movs, vec(  1,  1 ))
            else
                table.insert(movs, vec(  1,  1 ))
                table.insert(movs, vec( -1,  1 ))
            end 

        -- lower than the player
        else
            if self.facing.x > 0 then
                table.insert(movs, vec( -1, -1 ))
                table.insert(movs, vec(  1, -1 ))
            else
                table.insert(movs, vec(  1, -1 ))
                table.insert(movs, vec( -1, -1 ))
            end 
        end


    elseif mov == "adjacent" then

        local gx, gy = pp.x > sp.x, pp.y > sp.y
        local lx, ly = sp.x > pp.x, sp.y > pp.y

        if gx then
            if gy then  table.insert(movs, vec(  1,  1 )) table.insert(movs, vec( 0,  1 )) end
            if ly then  table.insert(movs, vec(  1, -1 )) table.insert(movs, vec( 0, -1 )) end
                        table.insert(movs, vec(  1,  0 ))
        elseif lx then
            if gy then  table.insert(movs, vec( -1,  1 )) table.insert(movs, vec( 0,  1 )) end
            if ly then  table.insert(movs, vec( -1, -1 )) table.insert(movs, vec( 0, -1 )) end
                        table.insert(movs, vec( -1,  0 ))
        
        -- on one X with the player
        else
            table.insert(movs, { 0, gy and 1 or -1 })
        end

    -- please don't use these random ones. These would be very obnoxious to deal with
    -- at least make the enemies point in the direction they are going to move
    -- like bats in CoH as opposed to the bats of CotND
    elseif mov == "basic-random" then
        local x = math.random(0, 1) * 2 - 1
        local i = math.random(1, 2)
        local t = { 0, 0 }
        t[i] = x
        table.insert(movs, vec( t[1], t[2] ))
    
    elseif mov == "diagonal-random" then
        table.insert(movs, vec(math.random(0, 1) * 2 - 1, math.random(0, 1) * 2 - 1))


    elseif mov == "adjacent-random" then
        table.insert(movs, vec(math.random(-1, 1), math.random(-1, 1)))


    -- move continuously in a straight line
    elseif mov == "straight" then
        table.insert(movs, self.facing)
    end

    
    if #movs > 0 then 
        actions = Action.toActions(self, self.seq:step().name, #movs)            
        Action.eachBoth(actions, 'setDir', movs)
        Action.each    (actions, 'setAtt', self:getAttack())
        Action.each    (actions, 'setAms', self:getAms())
    else
        actions = { Action(self, 'idle') }
    end

    self.cur_actions = actions
end


function Enemy:act(player_action)
    if self.moved then return end

    self.doing_action = true

    if not self.sees then
        self.moved = true
        return
    end
    
    local s = self.seq:step()
    local M, A = s:is('move'), s:is('attack')    

    local acts = self:getAction(player_action)
    local resps = {}    

    -- A check over one position
    local function posIter(a, p)
        local x, y = p:comps()
        local cell = self.world.grid[x][y]

        -- TODO: add user-defined checks

        if cell.wall then
            local d = a.att - cell.wall.def

            if d and d.dig then
                return 'dig'
            
            elseif M then
                return 'block'
            end
        
        elseif cell.entity then

            -- if attacking, attack
            if cell.entity == self.world.player then

                if A then
                    return 'player'
                
                -- if moving, bump
                elseif M then
                    return 'block'
                end

            -- elseif A and 

            -- free way
            elseif M and cell.entity.dead then
                return 'free'

            -- redo the iteration
            elseif 
                M and 
                cell.entity.moved == false and not
                cell.entity.doing_action 
            then
                return false

            -- attack empty space
            elseif A and not M then
                return 'free'


            elseif M then
                return 'block'
            end
        
        -- free way
        elseif M then
            return 'free'
        end
    end

    -- A check over one action
    local function doIter(i)
        local a = acts[i]
        if not a then return false end
        if not a.dir then return doIter(i + 1) end

        local ps = self:getPointsFromDirection(a.dir)
        local rs = {}

        for j = 1, #ps do
            rs[j] = posIter(a, ps[i])
            if rs[j] == false then
                return doIter(i)
            end
        end

        local function set(v)
            resps[i] = v
            doIter(i + 1)
        end

        local function _set(v)
            self:doAction(a, v)
            return true
        end

        if table.all (rs, 'dig')   then return  set('dig')   end
        if table.all (rs, 'free')  then return _set('free')   end
        if table.some(rs, 'block') then return  set('block') end
        if table.some(rs, 'enemy') then return  set('enemy') end
        if table.some(rs, 'player')then return _set('player')end
        return set(rs[1])
    end


    local r = doIter(1)

    if not r then
        self:doAction(acts[1], resps[1])
    end

end


function Enemy:doAction(a, r)
    self.moved = true

    -- get the sequence step
    local s = self.seq:step()

    -- create the turn
    local t = Turn(a, self)

    local M, A, I = s:is('move'), s:is('attack'), s:is('idle')


    if not t._in then

        if M then

            -- Free way, just move
            if r == 'free' then 
                self:go(a.dir, t)
            
            -- bump
            elseif r == 'enemy' or r == 'block' then
                self.facing = a.dir
                t:set('bumped')
            
            -- go out --TODO
            elseif r == 'stuck' then
                if self.stuck then
                    -- signalize the stuck causer (a water tile)
                    -- to let the player out
                    self.stuck:getOut()
                    t:set('stuck')
                    A = false I = false
                end
            end
        end

        if A then

            -- damage the player
            if r == 'player' then
                self.world.player:takeHit(a)
                self.facing = a.dir
                t:set('hit')
            end

        end

        if I then
            
            t:set('idle')

        end

    end   

    
    
    -- TODO: refactor
    self.close = self:isClose(self.world.player)
    self.close_diagonal = self:isCloseDiagonal(self.world.player)
    
    
    -- reorient to the player if necessary
    -- TODO: REFACTOR!!!
    if s.reorient then
        self:orientTo(self.world.player)
    elseif s.p_close and self.close and s.p_close.reorient then
        self:orientTo(self.world.player)
    end
    
    -- save the turn in the history
    t:apply()

end


function Enemy:reset()
    Entity.reset(self)
    self.cur_actions = false
    self.doing_loop = false
end

function Enemy:tick()
    self.seq:tick()
    Entity.tick(self)
end

-- change the facing to the player if not facing them already
function Enemy:orientTo(p)

    if self.facing.x > 0 and p.pos.x > self.pos.x or
       self.facing.x < 0 and p.pos.x < self.pos.x or
       self.facing.y > 0 and p.pos.y > self.pos.y or
       self.facing.y < 0 and p.pos.y < self.pos.y then return end

    if     p.pos.x > self.pos.x then self.facing = vec( 1,  0)
    elseif p.pos.x < self.pos.x then self.facing = vec(-1,  0)
    elseif p.pos.y > self.pos.y then self.facing = vec( 0,  1)
    elseif p.pos.y < self.pos.y then self.facing = vec( 0, -1)

    -- TODO: give it a random val when no player is around 
    else   self.facing = vec(0, 0) end
end


function Enemy:bumpLoop()
    if 
        -- if was preparing to attack
        self.seq:is('attack') and 
        -- but has bumped into an enemy
        self.hist:was('bumped') and
        -- hasn't attacked or bounced
        not self.hist:wasAny('hit', 'bounced')
    then
        -- TODO: Refactor this animation thing
        if self.close then
            self:anim(1000, "angry") 
        else
            self:anim(1000, "ready") 
        end        
        return true
    end
    return false
end

return Enemy