local AttackEffect = class("AttackEffect")


function AttackEffect:__construct(AttackModifier)
    self.damage = AttackModifier.damage or 0
    self.pierce = AttackModifier.pierce or 0
end

return AttackEffect