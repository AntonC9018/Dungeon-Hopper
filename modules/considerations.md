I don't know how to do it exactly, but the mod, id, registering content within the code idea clearly has to be improved. The fact that there are global functions like `registerEntity()` really bothers me.

What has to be done is some way of defining all the content inside a json file. Also, now that I think about it, the base modifiers should also be there. Actually, the entities can be defined entirely within that file, while their components may be defined within code and distributed among the designated folders.

But like json is not really a requirement. Lua is easier. I could use `.lua` instead of `.json`. It will be easier actually.

An example that already gives me trouble: the `Tile` is defined in `/base`, so it is saved at `EntityBases`, but it is treated as an entity in the code. The fact that there is no `Tile` at `Entities` means that the sprite is not loaded automatically. This can be fixed by treating the `Tile` as both a base and an entity, although the better fix would be to treat basic tiles as simply game objects so that we don't have to store meaningless for the logic items in the grid. `GameObject` versus `Entity` distinction has not been established thus far. There isn't a way of spawning `GameObjects` that are not also `Entities`, since they get into the grid lists and mess up the logic.

The `IceCube` is an entity, but it is never spawned on its own. It is used only as a complement for the freeze status effect. 

## Status Flavor

There must be a way of tweaking the exact repercussions of applying a status effect. Currently the status effects support stores. Take e.g. a spider (monkey). It applies the bind effect when it hops onto the player. However, the flavor of the status effect cannot be specified. The flavor in this case is whether it inverts the movement, blocks the movement or whatsoever. Currently, it just blocks it. Also, the spider has to set itself onto the store of the tinker of the status effect and the status effect itself has to constantly check whether or not the spider is there in its store. The good solution I see that is also scalable and reusable is to parametrize the statused decorator with an options object e.g. something like this:
```
{
    bind = { 
        whoBinds = Entity,  
        flavor = Flavors.PreventMovement    
    }
}
```
and pass it to the effect. 

Where do I store it? How to implement flavors exactly?

In this specific case flavors could be simply handlers. 
We store it on the tinker of the effect or the effect itself (probably the tinker, since it has to have a reference to the `whoBinds` property. This way the status effect will be the one responsible for setting the `whoBinds` up, the other code just has to pass it along, which means it doesn't have to be bound to the internals of the status effect, which is a good thing)