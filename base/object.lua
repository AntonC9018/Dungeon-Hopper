local Entity = require('base.entity')

local Object = class('Object', Entity)

Object.anims = {
    { c = {'dead'},              a = "_die" },
    {c = {'displaced'}, a = '_displaced'},
    {c = {'hurt'}, a = '_hopUp'}
}

Object.dmg_thresh = 3

Object.def = {
    dmg = 0,
    push = 0
}

Object.priority = 0

Object.hp_base = {
    t = 'red',
    am = 1
}

function Object:isObject()
    return true
end

function Object:anim() end
function Object:playAudio() end
function Object:act() self.moved = true end


return Object