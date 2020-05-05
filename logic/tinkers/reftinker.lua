-- these tinkers have reference to themselves inside their halders
local Tinker = require 'logic.tinkers.tinker'

local RefTinker = class("RefTinker", Tinker)

function RefTinker:__construct(generator)
    Tinker.__construct(self, generator(self))
end

return RefTinker