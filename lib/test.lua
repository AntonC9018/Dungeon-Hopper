-- a little test session
local e = require('emitter')()

local lis1 = function(a, b) print(a + b) end
local lis2 = function(a, b) print(a, b) end

e:on('ev1', lis1)
e:on('ev1', lis2)

e:emit('ev1', 2, 3) -- should print '5' and '2 3'

print('----------------------------')

e:removeListener('ev1', lis1)

e:emit('ev1', 2, 3) -- should print '2 3'

print('----------------------------')

e:once('ev2', lis1)
e:on('ev2', lis2)

e:emit('ev2', 2, 3) -- should print '2 3' and '5'
e:emit('ev2', 2, 3) -- should print '2 3'

print('-----------------------------')

local trueSometimes = function(a)
    if a == 1 then
        return 'Cool'
    else
        return false
    end
end
local final = function(a) print(a .. '? Yes, sir!') end

e:untilTrue('ev3', trueSometimes, final)

print('Feeding 0')
e:emit('ev3', 0)
print('Feeding 1')
e:emit('ev3', 1) -- only here it should print
print('Feeding 1 again')
e:emit('ev3', 1)
print('Feeding 2')
e:emit('ev3', 2)