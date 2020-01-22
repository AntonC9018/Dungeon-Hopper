local HPContainer = require "container"

local HP = class('HP')

local HEART_SIZE = 2

-- for now I'll keep it simple. health is a number
function HP:__construct(health)
    self.containers = {}

    local i = health

    while i > 0 do
        local container
        if i > HEART_SIZE then
            container = HPContainer(HEART_SIZE)
        else
            container = HPContainer(i)
        end
        table.insert(self.containers, container)
        i = i - HEART_SIZE
    end
end


function HP:takeDamage(amount)
    local i = #self.containers
    
    while damage > 0 do
        if self.containers[i].amount ~= 0 then
            
            local previousAmount 
            
            if damage > self.container[i].amount then
                previousAmount = self.container[i].amount
                self.container[i].amount = 0
            else
                previousAmount = damage
                self.container[i].amount =
                    self.container[i].amount - damage
            end

            damage = damage - previousAmount
            i = i - 1
            if i <= 0 then return damage end
        end
    end

    return 0
end


-- TODO: implement
function HP:heal(amount)
end


function HP:get()
    local health = 0
    for i = 1, #self.containers do
        health = health + self.containers[i].amount
    end
    return health
end


return HP