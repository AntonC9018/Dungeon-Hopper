
local Template = require("chains.chaintemplate")

local Start = function(entityClass)
    entityClass.chainTemplate = Template()
    entityClass.decorators = {}
end

return Start