# Overview

*Sequences* represent series of consequent *steps*, that is, action, an entity does.

Such entity is called *sequential* and is decorated with `Decorators.Sequential`.

Sequence is basically an array of such steps.

# Step

Step objects describe the action and the next step to do very precicely.

For example, take a simple skeleton.

It has 2 steps in its sequence:
1. Attack or Move
2. Stay idle

So the steps would look something like this:

```lua

step1 = 
{
    action = ATTACK_MOVE, -- try to attack, then to move
    mov = basic, -- require this predefined mov set
    failed = 1, -- in case all those fail, go back to step < 1 >
    success = 2 -- this option can be omitted, as steps are considered in sequence by default
}

step2 =
{
    action = NONE
}

```


Now take the case of, e.g., an armadillo:
1. Turn to player, stand still
2. Attack / Dig / Move
3. Don't do anything at all for 2 loops

The first step is more complex

``` lua

step1 = {
    -- this is one of the predefined check chains. You can create your own ones!
    action = SPECIAL(turnToPlayerChain) 
    success = 
        -- we've gotta chuck a checkOrthogonal function here
        -- to check whether the armadillo and the player
        -- are on one line / column
        -- for this, we create a custom chain on which we hang that function
        -- that chain in the end returns the next step in sequence
        -- so in this example the the next sequence step is not constant
        checkOrthogonalChain(2)
    -- in case this fails, e.g. we're frozen, remain at the 1st step
    failed = 1
}

step2 = {
    -- this one is simpler
    action = ATTACK_DIG_MOVE,
    -- for success we again need a custom chain
    success = checkNotMove(3),
    -- in case frozen, keep rolling
    failed = 2,
    -- also, we're invincible while rolling
    enter = addInfiniteArmor,
    -- and we shouldn't be while not rolling
    exit = removeInfiniteArmor
}

step3 = {
    action = NONE,
    repeat = 2, -- repeat this step 2 times before going to the next one
    success = 1 -- this and the failed can be omitted, as the sequence loops by default
}
```
