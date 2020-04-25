local utils = {}


utils.addHandlerOnChain = function(chainName, func)
    return function(target)
        local chain = target.chains[chainName]
        if chain ~= nil then
            chain:addHandler(func)
        end
    end
end

utils.removeHandlerOnChain = function(chainName, func)
    return function(target)
        local chain = target.chains[chainName]
        if chain ~= nil then
            chain:removeHandler(func)
        end
    end
end


utils.addHandlerOnChains = function(chainNames, func)
    return function(target)
        for i, name in ipairs(chainNames) do
            local chain = target.chains[name]
            if chain ~= nil then
                -- printf("Adding handler onto %s chain", name) -- debug
                chain:addHandler(func)
            end
        end
    end
end


utils.removeHandlerOnChains = function(chainNames, func)
    return function(target)
        for i, name in ipairs(chainNames) do
            local chain = target.chains[name]
            if chain ~= nil then
                -- printf("Removing handler from %s chain", name) -- debug
                chain:removeHandler(func)
            end
        end
    end
end

utils.addRemoveHandlerOnChain = function(chainName, func, priority)
    return 
        utils.addHandlerOnChain(chainName, priority ~= nil and { func, priority } or func),
        utils.removeHandlerOnChain(chainName, func)
end

utils.addRemoveHandlerOnChains = function(chainNames, func, priority)
    return 
        utils.addHandlerOnChains(chainNames, priority ~= nil and { func, priority } or func),
        utils.removeHandlerOnChains(chainNames, func)
end

return utils