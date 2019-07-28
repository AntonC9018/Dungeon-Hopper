local Step = class('Step')

function Step:__construct(s)
    local ns = type(s.name) == 'table' and s.name or { s.name }
    local anims = {}

    if s.anim then
        if type(s.anim) == 'string' then
            for j = 1, #ns do
                anims[ns[j]] = s.anim
            end
        else
            for j = 1, #ns do
                anims[ns[j]] = s.anim[j] or s.anim[ns[j]]
            end
        end
    else
        for j = 1, #ns do
            anims[ns[j]] = ns[j]
        end
    end
    s.name = ns
    s.anim = anims

    for k, v in pairs(s) do
        self[k] = v
    end
end


function Step:is(...)
    for i = 1, arg.n do
        if not contains(self.name, arg[i]) then
            return false
        end
    end
    return true
end


return Step