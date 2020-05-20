
local function forbidMove(event)
    event.propagate = false
end

return {
    NoMove = { 'getMove', { forbidMove, Ranks.HIGH } },
}