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


function clamp(v, l, u)
    if v >= u then return u end
    if v <= l then return l end
    return v
end

table.contains = function(table, val)
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

table.merge = function(t1, t2)
    for k,v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                table.merge(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

table.mergeArray = function(arr1, arr2)
    local len = #arr1
    for i = 1, #arr2 do
        arr1[len + i] = arr2[i]
    end
    return arr1
end


function printf(...)
    print(string.format(...))
end


table.shuffle = function(t)
    assert(t, "table.shuffle() expected a table, got nil")
    local iterations = #t
    local j

    for i = iterations, 2, -1 do
        j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end

table.joinAll = function (...)
    local r = {}
    for i = 1, arg.n do
        table.mergeArray(r, arg[i])
    end
    return r
end

table.containsKey = function (t, k)
    for key, _ in pairs(t) do
        if key == k then return true end
    end
    return false
end

table.averageByKey = function(arr, key)
    local sum = arr[1]
    for i = 2, #arr do
        sum = sum + arr[i][key]
    end
    return sum / #arr
end


table.average = function(arr)
    local sum = arr[1]
    for i = 2, # arr do
        sum = sum + arr[i]
    end
    return sum
end


table.map = function (arr, func)
    local result = {}
    for i = 1, #arr do
        result[i] = func(arr[i])
    end
    return result
end

table.map2 = function (arr, arr2, func)
    local result = {}
    for i = 1, #arr do
        result[i] = func(arr[i], arr2[i])
    end
    return result
end


table.each = function (arr, func)
    for i = 1, #arr do
        func(arr[i])
    end
end


table.each2 = function (arr, arr2, func)
    for i = 1, #arr do
        func(arr[i], arr2[i])
    end
end

table.somef = function (arr, func)
    for i, v in ipairs(arr) do
        if func(arr[i]) then
            return true
        end
    end
    return false
end

function table.slice(tbl, first, last, step)
    local sliced = {}

    for i = first or 1, last or #tbl, step or 1 do
        sliced[#sliced+1] = tbl[i]
    end

    return sliced
end

table.sumBy = function(arr, field)
    local s = 0
    for _, el in ipairs(arr) do
        s = s + el[field]
    end
    return s
end

table.reduce = function(arr, func, i)
    local a = i or 0
    for _, el in ipairs(arr) do
        a = func(a, el)
    end
    return a
end

string.split = function(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

require 'lib.deepclone'