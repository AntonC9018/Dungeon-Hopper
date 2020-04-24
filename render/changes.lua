return 
{
    Dead = 'dead',
    Dug = 'dug',   -- being dug
    Digs = 'digs', -- doing dig
    Move = 'move', -- moving itself
    Hits = 'hits', -- hitting something
    Hurt = 'hurt', -- being hit
    Bump = 'bump', -- did not manage to move
    Stuck = 'stuck', -- stuck in water
    Push = 'pushed', -- was pushed
    Status = 'status', -- was applied some status effects (does not have any specific ones for now, but it will one the status is implemented)

    Bounce = 'bounce', -- doing bounce
    JustState = 'state' 
}

-- These strings may subsequently be changed to e.g. plain numbers. 
-- For now, i'm using strings to simpily debugging