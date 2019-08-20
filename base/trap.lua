local Displayable = require('base.displayable')
local Entity = require('base.entity')
local Action = require('logic.action')
local Stats = require('logic.stats')

local Trap = class('Trap', Entity)

Trap.zIndex = 3
Trap.offset = vec(0, 0)
Trap.socket_type = 'tile'

function Trap:__construct(...)
    Displayable.__construct(self, ...)
    self.pushed = false
    self.subject = false
    self.sprite_pushed = self:createImage(2, UNIT, UNIT)
    self.sprite_pushed.alpha = 0
    self.sprite_unpushed = self:createImage(1, UNIT, UNIT)
end

function Trap:act()
    local x, y = self.pos:comps()
    local cell = self.world.grid[x][y]
    local entity = cell.entity

    if entity and entity ~= self.subject then

        entity:untilTrue('displaced',

            function(_, expected_turn)

                -- make sure the entity moved off
                if entity ~= cell.entity then
                    -- reset the state
                    self.subject = false
                    self.pushed = false

                    -- bind event to animation
                    entity:untilTrue('animation',

                        function(animation_event, current_turn)

                            -- when the expected turn comes in, swap our image
                            if
                                animation_event == 'step:complete' and
                                expected_turn == current_turn
                            then
                                self:swapImage({ pushed = false })
                                self:playAudio('unpushed')
                                return true
                            end

                        end)

                    -- let the lib know we want to unbind this event
                    return true
                end
            end)



        local last_turn = entity.hist:getLast()

        entity:untilTrue('animation',

            function(animation_event, current_turn)

                if
                    animation_event == 'step:complete' and
                    current_turn == last_turn
                then
                    self:swapImage({ pushed = true })
                    self:playAudio('pushed')
                    return true
                end

            end)

        self.subject = entity
        self.pushed = true
        self.moved = true
    end


end

function Trap:playAnimation(cb)

    if self.dead then
        self:_die()
    end

    cb()

end

function Trap:tick() end
function Trap:reset() self.moved = false end

function Trap:swapImage(tab)
    local before = tab.pushed and 'unpushed' or 'pushed'
    local after = tab.pushed and 'pushed' or 'unpushed'
    printf('%s is swapping image from %s to %s', class.name(self), before, after)
    if tab.pushed == true then
        self.sprite.alpha = 0
        self.sprite = self.sprite_pushed
        self.sprite.alpha = 1

    elseif tab.pushed == false then
        self.sprite.alpha = 0
        self.sprite = self.sprite_unpushed
        self.sprite.alpha = 1
    end
end


function Trap:toFront()
    self.sprite_pushed:toFront()
    self.sprite_unpushed:toFront()
end

function Trap:_die()
    self.sprite_pushed:removeSelf()
    self.sprite_unpushed:removeSelf()
end

-- TODO: make this at least as generic as in Entity
function Trap:die()
    self.world:removeFromGrid(self)
    self.dead = true
end

return Trap

