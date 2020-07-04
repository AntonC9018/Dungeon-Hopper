return function(code, obj)
    return {
        id = obj.id,
        state = obj.state,
        pos = obj.pos,
        orientation = obj.orientation,
        event = code,
        phase = obj.world.phase
    }
end