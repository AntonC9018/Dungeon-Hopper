-- the interface for a decorator

local Decorator = class("Decorator")


function Decorator:decorate(classdef)
    local methods = self.methods
    for k,v in pairs(methods) do
        classdef[k] = v
    end
end


function Decorator:__construct(methods)
    self.methods = methods
end

return Decorator
