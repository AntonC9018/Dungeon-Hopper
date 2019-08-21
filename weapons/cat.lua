local Weapon = require('base.weapon')

local Cat = class('Cat', Weapon)

Cat.scale = 1 / 24

Cat.att_base = {
    dmg = 1
}

Cat.move_attack = true

Cat.pattern = { vec(1, 0), vec(1, 1), vec(1, -1), vec(0, 1), vec(0, -1) }
Cat.knockb =  { vec(1, 0), vec(1, 1), vec(1, -1), vec(0, 1), vec(0, -1) }
Cat.reach =   { false,     false,     false,      false,     false      }

-- function Dagger:__construct(...)
--     Weapon.__construct(self, {
--         {
--             name = "swipe",
--             start = 1,
--             count = 3,
--             time = 1000,
--             loopCount = 1

--         }
--     }, ...)
-- end

function Cat:getPattern(i, a, t)
    print(i, a, t)
    if t.displaced then
        -- when attacking after having moved
        if i == 1 then
            -- ignore the first pattern
            return false
        else
            -- bring all patterns closer to the attacker
            return self.pattern[i] - vec(1, 0)
        end
    end

    return self.pattern[i]
end


function Cat:attack(params)
    if
        -- if not attacking straight in front
        params.index ~= 1 and
        -- and did not move
        not params.turn.displaced
    then
        -- bump
        params.turn:set('bumped')
    end

    Weapon.attack(self, params)
end

function Cat:isShouldMove(hits)
    for i = 1, #hits do
        if hits[i].index == 1 then
            return false
        else
            return true
        end
    end
end

return Cat