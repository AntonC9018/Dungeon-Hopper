local Step = class("Step")


local function checkSuccessDefault()
    local chain = Chain()
    chain:addHandler(
        function(event)
            .triggerEvent.propagate
        end
    )
    return chain
end


function Step:__construct(config)

    self.successStepCount = nil
    self.failureStepCount = nil

    local actionClass = config.action
    -- action must be specified
    assert(actionClass ~= nil)

    -- what is an action exactly?
    --
    -- action is just what is going to be passed down the line 
    -- when the instance does stuff. Based off of that action,
    -- different things would get executed. For example, 
    -- the Attack action has a chain attached to it. This chain
    -- in our case provides handlers for attacking an entity
    -- For more examples, see `actions`.

    self.actionClass = actionClass

    if config.success ~= nil then
        if type(config.success) == 'number' then
            self.successStepCount = config.success
        
        else
            self.successStepCount = config.success[1]
            self.successChain = config.success[2]
        end
    end

    if config.failure ~= nil then
        self.failureStepCount = config.failure
    end

    if config.enter ~= nil then
        self.enter = config.enter
    end

    if config.exit ~= nil then
        self.exit = config.exit
    end

    if config.repet ~= nil then
        
    end

end


function Step:checkSuccess(event) 
    local outerEvent = Event(self, nil)
    outerEvent.triggerEvent = event
    self.successChain:pass()
    return outerEvent.propagate
end
function Step:success() 
    return self.successStepCount 
end
function Step:failure() 
    return self.failureStepCount
end
function Step:enter() end
function Step:exit() end


return Step