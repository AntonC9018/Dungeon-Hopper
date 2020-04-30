-- The starting numbers for the ranks
local function getRankMap()

    return 
    {
        100000, -- LOWEST
        200000, -- LOW
        300000, -- MEDIUM
        400000, -- HIGH
        500000  -- HIGHEST
    }

end

local rankMap = getRankMap()

return {
    rankMap = rankMap,
    getRankMap = getRankMap
}