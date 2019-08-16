local Object = require('base.object')
local Gold = require('environ.gold')
local Wizzrobe = require('enemies.wizzrobe')

local Crate = class('Crate', Object)

Crate.offset_y = -0.2
Crate.offset_y_jump = -0.3
Crate.offset_y_hop = -0.3

Crate.scale = Object.scale * 0.75

Crate.innards= {
    { v = vec(0, 0), am = 250, t = 'gold'        },
    { v = vec(1, 0), cl = Wizzrobe, t = 'entity' }
}

function Crate:__construct(...)
    Object.__construct(self, ...)
    self:createImage(1, UNIT, UNIT)

    -- self:once('hit:taken-damage', function()
    --     self:on('animation:start', function()
    --         local arr = self.hist:arr()
    --         for i = 1, #arr do
    --             print(ins(arr[i], {depth = 1}))
    --         end
    --     end)
    -- end)


end

return Crate