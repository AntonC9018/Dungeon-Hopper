# Chains

## What are chains?

The concept of a chain is essential in this project. They allow for flexible dynamic customizable algorithms, and easier splitting of code into components.

These chains are just a modified form of responsibility chains, called just 'chains' for convenience.

## Example

Essentially, a chain is just a series of handler functions that operate on an event. You may want to have a chain that, for example, checks for multiple things like this:

```lua

local APPLE = 1
local POTATO = 2
local PEAR = 3


local chain = Chain()

local function checkApple(event)
    if event.actor == APPLE then
        event.propagate = false
    end
end

local function checkPotato(event)
    if event.actor == POTATO then
        event.propagate = false
    end
end

-- register the handlers.
-- their number is unlimited.
-- in this case, we used just two
chain:addHandler(checkApple)
chain:addHandler(checkPotato)

-- now, test out our chain
local event = { actor = PEAR, propagate = true }

-- do a pass through all handlers in order.
-- the second argument indicates that we should stop if event.propagate is false
chain:pass(event, Chain.checkPropagate)

print(event.propagate)
-- >> true


-- test for an apple
event = { actor = APPLE, propagate = true }

chain:pass(event, Chain.checkPropagate)

print(event.propagate)
-- >> false
```

The beauty of this method, though, is that the chain may be modified on the fly!

```lua
event = { actor = APPLE, propagate = true }
chain:pass(event)
-- event.propagate = false

-- remove the handler that check apple
chain:removeHandler(checkApple)

event = { actor = APPLE, propagate = true }
chain:pass(event)
-- event.propagate = true
```

## Stop condition

One more thing, the stop condition may be programmed as a function. The `Chain.checkPropagate` you've seen previously is actually just a simple function. Here's how it's defined.

```lua
Chain.checkPropagate = function(event)
    return not event.propagate 
end
```

So, once `event.propagate` turns false, it will stop the propagation of the event, that is, the handlers after the one that made the stop condition be satisfied won't be executed.

## The order of execution

This feature is reserved for later and not yet implemented. This would be good to have, though.

Basically, each of the handlers should have a priority number and each time the chain is to be traversed, the handlers are to be sorted by priority. 

This feature may fix future bugs like a ring that e.g. gives you temporary damage immunity proccing while the character is invincible.

# Chain Templates

## Overview

Chain templates are a way of planning out a standart structure of a set of chains. 

## Example

```lua
local template = ChainTemplate() 

local function handler00(event) end
local function handler01(event) end
local function handler10(event) end

-- add a chain with 2 handlers
template:addChain('chain0')
template:addHandler('chain0', handler00)
template:addHandler('chain0', handler01)

-- add a chain with 1 handler
template:addChain('chain1')
template:addHandler('chain1', handler10)

-- add a chain with 0 handlers
template:addChain('chain2')

local chains = template:init()

inspect(chains)
-- {
--     chain0 = Chain,
--     chain1 = Chain,
--     chain2 = Chain
-- }

```

## Checking if a chain is set

For checking the existence of a chain, use `template.isSetChain(chainName)`