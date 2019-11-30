-- this file describes the structure of the entity objects
-- that should be passed to renderer
local entity = {
    pos = Vec(0, 1), -- this is the position
    orientation = Vec(1, 0), -- this one basically describes rotation

    -- TODO: change this to numbers
    state = "One of the state names",
    weapon = {} -- another same `entity`.
}

-- obj is the real entity in world
local function convertForRenderer(obj, eventName) 

    assert(type(obj) == 'table')

    local entity = {}
    entity.pos = obj.pos
    entity.orientation = obj.orientation
    entity.state = obj.state

    -- TODO: readdress this
    -- this highly depends on the algorithm of attacking
    -- so prbably will need to be readdressed later
    if obj.weapon == nil or eventName ~= eventNames.attack then
        entity.weapon = nil -- if obj doesn't have weapon, it'll be null
    else
        entity.weapon = {}
        entity.weapon.pos = obj.pos + obj.orientation
        entity.weapon.orientation = obj.weapon.orientation

        -- e.g. different sprites for different versions of a weapon
        entity.weapon.state = obj.weapon.state 
    end

    return entity
end