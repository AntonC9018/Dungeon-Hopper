local Event = require "lib.chains.event"

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

    self.successStepIndex = nil
    self.failureStepIndex = nil

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
            self.successStepIndex = config.success
        
        else
            self.successStepIndex = config.success.index
            self.successChain = config.success.chain
        end
    end

    if config.failure ~= nil then
        self.failureStepIndex = config.failure
    end

    if config.enter ~= nil then
        self.enter = config.enter
    end

    if config.exit ~= nil then
        self.exit = config.exit
    end

    self.repet = config.repet

end


function Step:nextStep(event)
    local stepSuccessful = self:checkSuccess(event) 

    if stepSuccessful then
        return successStepIndex
    else
        return failureStepIndex
    end
end


function Step:checkSuccess(event) 
    local outerEvent = Event(self, nil)
    outerEvent.triggerEvent = event
    self.successChain:pass()
    return outerEvent.propagate
end

function Step:enter() end
function Step:exit() end


return Step