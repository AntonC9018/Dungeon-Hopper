local DigEffect = class("DigEffect")

function DigEffect:__construct(modifier)
    self.damage = modifier.damage or 0
    self.power = modifier.power or 0
end

return DigEffect