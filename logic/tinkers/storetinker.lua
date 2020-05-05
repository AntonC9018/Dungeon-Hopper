-- The idea of this tinker is like
--
-- What if you want to have a shared piece of data between the handlers
-- but you want to use the same tinker for all instances? clearly
-- you can't just put information of the tinker, since it will be shared
--
-- There are a couple of ways to implement stateful tinkers without re-
-- instantiating the tinker every time that I can think of.
-- 
-- 1. we could store an id or some key that every entity will provide 
--    on each call to tink / untink. If a store with that id doesn't exist
-- [ Actually realized that stores can be managed separately, so there are separate methods for it ]
--    one will be created. This way the handlers that reference the
--    tinker would provide the entities' id as the key to the store of
--    the shared piece of data.
--    something like:
--          `local store = tinker:getStore(event.actor)`
--    now they would modify the store if they need to.
--    The store also has to be accessible by the tinker's owner, e.g.
--    inside the chains of e.g. submerging an entity, but that can be figured
--    by simply storing the submerged entity.
-- 
-- Now that I think of it, it is actually perfect! and it doesn't even require
-- a separate class (although I will make a separate class to allow simpler usage too) 
--
-- 2. create a wrapper object around a tinker. This will not work, since the 
--    handlers get just the tinker instance, so the logic has to be rewritten
--
-- I like the first idea though

local RefTinker = require 'logic.tinkers.reftinker'

local StoreTinker = class('StoreTinker', RefTinker)


function StoreTinker:__construct(generator)
    self.stores = {}
    RefTinker.__construct(self, generator)
end

function StoreTinker:setStore(entity, obj)
    self.stores[entity.id] = obj or {}
end

function StoreTinker:getStore(entity)
    return self.stores[entity.id]
end

function StoreTinker:removeStore(entity)
    self.stores[entity.id] = nil
end


return StoreTinker



