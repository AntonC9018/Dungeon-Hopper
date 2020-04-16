local Chain = require("lib.chains.chain")
-- local StatelessHandler = require("lib.chains.handler").StatelessHandler

local ChainsTemplate = class("ChainsTemplate")

function ChainsTemplate:__construct()
    self.chains = {}
end

function ChainsTemplate:addChain(name)
    if self.chains[name] == nil then
        self.chains[name] = {}
    end
end

function ChainsTemplate:isSetChain(name)
    return self.chains[name] ~= nil
end

function ChainsTemplate:addHandler(name, handler)
    assert(self.chains[name] ~= nil)
    table.insert(self.chains[name], handler)
end

function ChainsTemplate:init()
    local chains = {}
    for key,hArr in pairs(self.chains) do
        local chain = Chain()
        chain:addHandlers(hArr)
        chains[key] = chain
    end
    return chains
end

return ChainsTemplate