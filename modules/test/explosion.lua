local Entity = require "logic.base.entity"
local Cell = require "world.cell"
local AttackAction = require 'logic.action.actions.attack'
local StatTypes = require('logic.decorators.dynamicstats').StatTypes
local Changes = require "render.changes"

local Explosion = class("Explosion", Entity)

-- select layer
Explosion.layer = Cell.Layers.explosion
Explosion.state = 1

function Explosion:set(p)
    self.params = p
end

function Explosion:calculateAction()
    if self.state == 1 then
        local action = AttackAction()
        action:setDirection(self.params.direction)
        action.attack = self.params.attack
        action.push = self.params.push
        self.nextAction = action
    else
        self.nextAction = nil
    end
end


local LAST_PHASE = 3

function Explosion:executeAction()  

    if self.nextAction == nil then
        return
    end

    -- apply attack to all objects of the cell that
    -- are vulnerable to explosions
    local entities = self.world.grid:getAllAt(self.pos)

    for _, entity in ipairs(entities) do
        if entity ~= nil and entity ~= self then
            local res = entity:getStat(StatTypes.ExplRes)
            print('Attacking '..class.name(entity))
            if 
                res == nil 
                or self.params.explosionLevel >= res  
            then
                entity:beAttacked(self.nextAction)
                entity:bePushed(self.nextAction)
            end
        end
    end

    if self.state == LAST_PHASE then
        self.dead = true
        self.world:registerChange(self, Changes.Dead)
    else
        self.state = self.state + 1
        self.world:registerChange(self, Changes.JustState)
    end
end


return Explosion