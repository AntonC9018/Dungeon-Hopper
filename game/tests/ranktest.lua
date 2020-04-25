local Chain = require 'lib.chains.schain'
local Ranks = require 'lib.chains.ranks'

return function()

    local function a1(event)
        print(1)
        event.x = 1
    end

    local function a2(event)
        print(2)
        printf('X = %i', event.x)
    end

    local function a3()
        print(3)
    end

    local function a4()
        print(4)
    end

    local function a5()
        print(5)
    end

    local test = Chain()
    local event = Event()

    test:addHandler(a1)
    test:addHandler(a2)
    test:addHandler(a3)
    test:addHandler(a4)
    test:addHandler(a5)

    test:pass(event)

end