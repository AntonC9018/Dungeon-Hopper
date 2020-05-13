local t = {}

t.registerItem = function(item)
    t[ item:getItemId() ] = item
end

return t