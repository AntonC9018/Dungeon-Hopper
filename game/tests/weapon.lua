local TestEnemy = require 'modules.test.entities.enemytest' 
local StatTypes = require('logic.decorators.dynamicstats').StatTypes
local Projectile = require 'modules.test.entities.projectile'
local BounceTrap = require 'modules.test.entities.bouncetrap'
local Joe = require 'modules.test.entities.joe'
local Input = require 'game.input'

local ItemTable = require 'items.itemtable'
local spear = require 'modules.test.items.spear'
ItemTable.registerItem(spear)

return function()

    local World = require('world.world')

    local assets = require('render.assets')()
    local renderer = require('render.renderer')(assets)
    
    local world = World(renderer, 20, 20)
    world:addGameObjectType(Projectile)
    world:addGameObjectType(TestEnemy)
    world:addGameObjectType(Joe)
    world:addGameObjectType(BounceTrap) 
    world:registerTypes(assets)


    -- load all assets
    assets:loadAll()

    Runtime:addEventListener( 
        "enterFrame",         
        function(event)
            renderer:update(event.time)
        end
    )

    world:createFloors()
    local player = world:createPlayer(Joe, Vec(4, 3))
    local trap = world:create(BounceTrap, Vec(4, 4))
    local enemy = world:create(TestEnemy, Vec(8, 8))
    local droppedSpear = world:createDroppedItem( spear:getItemId(), Vec(5, 5) )
    
    enemy:setStat(StatTypes.Push, 'power', 1)
    player:setStat(StatTypes.PushRes, 'normal', 2)

    Input(world, function()
        print(player.hp:get())
    end)

    -- proj:setStat(StatTypes.Push, 'power', 10)
    -- proj:setStat(StatTypes.Push, 'distance', 1)
end