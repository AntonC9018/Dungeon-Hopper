local Spear = require 'modules.test.spear' 
local Weapon = require 'items.weapons.weapon'
local Player = require 'logic.base.player'
local TestEnemy = require 'modules.test.enemytest'

return function()

    local World = require('world.world')

    local assets = require('render.assets')()
    local renderer = require('render.renderer')(assets)
    
    local world = World(renderer, 10, 10)
    world:addGameObjectType(TestEnemy)
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


    local Tinker = require 'logic.tinkers.tinker'
    local Move = require 'logic.tinkers.components.move'
    local StatTinker = require 'logic.tinkers.stattinker'
    local utils = require 'logic.tinkers.utils'
    local StatTypes = require('logic.decorators.dynamicstats').StatTypes
    local Stats = require 'logic.stats.stats'

    local statTinker = StatTinker({
        { StatTypes.Move, 'distance', 1 }
    })

    statTinker:tink(player)

    world:setPlayerActions( Vec(1, 0), 1 )
    world:gameLoop()

    assert(player.pos.x == 4)


    statTinker:untink(player)

    world:setPlayerActions( Vec(1, 0), 1 )
    world:gameLoop()

    assert(player.pos.x == 5)


    statTinker = StatTinker({
        { StatTypes.Attack, Stats.fromTable{ damage = 1, pierce = 1 } }
    })

    player:setStat(StatTypes.Attack, 'damage', 2)
    player:setStat(StatTypes.Attack, 'pierce', 2)

    statTinker:tink(player)

    local attack = player:getStat(StatTypes.Attack)

    assert(attack.damage == 3 and attack.pierce == 3)

    statTinker:untink(player)
    

    local tinker = Tinker{
        Move.afterAttack
    }

    tinker:tink(player)
    
    local enemy = world:create( TestEnemy, Vec(6, 2) )
    enemy:setStat(StatTypes.AttackRes, Stats{ armor = 0, pierce = 0 })
    local hp = enemy.hp:get()

    world:setPlayerActions( Vec(1, 0), 1 )
    world:gameLoop()        

    assert(hp - enemy.hp:get() == 2)
    assert(player.pos.x == 6)


    local function generator(tinker)
        return function(event)
            print("hello")
            tinker.untink()
        end
    end

    tinker = utils.SelfUntinkingTinker(player, 'move', generator)

    tinker.tink()   -- the function output by generator gets onto the chain

    world:setPlayerActions( Vec(0, 1), 1 )
    world:gameLoop()
    world:setPlayerActions( Vec(0, 1), 1 )
    world:gameLoop()
end