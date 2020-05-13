# Tinkers

`Tinkers` are objects that help to add handlers onto the chains of an instance of an entity. They also may modify stats via the interaction with the DynamicStats decorator. In addition, `Tinkers` provide a simple interface of removing these handlers off the target and restoring initial stats.

There are 2 classes: the `Tinker` class is responsible for handlers and the `StatsTinker` class is responsible for stats and stat handlers.

## Terminology

The process of adding a handler onto a chain is called **tinking** (an abbreviation of *tinkering*). Similarly, the process of removing one is called **untinking**.

The process of activating a tinker is called **tinking** too, but refers to all tinking done by a tinker. The process of deactivating it is refered to as the **untinking** of a tinker.

The same terminology by extension also applies to modifying and restoring stats via the `StatsTinker`. So, the process of adding a stat may be called **stat-tinking**.


## SelfUntinkingTinker

```lua
local function generator(tinker)
    return function(event)
        if event.something == 'something' then
            tinker.untink()
        end
    end
end

local tinker = utils.SelfUntinkingTinker(entity, 'sampleChain', generator)

tinker.tink()   -- the function output by generator gets onto the chain
tinker.untink() -- the function output by generator is taken off the chain
```



## Example
```lua
local Move = require '@tinkers.components.move'
local Tinker = require '@tinkers.tinker'
local StatsTinker = require '@tinkers.stattinker'
local DynamicStats = require '@decorators.dynamicstats'
local StatTypes = DynamicStats.StatTypes
local Stats = require '@stats.stats'

local tinkElements = {
    Move.afterAttackIfNotFirstPiece
    -- , ...
}

local tinker = Tinker(tinkElements)


local statChanges = {
    { StatTypes.Attack, Stats({ damage = 1, pierce = 1 }) },
    { StatTypes.PushRes, -1 },
    { StatTypes.Push, 'distance', 1 },
    { StatTypes.Push, function(event) event.stats.distance = 5 end}
}

local statsTinker = StatsTinker(statChanges)


local Item = class('Item')

function Item:onPickup(entity)
    tinker:tink(entity)
    statsTinker:tink(entity)
end

function Item:onDrop(entity)
    tinker:untink(entity)
    statsTinker:untink(entity)
end

return Item
```