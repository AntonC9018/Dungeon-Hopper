local handlerUtils = require '@action.handlers.utils' 

local utils = {}

-- this method takes the name of the decorator as its parameter
-- it a) makes an action that calls the decorator's activation
--    b) makes calculateAction() set the action +
--       sets the direction to the orientation
utils.redirectActionToDecorator = function(entityClass, decoratorName)
    -- define our custom action that calls the new decorator's activation
    local CustomAction = Action.fromHandlers(
        -- TODO: make sure this is not taken
        -- well, if it is, then the action would be that same created previously
        -- so no big deal
        decoratorName..'Action',
        handlerUtils.activateDecorator(decoratorName)
    )

    entityClass.calculateAction = function(self)
        local action = CustomAction()
        -- set the orientation right away since it won't change
        action.direction = self.orientation
        self.nextAction = action
    end

    return CustomAction
end


utils.redirectActionToHandler = function(entityClass, funcName)
    -- define our custom action that calls the new decorator's activation
    local CustomAction = Action.fromHandlers(
        -- TODO: make sure this is not taken
        -- well, if it is, then the action would be that same created previously
        -- so no big deal
        funcName..'Action',
        handlerUtils.applyHandler(funcName)
    )

    entityClass.calculateAction = function(self)
        local action = CustomAction()
        -- set the orientation right away since it won't change
        action.direction = self.orientation
        self.nextAction = action
    end
    
    return CustomAction
end

return utils