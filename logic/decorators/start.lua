
local Template = require("lib.chains.chaintemplate")

local Start = function(entityClass)
    entityClass.chainTemplate = Template()
    entityClass.decoratorsList = {}
end

return Start