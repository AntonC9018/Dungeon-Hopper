# Overview
This folder includes files responsible for game logic in a particular world.

# Calling conventions:

1. *Every single game object that exists in the game world and may be found in a cell is a `game object`.*
    
These include: floor tiles, walls, player, enemies, gold, traps, dropped items, torches, items for sale, projectiles, and explosions. 

Everything that is not a game object and is found in world but not in a particular cell, is a `particle`.

2. *Every game object that has `health` is an `entity`.*
Entities may have one or more of the following properties:
    * *`Attackable`*, that is entities that can take damage from normal attacks and, for that matter, can be attacked e.g. player, enemies, environmental objects like barrels
    * *`Explodable`*, e.g. walls, traps and all *Attackable* entities, dropped items (?), gold (?)
    * *`Attacking`*, e.g. player, enemies, some traps, some walls, some environmental objects
    * *`Moving`*, that is entities that may change their location in the grid, e.g. player, enemies, environmental objects
    * *`Sized`*, that is entities that may occupy multiple cells at once
    * *`Statused`*, that is entities that are vulnerable to status effects, e.g. being frozen, on fire etc. and being pushed, e.g. player and enemies
    * *`AttackableOnlyWhenNextToAttacker`* speaks for itself. Include environmental objects like crates
    * *`Pickuppable`*, whether the thing can be picked up by player. *Picking-up* means destroying and converting to some other information, e.g. dropped item -> picked-up item
    * *`Real`* if the entity is a player, an enemy or an environmental object, such as a barrel etc. and *`Non-Real`* otherwise.

These things are implemented as decorators 


# Game Loop

Here is an overview of what happens during the game loop and in what order.

1. All game objects have priority, which determines in what order they act. For example, *Enemies* have higher priority than *projectiles*, this is why they move first, and then do the projectiles. **All game objects are sorted by priority among their categories at the start of each loop**. Amongst *traps* and *floors*, things are too sorted by priority at the start of each loop. This ensures thing are always in order.

2. After that, all game objects are asked to decide on their next action, and save it inside them (see action.lua for a list of action types). These calculations cannot affect the grid (world) state. This is ensured by creating a copy of the entire grid before those calculations. This "fake" grid prevents things from doing attacks and taking damage.

3. Now the real grid is restored and all saved actions are executed in this order:
    1. *Player* actions
    2. All *Reals* but player
    3. *Explosions*
    4. *Floor* hazards
    5. finally, *Traps*

4. Destroyed (*dead*) things are filtered out, things are rendered and then *reset*. *Resetting* means deleting the actions that the objects chose inside those objects and some other variables for doing those action calculations. 

