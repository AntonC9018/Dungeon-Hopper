
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
ins = require('inspect')
Emitter = require('events')
local json = require('json')

assets = json.decodeFile(system.pathForFile('configs/assets.json', system.ResourceDirectory ))


for k, v in pairs(assets) do
    if v.sheet then
        assets[k].sheet.path = '/assets/image_sheets/'..v.sheet.path
    end

    if v.audio then
        for _k, _v in pairs(v.audio) do
            assets[k].audio[_k] = '/assets/audio/'.._v
        end
    end
end


require('constants')
require('utils')


function scene:create( event )

    -- render pixel graphics correctly
    display.setDefault('magTextureFilter', 'nearest')
    display.setDefault('minTextureFilter', 'nearest')

    local BounceTrap = require('environment.bounceTrap')
    local World = require('world')

    -- initialize groups
    local sceneGroup = self.view
    local world_group = display.newGroup(sceneGroup)
    
    -- display sprites of right size
    world_group:scale(UNIT, UNIT) 

    local world = World:new(
        { 
            group = world_group, 
            width = 18, 
            height = 18 
        }
    )
    -- create the player
    world:initPlayer({ x = 4, y = 4 })
    -- spawn 5 wizzrobes
    world:populate(5)


    local trap = BounceTrap:new(
        { 
            x = 4, 
            y = 4, 
            world = world
        }
    )

    table.insert(world.environment.traps, trap)

    
    world_group.x, world_group.y =
        -world.player.x * UNIT + display.contentCenterX,
        -world.player.y * UNIT + display.contentCenterY


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