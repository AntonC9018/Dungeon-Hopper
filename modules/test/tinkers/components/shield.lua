return function(pierce, damage)

    return function(event)
        if event.action.attack.damage >= damage then
        elseif event.action.direction:equals(-event.actor.orientation) then
            event.resistance:add('pierce', pierce)
        end
    end

end