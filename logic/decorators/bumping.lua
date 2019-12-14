
local function bump(event)



end


local function Bumping(entityClass)

    local template = entityClass.chainTemplate

    template:addHandler("failedAction", bump)

end

return Bumping