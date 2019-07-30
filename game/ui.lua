local widget = require('widget')

local UI = class('UI')

function UI:__construct(g)
    self.group = g
    self.emitter = Emitter:new()
end


function UI:ev(p)
    self.emitter:emit('click', p)
end


function UI:initControls()
    -- local arc = conf.arrowRight
    -- local ar = display.newRect(self.group, arc.pos.x, arc.pos.y, arc.s, arc.s)
    -- ar.fill = { 1, 1, 1}
    -- local ar = display.newImageRect(self.group, arc.path, arc.s, arc.s)

    local w = display.safeActualContentWidth / 16
    local p = {
        shape = "rect",
        width = w,
        height = w,
        fillColor = { default={ 1, 0.2, 0.5, 0.7 }, over={ 1, 0.2, 0.5, 1 } },
        strokeWidth = 1,
        strokeColor = { default = { 0, 0, 0 }, over = { 0.5, 0.5, 0.5 } }
    }

    local a = {
        {
            x = display.safeScreenOriginX + w,
            y = display.contentCenterY,
            label = "←", 
            onPress = function() self:ev({ -1, 0 }) end
        },
        {
            x = display.safeScreenOriginX + w,
            y = display.contentCenterY - w,        
            label = "↑",
            onPress = function() self:ev({ 0, -1 }) end
        },
        {
            x = display.safeScreenOriginX + w,
            y = display.contentCenterY + w,
            label = "↓",
            onPress = function() self:ev({ 0, 1 }) end
        },
        {
            x = display.safeActualContentWidth - w,
            y = display.contentCenterY,
            label = "→",
            onPress = function() self:ev({ 1, 0 }) end
        },
        {
            x = display.safeActualContentWidth - w,
            y = display.contentCenterY - w,
            label = "↑",
            onPress = function() self:ev({ 0, -1 }) end
        },
        {
            x = display.safeActualContentWidth - w,
            y = display.contentCenterY + w,
            label = "↓",
            onPress = function() self:ev({ 0, 1 }) end
        }
    }

    for i = 1, #a do
        widget.newButton(merge(a, p))
    end
end

return UI