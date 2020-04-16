
-- Multimov means
--
-- An entity that uses a dirs algorithm, that is, selects a set of possible
-- next actions by an algorithm, and then tries to apply those possible actions
-- by some other algorithm (generally, it would be the general algorithm)
--
-- ShouldAct chains are employed by the general algorithm 
local Decorator = require 'logic.decorators.decorator'
local ShouldAct = class('ShouldAct', Decorator)

ShouldAct.affectedChains = {
    { "shouldAttack", {} },
    { "shouldMove", {} },
    { "shouldDig", {} },
    { "shouldSpecial", {} }
}

return ShouldAct