
local Actions = {
    Attack = require "logic.action.actions.attack",
    Move = require "logic.action.actions.move",
    Dig = require "logic.action.actions.dig",
    AttackMove = require "logic.action.actions.attackmove",
    AttackDig = require "logic.action.actions.attackdig",
    AttackDigMove = require "logic.action.actions.attackdigmove",
    None = require "logic.action.actions.none",
    Special = require "logic.action.actions.special"
}

return Actions