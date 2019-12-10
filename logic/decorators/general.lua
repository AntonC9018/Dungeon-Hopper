-- use general algorithm, that is
--      1. make the entity Acting, that is, allow it to do stuff
--      2. make it MultiMov
--      3. make it use the GeneralAlgo
--      4. make it Sequential

local Acting = require "acting"
local ShouldAct = require "shouldact"
local GeneralAlgo = require "logic.action.algorithms.general"
local Sequential = require "sequential"

local function General(entityClass)

    Acting(entityClass)
    ShouldAct(entityClass)
    entityClass.actionAlgorithm = GeneralAlgo
    Sequential(entityClass)

end

return General