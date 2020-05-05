local Effect = class("Effect")

function Effect:__construct(mod)
    for i, v in ipairs(self.modifier) do
        self[ v[1] ] = mod and mod[ v[1] ] or v[2]
    end
end

Effect.modifier = {}

return Effect