table.deepClone = function(toClone)
    local clone
    if (type(toClone) == 'table') then
        clone = {}
        for k,v in pairs(toClone) do
            clone[k] = table.deepClone(v)
        end
    else
        clone = toClone
    end

    return clone 
end
