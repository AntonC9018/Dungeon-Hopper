
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
ins = require('lib.inspect')
Emitter = require('lib.events')
Luaoop = require('lib.Luaoop')
class = Luaoop.class
AM = require('game.assets')
AM:loadAssets()
vec = require('lib.vec')
require('constants')
require('lib.utils')


function scene:create( event )

    -- local BounceTrap = require('environment.bounceTrap')
    local World = require('game.world')
    local UI = require('game.ui')
    
    -- initialize groups
    local sceneGroup = self.view
    local world_group = display.newGroup()
    
    -- display sprites of right size
    world_group:scale(SCALE, SCALE) 

    local world = World(15, 15, world_group)
    -- create the player
    world:initPlayer(7, 7)
    -- spawn some wizzrobes
    world:populate(1)


    -- local trap = BounceTrap:new(
    --     { 
    --         x = 4, 
    --         y = 4, 
    --         world = world
    --     }
    -- )

    -- table.insert(world.env.traps, trap)

    
    world_group.x, world_group.y =
        -world.player.pos.x * UNIT + display.contentCenterX,
        -world.player.pos.y * UNIT + display.contentCenterY

    local ui = UI(display.newGroup())

    ui:initControls()

    ui.emitter:on('click', function(p) 

        p = vec(p[1], p[2])

        if #world.loop_queue == 0 and not world.doing_loop then
            world:do_loop(p)
        else    
            table.insert(world.loop_queue, p)
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