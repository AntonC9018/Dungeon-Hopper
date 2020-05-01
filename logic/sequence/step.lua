local Event = require "lib.chains.event"

local Step = class("Step")

local standartSuccessChain = Chain(
    {
        function(event)
            local enclosingEvent = event.triggerEvent.actor.enclosingEvent
            event.success = enclosingEvent.success
        end
    }
)

-- local function checkSuccessDefault()
--     local chain = Chain()
--     chain:addHandler(
--         function(event)
--             event.triggerEvent.propagate
--         end
--     )
--     return chain
-- end


function Step:__construct(config)

    self.successStepIndex = nil
    self.failStepIndex = nil

    local ActionClass = config.action
    -- action must be specified
    assert(ActionClass ~= nil)

    -- what is an action exactly?
    --
    -- action is just what is going to be passed down the line 
    -- when the instance does stuff. Based off of that action,
    -- different things would get executed. For example, 
    -- the Attack action has a chain attached to it. This chain
    -- in our case provides handlers for attacking an entity
    -- For more examples, see `actions`.

    self.ActionClass = ActionClass

    if config.success ~= nil then
        self.successStepIndex = config.success        
    end

    if config.fail ~= nil then
        self.failStepIndex = config.fail
    end    

    if config.checkSuccess == nil then
        self.successChain = standartSuccessChain
    else
        self.successChain = config.checkSuccess
    end

    if config.enter ~= nil then
        self.enter = config.enter
    end

    if config.exit ~= nil then
        self.exit = config.exit
    end

    if config.movs ~= nil then
        self.getMovs = config.movs
    end

    self.repet = config.repet

end


function Step:nextStep(event)
    local internalEvent = Event(self, nil)
    internalEvent.triggerEvent = event
    self.successChain:pass(internalEvent)

    if internalEvent.success then
        return internalEvent.index or self.successStepIndex
    else
        return self.failStepIndex
    end
end

function Step:enter() end
function Step:exit() end
function Step:getMovs() return {} end


return Step