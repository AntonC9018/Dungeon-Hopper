-- Pickuppable objects are game objects that have dual nature:
--      1. they can be game objects
--      2. they can be upgrades on player


-- In order to pick up an object, one has to REMOVE it from the grid
-- and set it's 'dead' attribute to true


-- So in order to drop an object, one has to SET it into the grid
-- and restore the dead field to false

