local utils = {}

utils.activateDecorator = function(decorator)
    local name = class.name(decorator)
    return 
        function(self, ...)
            local decorator = 
                self.decorators[name]
            
            if (decorator ~= nil) then
                -- printf("Activating decorator %s", name) -- debug
                return decorator:activate(self, ...)
            end

            return nil
        end
end

utils.activateDecoratorCustom = function(decorator, funcName)
    local name = class.name(decorator)
    return 
        function(self, ...)
            local decorator = 
                self.decorators[name]
            
            if (decorator ~= nil) then
                -- printf("Activating decorator %s", name) -- debug
                return decorator[funcName](decorator, ...)
            end

            return nil
        end
end

return utils