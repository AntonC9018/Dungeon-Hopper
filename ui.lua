local constructor = require('constructor')
local widget = require( "widget" )

local UI = {}

function UI:new(...)
    local o = constructor.new(self, ...)
    o.emitter = Emitter:new()
    return o
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

    -- left button
    widget.newButton({
        x = display.safeScreenOriginX + w,
        y = display.contentCenterY,
        shape = "rect",
        label = "←",
        width = w,
        height = w,
        fillColor = { default={ 1, 0.2, 0.5, 0.7 }, over={ 1, 0.2, 0.5, 1 } },
        strokeWidth = 1,
        strokeColor = { default = { 0, 0, 0 }, over = { 0.5, 0.5, 0.5 } },

        onPress = function() self:ev({ -1, 0 }) end
    })

    -- left up button
    widget.newButton({
        x = display.safeScreenOriginX + w,
        y = display.contentCenterY - w,        
        label = "↑",
        shape = "rect",
        width = w,
        height = w,
        strokeWidth = 1,
        fillColor = { default={ 1, 0.2, 0.5, 0.7 }, over={ 1, 0.2, 0.5, 1 } },
        strokeColor = { default = { 0, 0, 0 }, over = { 0.5, 0.5, 0.5 } },
        onPress = function() self:ev({ 0, -1 }) end
    })

    -- left down button
    widget.newButton({
        x = display.safeScreenOriginX + w,
        y = display.contentCenterY + w,
        label = "↓",
        shape = "rect",
        width = w,
        height = w,
        strokeWidth = 1,
        strokeColor = { default = { 0, 0, 0 }, over = { 0.5, 0.5, 0.5 } },
        fillColor = { default={ 1, 0.2, 0.5, 0.7 }, over={ 1, 0.2, 0.5, 1 } },
        onPress = function() self:ev({ 0, 1 }) end
    })

    -- right button
    widget.newButton({
        x = display.safeActualContentWidth - w,
        y = display.contentCenterY,
        label = "→",
        shape = "rect",
        width = w,
        height = w,
        strokeWidth = 1,
        strokeColor = { default = { 0, 0, 0 }, over = { 0.5, 0.5, 0.5 } },
        fillColor = { default={ 1, 0.2, 0.5, 0.7 }, over={ 1, 0.2, 0.5, 1 } },
        onPress = function() self:ev({ 1, 0 }) end
    })

     -- right up button
    widget.newButton({
        x = display.safeActualContentWidth - w,
        y = display.contentCenterY - w,
        label = "↑",
        shape = "rect",
        width = w,
        height = w,
        strokeWidth = 1,
        strokeColor = { default = { 0, 0, 0 }, over = { 0.5, 0.5, 0.5 } },
        fillColor = { default={ 1, 0.2, 0.5, 0.7 }, over={ 1, 0.2, 0.5, 1 } },
        onPress = function() self:ev({ 0, -1 }) end
    })

     -- right down button
    widget.newButton({
        x = display.safeActualContentWidth - w,
        y = display.contentCenterY + w,
        label = "↓",
        shape = "rect",
        width = w,
        height = w,
        strokeWidth = 1,
        strokeColor = { default = { 0, 0, 0 }, over = { 0.5, 0.5, 0.5 } },
        fillColor = { default={ 1, 0.2, 0.5, 0.7 }, over={ 1, 0.2, 0.5, 1 } },
        onPress = function() self:ev({ 0, 1 }) end
    })
end
return UI