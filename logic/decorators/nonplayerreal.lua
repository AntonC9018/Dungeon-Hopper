


local NonPlayerReal = function(entityClass)

    local template = entityClass.chainTemplate

    template:addChain("shouldAttack")
    template:addChain("shouldMove")
    template:addChain("shouldDig")
    template:addChain("shouldSpecial")
    template:addChain("failedAction")

    table.insert(entityClass.decorators, NonPlayerReal)

end

return NonPlayerReal