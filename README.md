---
id: home
title: What is this?
---

It's a game based on mechanics of NecroDancer. Right now I'm developing the logic for it. I've done an attempt at this previously, but the project had gone out of hand rather quickly. You may find the old code in older versions of the repo.

The idea with this project isn't to replicate the original **Crypt of the Necrodancer**, but to create a scalable open-source game based on the same mechanics, so that it could be easily extended by community mods. If you do not know what this 'Necrodancer' game is, I highly recommend you check it out. It is awesome.

See docs! https://antonc9018.github.io/Dungeon-Hopper-Docs/

## At a very high level

The game pretty much follows the **MVVM** (Model - View - ViewModel) pattern. This basically means that the game logic is totally decoupled from all the drawing done to the screen. The `Model` is represented by the game logic. All stuff explained in docs thus far is pure logic. The `View` and `ViewModel` are still in their infancy and so are not mentioned in the documents. The system currently just displays and 'teleports' the sprites around, placing them at the necessary location on the screen. You may find the assets (just single pngs, no sprite sheets) in the `/assets` folder of the repo. 

The existence of this sort of paradigm allows us to easily switch the underlying engine if needed, as long as it supports lua as its scripting language.

As the graphics improve over time, its API will be documented as well.

## The weird imports

Let the weird imports not throw you off!

There is a special syntax for requires:
* the `@` turns into `logic.`
* a `.` at the front turns into `modules.MOD_NAME.`, where `MOD_NAME` is the name of the mod folder you're working with.

For example, `require '@items.item'` will in fact do `require 'logic.items.item'`. 

## Dependencies

Among dependencies, there is the [Luaoop class library](https://github.com/ImagicTheCat/Luaoop) by ImagicTheCat(classes are used extensively throughout the project) and [inspect](https://github.com/kikito/inspect.lua) by kikito (dev dependency, useful for debugging). See their github repos for docs.

[Vec](https://github.com/AntonC9018/Dungeon-Hopper/blob/master/lib/vec.lua) and [Emitter](https://github.com/AntonC9018/lua-event-emitter) are also used but are not documented in these docs (have not been thus far). [Chains](https://antonc9018.github.io/Dungeon-Hopper-Docs/docs/chains) are both used extensively and documented here.

## Progress

List of things already implemented:
1. Chains and Chain Templates (Implemented sorting based on priority)
2. High-level Grid
3. General action execution algorithm for player and non-player entities
4. Attacking and Attackable decorators
5. Sequences
6. Weapon target selection logic

List of important things not implemented:
1. Basic graphics +
2. Pushing +
3. Moving +
4. Sequential decorator +
5. Ticking +
6. HP +
6. Basic Controls +

List of less significant things not implemented:
1. Digging, walls +
2. Traps +
3. Special tiles +
4. Explosions + 
5. Environment Objects +
6. Status effects +
7. Projectiles +
8. Items +
10. Better controls
9. Better renderer

List of dreams:
1. World generation +
2. Enemy pools +
3. Shopping
4. Secrets
5. Music
6. Lobby
7. Menu