# Some new terminology on methods:

1. `be<Something>` methods refer to applying that something on the object after a series of checks that are able to interfere with that, not allowing the effects. For example, `beAttacked` does the attack after going through a series of handlers, e.g. blocking some of the damage, or stopping the event from propagating completely, e.g. by being invincible. 
2. `do<Something>` methods refer to applying the action on a previously unknown object. For example, `doAttack` method on `World` calculates which entity is going to be targeted and calls `beAttacked` on that enemy.
3. `apply<Something>` methods refer to those methods which call `do<Something>` on `World`.
4. `execute<Something>` is the same as the first one, except it is that object that does the action, that is, it is not the subject of the action. Foe example, `executeAttack`.

# How to use the decorators

Assume you have an entity you'd like to decorate. For that, just do the following:
```lua
local Decorators = require "logic.decorators"
Decorators.Start(MyEntity)        -- create the chain template on that object
Decorators.MyDecorator(MyEntity)  -- add stuff to that template, add stuff to your entity
```

### Here is a list of all available decorators:

## `Decorators.Start`

Adds *the chain template, the __emitter*  to your Entity class and the *handlers* list to the instances of your class (on their instantiation). 
> You must call this first if you want your next decorators to work at all.

## `Decorators.Attackable`

| Added chain | Automatically added handlers | Description |
|-------------|------------------------------| ----------- |
| `defence` | Reduction by base armor | This chain is traversed when your entity is about to take damage. These methods mild or amplify effects of the attack. |
| `beHit` | `takeHit`, `die` | Handlers of this chain are traversed after a hit has been assured to come through by the `defence` chain.  |

`takeHit` does damage to you (without applying status effects and pushing, see `Pushable` and `Statused` for that). 

`die` checks if the health is 0 and calls the `Entity.die()` if it is.

| Added method | Description |
| ------------ | ----------- |
| `beAttacked` | Get attacked by an entity |

## `Decorators.Attacking`

| Added chain | Automatically added handlers | Description |
|-------------|------------------------------| ----------- |
| `getAttack` | `setBase` | Used for creating the Attack object and modifying it with e.g. more damage |
| `attack`    | `applyAttack`, `applyPush`, `applyStatus` | Used for doing the Attack and applying push and the related status effects |

| Added method | Description |
| ------------ | ----------- |
| `executeAttack` | Attack an enemy, according to the action object |


## `Decorators.Pushable`

| Added chain | Automatically added handlers | Description |
|-------------|------------------------------| ----------- |
| `checkPush` | `checkPush` | |
| `applyPush` | `applyPush` | |

| Added method | Description |
| ------------ | ----------- |
| `executePush`| |

## `Decorators.Explodable`
## `Decorators.InvincibleAfterAttack`
## `Decorators.Statused`
## `Decorators.Moving`