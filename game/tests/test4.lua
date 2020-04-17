return function()

    -- local function hello()
    --     print("hello")
    -- end

    -- local chain = Chain()
    -- chain:addHandler(hello)
    -- chain:pass({})

    local ChainTemplate = require "lib.chains.chaintemplate"

    local template = ChainTemplate() 

    local function handler00(event) 
        print("handler 00")
    end
    local function handler01(event) 
        print("handler 01")
    end
    local function handler02(event) 
        print("handler 02")
    end

    -- add a chain with 2 handlers
    template:addChain('chain0')
    template:addHandler('chain0', handler00)
    template:addHandler('chain0', handler01)

    -- add a chain with 1 handler
    template:addChain('chain1')
    template:addHandler('chain1', handler10)

    -- add a chain with 0 handlers
    template:addChain('chain2')

    local chains = template:init()

    print(ins(chains))
    -- {
    --     chain0 = Chain,
    --     chain1 = Chain,
    --     chain2 = Chain
    -- }

    chains.chain0:pass({})
    chains.chain1:pass({})

    print(ins(chains))

end