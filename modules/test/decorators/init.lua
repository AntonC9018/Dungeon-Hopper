-- There seems to be a need for an init hook for entity classes
-- e.g. the items should be generated and set on entities from
-- the very start.
-- 
-- For now I'm going to implement this hook as a decorator and I
-- understand that this isn't the perfect soultion since the 
-- chains of the decorators are dynamic, while the init chains
-- really have to be traversed just once and then there is no 
-- need for them, but this can be optimized later by adding 
-- lazy static chains (chains that are reinstantiated only when
-- it is required at runtime and not beforehand on entity 
-- initialization as it is currently)
local Decorator = require 'logic.decorators.decorator'

local Init = class("Init", Decorator)

function Init:__construct(entity)
    local event = Event(entity, nil)
    entity.chains.init:pass(event)
    return event
end

Init.affectedChains = {
    { 'init', {} }
}

return Init