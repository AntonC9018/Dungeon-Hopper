-- Rework decorators as components

local Decorator = class("Decorator")

-- Basically, all decorators do right now is they add 
-- a bunch of handlers to chains / create new chains on instances
--
-- 

-- Store the list of affected chains here
Decorator.affectedChains = {}

-- Decorator initialization function
Decorator.decorate = function(instanceClass, decoratorClass)

    printf("%s, %s", class.name(instanceClass), class.name(decoratorClass))

    -- put this decorator for firther intialization in the list of decorators
    local decoratorsList = instanceClass.decoratorsList
    table.insert(decoratorsList, decoratorClass)

    if decoratorClass.affectedChains == nil then
        return
    end

    -- update the template on instance class
    local template = instanceClass.chainTemplate

    for i = 1, #decoratorClass.affectedChains do
        local chain = decoratorClass.affectedChains[i][1]
        local handlers = decoratorClass.affectedChains[i][2]
        if not template:isSetChain(chain) then
            template:addChain(chain)
        end
        for j = 1, #handlers do
            template:addHandler(chain, handlers[j])
        end
    end
end


function Decorator:__construct()
end

function Decorator:activate()
end

return Decorator