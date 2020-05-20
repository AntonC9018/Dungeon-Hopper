
local function forbidMove(event)
    print('Move forbidden')
    event.propagate = false
end

return {
    NoMove = { 'getMove', { forbidMove, Ranks.HIGH } },
}