
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
ins = require('lib.inspect')
Emitter = require('lib.emitter')
Luaoop = require('lib.Luaoop')
class = Luaoop.class
Vec = require('lib.vec')
require('lib.utils')
Event = require('lib.chains.event')
Chain = require('lib.chains.schain')

function scene:create( event )
    
    require("game.tests.weapontest")()


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