local AttackEffect = class("AttckEffect")


function AttackEffect:__construct(AttackModifier)
    self.damage = AttackModifier.damage or 0
    self.pierce = AttackModifier.pierce or 0
end

return AttackEffect