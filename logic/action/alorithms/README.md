# Overview

These files are responsible for the algorithm of **non-player action execution process**.


# The general algorithm

Here are the steps involved in that:

1. The `World` loops through all non-player reals and makes them `executeAction()`. 

2. Each real generates a list of possible `movs`, which are just directions they would like to do stuff into.

3. An `action` with that mov's `direction` set, walks this action's `chain`, which has the corresponding handlers.
For example, an `ATTACK_MOVE_ACTION` is going to try attacking (after checking if it should via the `shouldAttack` chian) and then going to try moving (same, after checking).

4. If another real is blocking their way of moving / attacking, they will pass them the turn. They will call `executeAction()` on that real. If it has already executed their action, though, the current `mov` will fail.

5. If all the `movs` have failed, the `failedAction` chain is traversed on the actor entity.