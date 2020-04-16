
local Attack = require "logic.action.actions.attack"
local Move = require "logic.action.actions.move"
local Dig = require "logic.action.actions.dig"
local AttackMove = require "logic.action.actions.attackmove"
local AttackDig = require "logic.action.actions.attackdig"
local AttackDigMove = require "logic.action.actions.attackdigmove"
local None = require "logic.action.actions.none"
local Special = require "logic.action.actions.special"

Actions = {
    Attack,
    Move,
    Dig,
    AttackMove,
    AttackDig,
    AttackDigMove,
    None,
    Special
}

return Actions