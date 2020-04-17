local utils = {}

utils.activateDecorator = function(decorator)
    local name = class.name(decorator)
    return 
        function(self, ...)
            local decorator = 
                self.decorators[name]
            
            if (decorator ~= nil) then
                return decorator:activate(self, ...)
            end

            return nil
        end
end

return utils