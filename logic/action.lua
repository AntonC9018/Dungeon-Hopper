-- 
-- action.lua
--
-- This file contains the Action class, which is anything an object
-- plans to do or does that may change the game state.
-- We have the following types of Actions:
--      1. ATTACK
--      2. MOVE
--      3. DIG
--      4. ATTACK_MOVE : either attacking or moving, attacking in priority
--      5. ATTACK_DIG_MOVE
--      6. NONE : stay still
--      7. SPECIAL

local Action = class("Action")

Action.Types = 
{
    ATTACK = 1,
    MOVE = 2,
    DIG = 3,
    ATTACK_MOVE = 4,
    ATTACK_DIG = 5,
    ATTACK_DIG_MOVE = 6,
    NONE = 7,
    SPECIAL = 8
}

-- the none action means doing nothing
local None = class("NoneAction", Action)
Action.None = None

function None:__construct()
    self.type = Action.Types.NONE
end



local Attack = class("AttackAction", Action)
Action.Attack = Attack
function Attack:__construct(obj)
    self.direction = obj.direction
    self.pos = obj.pos
    self.attack = obj.attack    
    self.type = Action.Types.ATTACK
end


local Move = class("MoveAction", Action)
Action.Move = Move
function Move:__construct(obj)
    self.direction = obj.direction
    self.pos = obj.pos 
    self.type = Action.Types.MOVE
end


local Dig = class("DigAction", Action)
Action.Dig = Dig
function Dig:__construct(obj)
    self.direction = obj.direction
    self.pos = obj.pos
    self.dig = obj.dig    
    self.type = Action.Types.DIG
end


local AttackMove = class("AttackMove", Action)
Action.AttackMove = AttackMove
function AttackMove:__construct(obj)
    self.direction = obj.direction
    self.pos = obj.pos 
    self.attack = obj.attack
    self.move = obj.move
    self.type = Action.Types.ATTACK_MOVE
end


local AttackDig = class("AttackDig", Action)
Action.AttackDig = AttackDig
function AttackDig:__construct(obj)
    self.direction = obj.direction
    self.pos = obj.pos 
    self.attack = obj.attack
    self.dig = obj.dig
    self.type = Action.Types.ATTACK_DIG
end


local AttackDigMove = class("AttackDigMove", Action)
Action.AttackDigMove = AttackDigMove
function AttackDigMove:__construct(obj)
    self.direction = obj.direction
    self.pos = obj.pos 
    self.attack = obj.attack
    self.dig = obj.dig
    self.move = obj.move
    self.type = Action.Types.ATTACK_DIG_MOVE
end

local Special = class("SpecialAction", Action)
Action.Special = Special
function Special:__construct(obj)
    self.direction = obj.direction
    self.pos = obj.pos
    self.special = obj.special -- TODO: figure what this should be
    self.type = Action.Types.SPECIAL
end


Action.Actions = {
    Attack,
    Move,
    Dig,
    AttackMove,
    AttackDig,
    AttackDigMove,
    None,
    Special
}



return Action