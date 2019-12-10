


local Acting = function(entityClass)

    local template = entityClass.chainTemplate

    template:addChain("failedAction")
    tamplate:addChain("succeedAction")

    table.insert(entityClass.decorators, Acting)

end

return Acting