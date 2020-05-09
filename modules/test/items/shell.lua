-- is just like a shield but blocks damage from all sides
local Item = require 'items.item'
local Tinker = require 'logic.tinkers.tinker'
local Ranks = require 'lib.chains.ranks'

local Shell = class("Shell", Item)


function Shell:__construct(damage, pierce, resReduction)

    damage = damage or math.huge
    pierce = pierce or 0
    resReduction = resReduction or 0
    

    local function block(event)
        event.resistance:add('pierce', pierce)

        if event.action.attack.damage >= damage then
            -- TODO: create some kind of marker at the actor that would show
            -- whether or not a blocking item has been removed this beat.
            -- Do not break if it were.
            event.actor:removeItem(self)
        end
    end

    local function reducePushRes(event)
        event.resistance = event.resistance - resReduction
    end

    -- make the tinker
    local tinker = Tinker({
        { 'defence',   { block,         Ranks.MEDIUM } },
        { 'checkPush', { reducePushRes, Ranks.MEDIUM } }
    })

    -- activate the base constructor
    Item.__construct(self, tinker)

end

-- for now use the second slot
Shell.slot = 2

-- return a test shell for now
return Shell(2, 2, 0)