
local function bump(event)



end


local function Bumping(entityClass)

    local template = entityClass.chainTemplate

    template:addHandler("failAction", bump)

end

return Bumping