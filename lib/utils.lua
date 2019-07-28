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

function contains(table, val)
    for i = 1, #table do
        if table[i] == val then 
           return true
        end
    end
    return false
end
function sign(x)
  return (x < 0 and -1) or ((x > 0 and 1) or 0)
end

table.all = function(arr, it)
    for i = 1, #arr do
        if arr[i] ~= it then return false end
    end
    return true
end


table.some = function(arr, it)
    for i = 1, #arr do
        if arr[i] == it then return true end
    end
    return false
end

function tdArray(w, h, f, reversed)
    if not f then f = function() return false end end

    local arr = {}

    if reversed then

        for i = w, 1, -1 do
            arr[i] = {}        
            for j = h, 1, -1 do
                arr[i][j] = f(i, j)
            end
        end


    else

        for i = 1, w do
            arr[i] = {}        
            for j = 1, h do
                arr[i][j] = f(i, j)
            end
        end

    end

    return arr
end