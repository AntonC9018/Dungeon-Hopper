local Ranks = require 'lib.chains.ranks'
local utils = require 'logic.retouchers.utils'

local shield = {}


local function block(dir, pierce)
    return function(event)
        if event.action.direction:equals(dir) then
            event.resistance:add('pierce', pierce)
        end
    end
end

-- works by increasing the piercing level when 
-- attacked from a certain direction
shield.constantDir = function(entityClass, dir, pierce)
    utils.retouch(entityClass, 'defence', block(-dir, pierce))
end


local function blockOrientation(pierce)
    return function(event)
        if event.action.direction:equals(-event.actor.orientation) then
            event.resistance:add('pierce', pierce)
        end
    end
end


shield.orientationDir = function(entityClass, pierce)
    utils.retouch(entityClass, 'defence', blockOrientation(pierce))
end


local function blockRotation(angle, pierce)
    return function(event)
        local dir = event.actor.orientation:rotate(angle)
        if event.action.direction:equals(dir) then
            event.resistance:add('pierce', pierce)
        end
    end
end


shield.blockRotation = function(entityClass, angle, pierce)
    utils.retouch(entityClass, 'defence', blockOrientation(angle, pierce))
end


return shield