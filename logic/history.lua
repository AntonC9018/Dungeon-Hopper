local History = class('History')

function History:__construct()
    self.turns = {}
end

function History:arr()
    return self.turns
end

function History:add(e)
    table.insert(self.turns, e)
end

-- check if there was at least one turn that
-- satisfied at least one of the conditions 
function History:wasAny(...)
    for i = 1, #self.turns do
        if self.turns[i]:satisfiesAny(...) then
            return true
        end
    end
    return false
end

-- check if there was at least one turn that
-- satisfied all specified conditions at once
function History:was(...)
    for i = 1, #self.turns do
        if self.turns[i]:satisfies(...) then
            return true
        end
    end
    return false 
end


-- check if there was at least one turn that
-- satisfied a specified condition, for each of the conditions
function History:wasAll(...)
    for j = 1, arg.n do
        
        if arg[j] == 'string' then
            local any = false
            for i = 1, #self.turns do
                if self.turns[i][arg[j]] then
                    any = true
                    break
                end
            end
            if not any then return false end
        else
            -- we got a table
            if not self:was(unpack(arg[j])) then
                return false
            end
        end 
    end
    return true
end

-- check if no turns satisfied the specified conditions
function History:wasnot(...)
    for i = 1, self.turns do
        if self.turns:satisfies(...) then
            return false
        end
    end
    return true
end

return History