
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
ins = require('inspect')

UNIT = 64

table.unpack = unpack

require('classes_util')
require('tile')
require('player')
require('enemies.enemy')
require('enemies.wizzrobe')
require('game_controller')
require('weapons.dagger')


local tiles
local entities



function scene:create( event )

    -- render pixel graphics correctly
    display.setDefault('magTextureFilter', 'nearest')
    display.setDefault('minTextureFilter', 'nearest')

    -- initialize groups
    local sceneGroup = self.view
    local followGroup = display.newGroup(sceneGroup)
    local tileGroup = display.newGroup(followGroup)
    local playerGroup = display.newGroup(followGroup)
    
    Entity.group = tileGroup

    local dagger = Dagger:new(
        {
            options = {
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
        }        
    )
    dagger:createSprite()

    -- init player
    Player.group = playerGroup
    local player = Player:new({
            x = 1,
            y = 1,
            follow_group = tileGroup,
            weapon = dagger,
            options = -- options list
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
        }     
    )
    player:createSprite()


    

    -- set up tiles
    Tile.group = tileGroup
    Tile:loadSheet(
        '/assets/image_sheets/floor.png', 
        {
            width = 16,
            height = 16, 
            numFrames = 11
        }
    )
    -- display sprites of right size
    tileGroup:scale(UNIT, UNIT) 


    -- Initialize tiles 
    local field_width, field_height = 10, 10

    local tiles = {}
    local walls = {}
    local environment = {}
    local enemGrid = {}

    for i = 1, field_width do
        tiles[i] = {}
        walls[i] = {}
        environment[i] = {}
        enemGrid[i] = {}
        
        for j = 1, field_height do        
            tiles[i][j] = Tile:new{ x = i, y = j, type = math.random(11) }
            tiles[i][j]:createSprite()

            walls[i][j] = false
            environment[i][j] = false
            enemGrid[i][j] = false
        end
    end
    
    tileGroup.x, tileGroup.y =
        -player.x * UNIT + display.contentCenterX,
        -player.y * UNIT + display.contentCenterY

    local enemList = {}

    local wizzrobe = Wizzrobe:new{
        x = 2,
        y = 2,
            options = {
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
        }

    wizzrobe:createSprite()

    table.insert(enemList, wizzrobe)
    enemGrid[wizzrobe.x][wizzrobe.y] = wizzrobe

    for i = 1, 10 do
        local x, y = 1 + math.random(8), 1 + math.random(8)
        local w = Wizzrobe:new{
            x = x,
            y = y
        }
        table.insert(enemList, w)
        enemGrid[x][y] = w
        w:createSprite()
    end

    

    table.sort(enemList, function(a, b) return a.y < b.y end)

    for i = 1, #enemList do
        enemList[i].sprite:toFront()
    end

    controller = Controller:new{
        enemList = enemList,
        enemGrid = enemGrid,
        player = player,
        walls = walls,
        tiles = tiles,
        environment = environment,
        follow_group = tileGroup,
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

        -- dagger:prepareAnimation(act, 5, 5, controller)

        if #controller.loop_queue == 0 and not controller.doing_loop then
            controller:do_loop(act)
        else    
            table.insert(controller.loop_queue, act)
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