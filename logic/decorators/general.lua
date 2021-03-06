-- use general algorithm, that is
--      1. make the entity Acting, that is, allow it to do stuff
--      2. give it the necessary ShouldAct chains
--      3. make it use the GeneralAlgo
--      4. make it Sequential

local Acting = require "@decorators.acting"
local GeneralAlgo = require "@algos.general"
local Sequential = require "@decorators.sequential"

local function General(entityClass)

    decorate(entityClass, Acting)
    entityClass.chainTemplate:addHandler('action', GeneralAlgo)
    decorate(entityClass, Sequential)

end

return General