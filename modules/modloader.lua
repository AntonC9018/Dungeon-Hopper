-- The mod main files are just config files.
-- We've got to require them and then just add their content into
-- global lists.


-- One complication is that there are thing that have to be defined before
-- the other content of the mod and it expects that content to be there
-- I may limit or forbid that, don't know what to do about it yet
--
-- E.g. the chest gets the item pool id from the global pool config
-- at the time of class definition, so it expects it to be available
-- globally at that time. Potential workarounds:
--      1. use strings instead of ids for selecting a pool (ok)
--      2. use a function of getting a pool (ok, but a bit worse)
--      3. store the pools themselves as strings (meh)