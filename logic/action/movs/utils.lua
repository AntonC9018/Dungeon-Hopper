
local calculateRelativeness = function(actor)
    local player = 
        actor.world.grid:getClosestPlayer(actor.pos)
    local gx, gy = 
        player.pos.x > actor.pos.x, player.pos.y > actor.pos.y
    local lx, ly = 
        actor.pos.x > player.pos.x, actor.pos.y > player.pos.y

    return gx, gy, lx, ly
end


return {
    calculateRelativeness = calculateRelativeness
}