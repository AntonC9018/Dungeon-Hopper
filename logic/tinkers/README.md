`Tinkers` are functions that add handlers to the chains of an instance of an entity. They also may modify stats via the interaction with the DynamicStats handler.

This can be done manually too, but I hope these tinkers will provide an easier interface.

Not to be confused with `Retouchers`, which add handlers to the chain template of an entity class.


# SelfDetachingTinker

```lua
local function generator(tinker)
    return function(event)
        if event.something == 'something' then
            tinker.detach()
        end
    end
end

local tinker = utils.SelfDetachingTinker(entity, 'sampleChain', generator)

tinker.apply()  -- the function output by generator gets on the chain
tinker.detach() -- the function output by generator is taken off the chain
```