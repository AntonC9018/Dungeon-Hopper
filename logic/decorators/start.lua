
local Template = require("lib.chains.schaintemplate")

local Start = function(entityClass)
    entityClass.chainTemplate = Template()
    entityClass.decoratorsList = {}
end

return Start