local composer = require('composer')

local scene = composer.newScene()

function scene:create(event)

    local sceneGroup = self.view

    local background = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
    background:setFillColor(1, 1, 1)

    local start = display.newText(sceneGroup, 'Start', display.contentCenterX, display.contentCenterY, native.systemFont, 80)
    start:setFillColor(0)

    composer.gotoScene('game.game')
    -- start:addEventListener('tap',
    --     function(event)
    --     end
    -- )



end

scene:addEventListener( "create", scene )

return scene