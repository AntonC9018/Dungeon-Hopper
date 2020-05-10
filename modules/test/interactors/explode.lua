local AttackAction = require 'logic.action.actions.attack'
local DynamicStats = require 'logic.decorators.dynamicstats'
local StatTypes = DynamicStats.StatTypes
local HowToReturn = require 'logic.decorators.stats.howtoreturn'
local Changes = require 'render.changes'
local Explosion = require 'modules.test.effects.explosion'
local Attack = require 'logic.action.effects.attack'
local Push = require 'logic.action.effects.push'
local Attackable = require 'logic.decorators.attackable'

Attackable.registerAttackSource('Explosion')

-- and explosion too
DynamicStats.registerStat(
    'Explosion',
    { 'explosion', Explosion },
    HowToReturn.EFFECT
)


local explFallback = Explosion()
explFallback.attack = Attack({ 
    damage = 2, 
    pierce = 1, 
    source = 'explosion', 
    power  = 1 
})
explFallback.push = Push({ 
    distance = 1, 
    power  = 1, 
    source = 'explosion' 
})


local explode = {}

-- explode a cell in the world
explode.cell = function(world, pos, dir, expl)

    if expl == nil then
        expl = explFallback
    end

    -- TODO: How to manage game objects rather than entities?
    -- for now, no game objects will have to be drawn
    -- world.renderer:addRenderEntity()
    local action = AttackAction()
    action:setDirection(dir)
    action.attack = expl.attack
    action.push = expl.push

    -- apply attack to all objects of the cell that
    -- are vulnerable to explosions
    local entities = world.grid:getAllAt(pos)

    for _, entity in ipairs(entities) do
        entity:beAttacked(action)
        entity:bePushed(action)
    end

end

-- explode multiple cells in the world
explode.radius = function(world, pos, expl)
    
    if expl == nil then
        expl = explFallback
    end

    -- instantiate explosions all around the pos
    -- TODO: this contains a bug. must start from the outer edges
    for i = -expl.radius, expl.radius do
        for j = -expl.radius, expl.radius do
            local offset = Vec(i, j)
            local dir = offset:normComps()
            local expl = explode.cell(world, pos + offset, dir, expl)
        end
    end
end


return explode