local Chain = require("lib.chains.schain")
-- local StatelessHandler = require("lib.chains.handler").StatelessHandler

local SChainsTemplate = class("SChainsTemplate")

function SChainsTemplate:__construct()
    self.chains = {}
end

function SChainsTemplate:addChain(name)
    if self.chains[name] == nil then
        self.chains[name] = {}
    end
end

function SChainsTemplate:isSetChain(name)
    return self.chains[name] ~= nil
end

function SChainsTemplate:addHandler(name, handler)
    assert(self.chains[name] ~= nil)
    table.insert(self.chains[name], handler)
end

function SChainsTemplate:init()
    local chains = {}
    for key,hArr in pairs(self.chains) do
        local chain = Chain()
        chain:addHandlers(hArr)
        chains[key] = chain
    end
    return chains
end

return SChainsTemplate