# Decorators

Decorators are used extensively throughout the project. They act pretty much like individual components that are used to augment your entity **classes**. They are **not dynamic**, that is, they *cannot* be added on already instantiated objects. Nevertheless, the chains they add *are* dynamic and can be modified at any time.

## Some new terminology on methods:

1. `be<Something>` methods refer to applying that something on the object after a series of checks that are able to interfere with that, not allowing the effects. For example, `beAttacked` does the attack after going through a series of handlers, e.g. blocking some of the damage, or stopping the event from propagating completely, e.g. by being invincible. 
2. `do<Something>` methods refer to applying the action on a previously unknown object. For example, `doAttack` method on `World` calculates which entity is going to be targeted and calls `beAttacked` on that enemy.
3. `apply<Something>` methods refer to those methods which call `do<Something>` on `World`.
4. `execute<Something>` is the same as the first one, except it is that object that does the action, that is, it is not the subject of the action. Foe example, `executeAttack`.


## How to use the decorators

Assume you have an entity class you'd like to decorate. For that, just do the following:
```lua
local Decorators = require "logic.decorators.decorators"
local Decorator = require "logic.decorators.decorator"
Decorators.Start(MyEntity)                 -- create the chain template on that object
Decorator.decorate(MyEntity, MyDecorator)  -- add stuff to that template, add stuff to your entity
```
> NOTE: You cannot decorate instances! You can apply the decorators only to classes!
> So, in order to, e.g., stop your entities from taking damage while they are in some phase of their lifecycle, use some other logic, e.g. adding handlers to chains. 
> In our example, this would mean stopping event from propagating in `myEntity.chains.defence` chain by adding a nullifier handler to it 


## What do decorators do?

In short, Decorators add particular behaviour to your classes.

They all share these 3 basic stages


### *Decoration*

This is the moment the `Decorator.decorate` method is called. It works by taking the list of `affectedChains` from the decorator class and adding them to the `chainTemplate` of your entity class. 

For example, such chains would create a chain named `myCheck` on the entity class's `chainTemplate` and add the handlers `checkHandler1` and `checkHandler2` onto it. After that, it would create the chain `myExecute`, adding just the `executeHandler1` to it and, finally, it would just create the new `myEmpty` chain on the `chainTemplate`, without adding any handler onto it.:
```lua
MyDecorator.affectedChains = {
    { 'myCheck',   { checkHandler1, checkHandler2 } },
    { 'myExecute', { executeHandler1 }              },
    { 'myEmpty',   {}                               }
}
```  

The decorator also gets pushed to the `myEntityClass.decoratorsList` for the further initialization stage.


### *Initialization*

The initialization stage takes place when your entity class is being instantiated. At this time, all Decorators saved on `myEntityClass.decoratorsList` are getting instantiated and their `myDecorator:__construct()` methods called. This is the moment they should instantiate things on the instance, if they need to.


### *Activation*

*Activation* as such implies the decorator's method `myDecorator:activate()` getting called. Typically, it would have the instance as the first parameter. 

A fair amount of predefined decorators use the **checkApplyCycle** as their activation. The idea is straightforward: they would do a pass over their `check` chain and, if it were successful, that is, if it went through all its handlers without getting interrupted, the `do` chain is going to be passed too. Otherwise, it wouldn't. See *logic.decorators.utils*.

For example, take `Decorators.Attacking`. It adds two chains: `getAttack`, which is the `check` (or `get`) chain, and `attack`, which is the `do` chain. 


# List of basic decorators

## `Start`

Adds the *chainTemplate* and *decoratorsList* to your Entity class. 

> This is technically not a decorator, but just an ordinary function.

> You must call this first if you want your next decorators to work at all.


## `Acting`

Enables the entity to apply action that were saved as `Entity.nextAction` during the `computeAction` beat stage.

| Added chain     | Automatically added handlers | Description |
|-----------------|------------------------------| ----------- |
| `checkAction`   | -                            | TODO        |
| `action`        | -                            | contains the action algorithm(s)|
| `failAction`    | -                            | traversed if no action succeeded|
| `succeedAction` | -                            | traversed if an action succeeded|

**Shorthand activation**: `Entity.executeAction()`


## `Attackable`

This decorator enables the entity to take normal hits.

| Added chain | Automatically added handlers | Description |
|-------------|------------------------------| ----------- |
| `defence`   | Reduction by base armor      | This chain is traversed when your entity is about to take damage. These methods mild or amplify effects of the attack. |
| `beHit`     | `takeHit`, `die`             | Handlers of this chain are traversed after a hit has been assured to come through by the `defence` chain.  |

`takeHit` does damage to you (without applying status effects and pushing, see `Pushable` and `Statused` for that). 
> `Entity.takeHit()` is the shorthand for `Entity.decorators.WithHP.activate()` 

`die` checks if the health is 0 and calls the `Entity.die()` if it is.
> `Entity.die()` is the shorthand for `Entity.decorators.Killable.activate()`

**Shorthand activation**: `Entity.beAttacked()`


## `Attacking`

This decorator enables the entity to do normal hits.

| Added chain | Automatically added handlers | Description |
|-------------|------------------------------| ----------- |
| `getAttack` | `setBase`, `getTargets`      | Used for creating the Attack object and modifying it with e.g. more damage |
| `attack`    | `applyAttack`, `applyPush`, `applyStatus` | Used for doing the Attack and applying push and the related status effects |

**Shorthand activation**: `Entity.executeAttack()`


## `AttackableOnlyWhenNextToAttacker`
TODO: THIS ONE IS QUESTIONABLE AND WILL BE REMOVED


## `Bumping`
| Added chain | Automatically added handlers | Description |
|-------------|------------------------------| ----------- |
| `failAction`| `bump`                       |             |


## `Explodable`
Enables the entity to be exploded


## `InvincibleAfterHit`
Makes the entity invincible for 2 loop after it's taken a hit


## `Killable`

| Added chain | Automatically added handlers | Description |
|-------------|------------------------------| ----------- |
| `checkDie`  | -                            |             |
| `die`       | `die` | sets `entity.dead` to `true` and calls `world:removeDead()`|

**Shorthand activation**: `Entity.die()`


## `Moving`
Enables entity to displace.

| Added chain   | Automatically added handlers | Description |
|---------------|------------------------------| ----------- |
| `getMove`     | `getBaseMove`                |             |
| `move`        | `displace`                   |             |

**Shorthand activation**: `Entity.executeMove()`


## `PlayerControl`
Converts direction to an action for the player

**Shorthand activation**: `Player.generateAction()`, just for players


## `Pushable`

Enables the entity to be pushed

| Added chain   | Automatically added handlers | Description |
|---------------|------------------------------| ----------- |
| `checkPush`   | `checkPush`                  |             |
| `executePush` | `executePush`                |             |

**Shorthand activation**: `Entity.bePushed()`


## `Sequential`

Enables the entity to calculate their next action. Uses a `Sequence` object to keep track of the current step.

The `Sequence` is instantiated and set on the entity as `Entity.sequence`.

**Shorthand activation**: `Entity.calculateAction()`


## `Statused`

Makes the entity vulnerable to status effects. Status effects are being frozen, stunned, on fire, poisoned and so on.

| Added chain   | Automatically added handlers | Description |
|---------------|------------------------------| ----------- |
| `checkStatus` | `checkStatus`                |             |
| `applyStatus` | `applyStatus`                |             |

**Shorthand activation**: `Entity.beStatused()`


## `Ticking`

Allows the entity to reset some fields at the `tick` phase.

| Added chain   | Automatically added handlers | Description |
|---------------|------------------------------| ----------- |
| `tick`        | `resetBasic`                 |             |

resetBasic does:
```lua
actor.didAction = false
actor.doingAction = false
actor.nextAction = nil
actor.enclosingEvent = nil
```

TODO: resetting of action should be done at the `reset` stage instead.

**Shorthand activation**: `Entity.tick()`


## `WithHP`

Adds an `hp` object to the player. Makes them `takeDamage` on activation.

**Shorthand activation**: `Entity.takeDamage()`


# Combos

As many of the entities would use the same decorators, applying them over and over is error prone and can be simplified. This is why `Combos` exist. 

`Combos` are essentially functions that apply a predefined set of decorators at once. For example, this:

```lua
Combos.BasicEnemy(Enemy)
```

would substitute this:

```lua 
Decorators.Start(Enemy)
decorate(Enemy, Decorators.Acting)
decorate(Enemy, Decorators.Sequential)
decorate(Enemy, Decorators.Killable)
decorate(Enemy, Decorators.Ticking)
decorate(Enemy, Decorators.Attackable)
decorate(Enemy, Decorators.Attacking)
decorate(Enemy, Decorators.Bumping)
decorate(Enemy, Decorators.Explodable)
decorate(Enemy, Decorators.Moving)
decorate(Enemy, Decorators.Pushable)
decorate(Enemy, Decorators.Statused)
decorate(Enemy, Decorators.WithHP)
Enemy.chainTemplate:addHandler('action', GeneralAlgo)
```

This:

```lua
Combos.Player(PlayerClass)
```

would substitute this:

``` lua
Decorators.Start(Player)
decorate(Player, Decorators.Ticking)
decorate(Player, Decorators.Killable)
decorate(Player, Decorators.Acting)    
decorate(Player, Decorators.Attackable)
decorate(Player, Decorators.Attacking) 
decorate(Player, Decorators.Bumping)  
decorate(Player, Decorators.Explodable)
decorate(Player, Decorators.Moving)  
decorate(Player, Decorators.Pushable) 
decorate(Player, Decorators.Statused) 
decorate(Player, Decorators.InvincibleAfterHit)
decorate(Player, Decorators.PlayerControl)
decorate(Player, Decorators.WithHP)
Player.chainTemplate:addHandler('action', PlayerAlgo)
```