local Synchronizer = class("Synchronizer")

-- this class should force game loop if the player 
-- did not provide user input for long enough,
-- or prevent the game looping if the player
-- provided too much input in a short enough time

return Synchronizer