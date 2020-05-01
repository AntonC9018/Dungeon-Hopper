local Spear = require 'modules.test.spear' 
local Weapon = require 'items.weapons.weapon'
local Crate = require 'modules.test.crate'
local Player = require 'logic.base.player'

return function()

    local World = require('world.world')

    local assets = require('render.assets')()
    local renderer = require('render.renderer')(assets)
    
    local world = World(renderer, 10, 10)
    world:addGameObjectType(Crate)
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
    local player = world:createPlayerAt( Vec(2, 2) )
    local crate = world:create( Crate, Vec(2, 4) )
    
    local knife = Weapon()
    local spear = Spear()

    player.weapon = spear

    local actions = {
        Vec(0, 1),
        Vec(0, 1)
    }

    local count = 1

    timer.performWithDelay( 
        1000, 
        function()
            local time = system.getTimer()
            world:setPlayerActions( actions[count], 1 )
            world:gameLoop()
            count = count + 1
            -- print("Attackabless of Mob: "..testEnemy:getAttackableness())
            printf("Time passed: %i", system.getTimer() - time)
            print("-------------- Cycle ended. ---------------")
            
            if count == 3 then
                assert(crate.dead == true)
            end
        end,
        #actions
    )
end