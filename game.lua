
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
    local UI = require('ui')

    -- initialize groups
    local sceneGroup = self.view
    local world_group = display.newGroup()
    
    -- display sprites of right size
    world_group:scale(UNIT, UNIT) 

    local world = World:new(
        { 
            group = world_group, 
            width = 15, 
            height = 15 
        }
    )
    -- create the player
    world:initPlayer({ x = 5, y = 5 })
    -- spawn some wizzrobes
    world:populate(5)


    -- local trap = BounceTrap:new(
    --     { 
    --         x = 4, 
    --         y = 4, 
    --         world = world
    --     }
    -- )

    -- table.insert(world.env.traps, trap)

    
    world_group.x, world_group.y =
        -world.player.x * UNIT + display.contentCenterX,
        -world.player.y * UNIT + display.contentCenterY


    first_input = true


    local ui = UI:new({ group = display.newGroup() })

    ui:initControls()

    ui.emitter:on('click', function(p) 
        if #world.loop_queue == 0 and not world.doing_loop then
            world:do_loop(p)
        else    
            table.insert(world.loop_queue, p)
        end
    end)

    Runtime:addEventListener("tap", function(event)

        
    
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