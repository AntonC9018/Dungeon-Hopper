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

2. After that, all game objects are asked to decide on their next action, and save it inside them (see action.lua for a list of action types). These calculations must not affect the grid (world) state.

3. Now all actions are executed in this order:
    1. *Player* actions
    2. All *Reals* but player
    3. *Explosions*
    4. *Floor* hazards
    5. finally, *Traps*

4. Destroyed (*dead*) things are filtered out, things are rendered and then *reset*. *Resetting* means deleting the actions that the objects chose inside those objects and some other variables for doing those action calculations. 


# Action Execution

The action execution process is pretty convoluted. 
Let's break it down into components to clarify how it works.

## Structure

Each `Acting NonPlayerReal` (`Acting` is a decorator) has a set of fields that reflect the action execution state:
1. `Acting.didAction` is set `true` once the action has been completely executed. The `game loop`, naturally, ignores them, so that the action is not repeated for many times over (remember, the `Acting` entities may make others act).
2. `Acting.doingAction` is set `true` once the `executeAction()` has been called, and `false` once exited.

Now we'll examine **the final event** structure once it comes out of `executeAction()` (assume `GeneralAlgo`). It does not 'come out' as such, the function always returns nothing. The final event is saved as `Acting.currentActionEvent`.

This event has a special structure, so let's call it the `EnclosingEvent`:
1. `EnclosingEvent.actor` - who does the action (this field is on each event as well).
2. `EnclosingEvent.action` - the action selected by the actor (this field is on each event as well).
3. `EnclosingEvent.propagate` - (boolean) really is of no practical value after the action. It is used to keep track of handlers while executing it (this field is on each event as well).
4. `EnclosingEvent.checkSuccess` - (boolean) same as 3, except not inherited.
5. `EnclosingEvent.success` - (boolean) comes paired with the next field.
6. `EnclosingEvent.successEvent` - The one event that actually occured, with the action and the direction, i.e.:
    1. Inherited `EnclosingEvent.successEvent.actor` and `EnclosingEvent.successEvent.action` and `EnclosingEvent.propagate`
    2. `EnclosingEvent.successEvent.direction` contains the actual final `dir` (see more on this in /algorithms)
    3. Wild diversity of more fields depending on the action type. E.g. for an `AttackAction`, these would be:
        1. `EnclosingEvent.successEvent.attack` 
        2. `EnclosingEvent.successEvent.push`
        3. `EnclosingEvent.successEvent.status` (none of these have been implemented yet)
        4. `EnclosingEvent.successEvent.targets` - a list of the `Target` objects, containing the reals actually hit. This list is formed by the weapon's spec or by taking the cell the actor is facing and getting the real out of it.
        5. `EnclosingEvent.successEvent.attackEvents` - list of events generated as a result of reals being attacked
        5. `EnclosingEvent.successEvent.pushEvents` - similarly, pushed
        5. `EnclosingEvent.successEvent.statusEvents` - similarly, statused

## Prerequisites for becoming an `Acting`

`Acting` is a decorator for entities. Entities decorated with `Acting` have the function `executeAction()` actually doing something interesting.


# Useful World Methods

## World