
-- Multimov means
--
-- An entity that uses a movs algorithm, that is, selects a set of possible
-- next actions by an algorithm, and then tries to apply those possible actions
-- by some other algorithm (generally, it would be the general algorithm)
--
-- ShouldAct chains are mployed by the general algorithm 

local ShouldAct = function(entityClass)

    local template = entityClass.chainTemplate

    template:addChain("shouldAttack")
    template:addChain("shouldMove")
    template:addChain("shouldDig")
    template:addChain("shouldSpecial")

    table.insert(entityClass.decorators, ShouldAct)

end

return ShouldAct