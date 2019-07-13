
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
ins = require('inspect')

UNIT = 64

table.unpack = unpack

function contains(table, val)
    for i = 1, #table do
        if table[i] == val then 
           return true
        end
    end
    return false
end

function sign(x)
  return (x < 0 and -1) or 1
end

require('constants')
require('animated')
require('attack')
require('entity')
require('camera')
require('turn')
require('weapons.weapon')
require('tile')
require('player')
require('enemies.enemy')
require('enemies.wizzrobe')
require('environment.environment')
require('world')
require('weapons.dagger')


local tiles
local entities


function scene:create( event )

    -- render pixel graphics correctly
    display.setDefault('magTextureFilter', 'nearest')
    display.setDefault('minTextureFilter', 'nearest')

    -- initialize groups
    local sceneGroup = self.view
    local entities_group = display.newGroup(sceneGroup)
    
    Animated.group = entities_group

    local dagger = Dagger:new(
        {},
        {
            sheet_path = '/assets/image_sheets/swipes/swipe_dagger.png',
            sheet_options = {
                width = 24,
                height = 24,
                numFrames = 3
            },
            audio = {
                swipe = '/assets/audio/pound.wav'
            }
        }        
    )
    dagger:createSprite()

    -- init player
    Player.group = playerGroup
    local player = Player:new({
            x = 4,
            y = 2,
            group = entities_group,
            camera = Camera:new{},
            items = {}
        },
         -- options list
        {
            sheet_path = '/assets/image_sheets/elf_girl.png',
            sheet_options = {
                width = 16,
                height = 21, 
                numFrames = 9
            },
            audio = {
                hurt = '/assets/audio/roblox.mp3'
            }
        }     
    )
    player:createSprite()
    player:equip(dagger)


    local trap = Trap:new(
        { x = 2, y = 2, group = entities_group },
        {
            sheet_path = 'assets/image_sheets/bounce_trap.png',
            sheet_options = {
                width = 16,
                height = 16,
                numFrames = 2
            },
            audio = {
                bounce = 'assets/audio/spring_bounce.mp3'
            }
        }
    )
    trap:createSprite()

    local trap2 = Trap:new{ x = 3, y = 2, group = entities_group }
    trap2:createSprite()

    
    environment = Environment:new{}

    table.insert(environment.traps, trap)
    table.insert(environment.traps, trap2)

    

    -- set up tiles
    Tile.group = entities_group
    Tile:loadSheet(
        '/assets/image_sheets/floor.png', 
        {
            width = 16,
            height = 16, 
            numFrames = 11
        }
    )
    -- display sprites of right size
    entities_group:scale(UNIT, UNIT) 


    -- Initialize tiles 
    local field_width, field_height = 10, 10

    local tiles = {}
    local walls = {}
    local entities_grid = {}

    for i = 1, field_width do
        tiles[i] = {}
        walls[i] = {}
        entities_grid[i] = {}
        
        for j = 1, field_height do        
            tiles[i][j] = Tile:new{ x = i, y = j, type = math.random(11) }
            tiles[i][j]:createSprite()

            walls[i][j] = false
            entities_grid[i][j] = false
        end
    end
    
    entities_group.x, entities_group.y =
        -player.x * UNIT + display.contentCenterX,
        -player.y * UNIT + display.contentCenterY

    local entities_list = {}

    table.insert(entities_list, player)


    local wizzrobe = Wizzrobe:new({
            x = 1,
            y = 2,
        },
        {
            sheet_path = '/assets/image_sheets/wizzrobe.png',
            sheet_options = {
                width = 16,
                height = 17, 
                numFrames = 5
            },
            audio = {
                hurt = '/assets/audio/roblox.mp3'
            }
        }
    )

    wizzrobe:createSprite()

    table.insert(entities_list, wizzrobe)
    entities_grid[wizzrobe.x][wizzrobe.y] = wizzrobe

    for i = 1, 0  do
        local x, y = 1 + math.random(field_width - 2), 1 + math.random(field_height - 2)
        local w = Wizzrobe:new{
            x = x,
            y = y
        }
        table.insert(entities_list, w)
        entities_grid[x][y] = w
        w:createSprite()
    end

    

    table.sort(entities_list, function(a, b) return a.y < b.y end)

    for i = 1, #entities_list do
        entities_list[i].sprite:toFront()
    end

    world = World:new{
        entities_list = entities_list,
        entities_grid = entities_grid,
        player = player,
        walls = walls,
        tiles = tiles,
        environment = environment,
        follow_group = entities_group,
        ignore = false
    }


    first_input = true


    Runtime:addEventListener("tap", function(event)
        
        if first_input then first_input = false return end

        local _w, _h = display.contentWidth, display.contentHeight
        local w, h = display.viewableContentWidth, display.viewableContentHeight
        
        local x = event.x - (_w - w) / 2
        local y = event.y - (_h - h) / 2

        local ratio = h / w


        local function f(x)
            return ratio * x
        end

        local function g(x)
            return -ratio * x + h
        end

        local function fInv(y)
            return 1 / ratio * y
        end

        local function gInv(y)
            return 1 / ratio * (h - y)
        end

        local side
        
        if x < w / 2 and y > f(x) and y < g(x) then side = 1 
        elseif x > w / 2 and y < f(x) and y > g(x) then side = 2
        elseif y < h / 2 and x < gInv(y) and x > fInv(y) then side = 3 
        elseif y > h / 2 and x > gInv(y) and x < fInv(y) then side = 4 end


        local act = { 
            (side == 1 and -1) or (side == 2 and 1) or 0, 
            (side == 3 and -1) or (side == 4 and 1) or 0 
        }

        if #world.loop_queue == 0 and not world.doing_loop then
            world:do_loop(act)
        else    
            table.insert(world.loop_queue, act)
        end
    
    end)

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene