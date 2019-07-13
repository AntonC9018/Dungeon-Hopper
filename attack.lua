Attack = constructor:new{}

function Attack:new(obj)
    local o = constructor.new(self, obj)
    o.debuffs = {}
    o.specials = {}

    return o
end

function Attack:setDmg(dmg)
    self.dmg = dmg
end

function Attack:copyAll(e)
    for i = 1, #DEBUFFS do
        self.debuffs[DEBUFFS[i]..'_ing'] = e[DEBUFFS[i]..'_ing']
        self.debuffs[DEBUFFS[i]..'_amount'] = e[DEBUFFS[i]..'_amount']
    end
    for i = 1, #SPECIAL do
        self.specials[SPECIAL[i]..'_ing'] = e[SPECIAL[i]..'_ing']
        self.specials[SPECIAL[i]..'_amount'] = e[SPECIAL[i]..'_amount']
    end
end

function Attack:copySpecials(e, names)
    for i = 1, #names do
        self.specials[names[i]..'_ing'] = e[names[i]..'_ing']
        self.specials[names[i]..'_amount'] = e[names[i]..'_amount']
    end
end


function Attack:copyDebuffs(e, names)
    for i = 1, #names do
        self.debuffs[names[i]..'_ing'] = e[names[i]..'_ing']
        self.debuffs[names[i]..'_amount'] = e[names[i]..'_amount']
    end
end

function Attack:addDebuffs(names, ings, amounts)
    for i = 1, #names do
        self.debuffs[names[i]..'_ing'] = (self.debuffs[names[i]..'_ing'] or 0) + ings[i]
        self.debuffs[names[i]..'_amount'] = (self.debuffs[names[i]..'_ing'] or 0) + amounts[i]
    end
end


function Attack:addSpecials(names, ings, amounts)
    for i = 1, #names do
        self.specials[names[i]..'_ing'] = (self.specials[names[i]..'_ing'] or 0) + ings[i]
        self.specials[names[i]..'_amount'] = (self.specials[names[i]..'_amount'] or 0) + amounts[i]
    end
end
