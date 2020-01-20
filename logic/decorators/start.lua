
local Template = require("chains.chaintemplate")

local Start = function(entityClass)
    entityClass.chainTemplate = Template()
    entityClass.__emitter = Emitter()
    entityClass.__emitter:on("create", 
        function(instance)
            instance.handlers = {}
            instance.chains = entityClass.chainTemplate:init()
        end)
    entityClass.decorators = {}
end

return Start