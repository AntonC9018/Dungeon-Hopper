-- table.each = function(a, f)
--     for 
-- end


table.addToEach = function(a, v)
    local t = {}
    for i = 1, #a do
        t[i] = a[i] + v
    end
    return t
end


-- table.indexOf2d = function(a2d, o)
--     for i = 1, #a2d do
--         for j = 1, #a2d[i] do
--             if 
--         end
--     end
-- end


table.indexOf = function(a, o)
    for i = 1, #a do
        if a[i] == o then
            return i
        end
    end
    return false
end


function clamp(v, u, l)
    if v >= u then return u end
    if v <= l then return l end
    return v
end

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end