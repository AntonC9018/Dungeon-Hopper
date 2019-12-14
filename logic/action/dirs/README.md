# Overview

This folder includes `dirs algorithms`, although the name of the folder is, simply, *dirs*.

`dirs` means a set of possible action directions, while a `dirs algorithm` is an algorithm which figures out what directions to include in that set.

Movs are, in essence, applicable only to the `GeneralAlgo`, which works with a set of directions. However, if you wish to implement some logic like that of a harpy, you have the following possibilities:

1. Mess around with the event, that is, use the `Special` event where you can define a custom control chain, and in the `dirs` you would actually store not the directions for the harpy to move, but the desirable points around the player. Then through that chain you would handle those points. This way you'd be able to use the `GeneralAlgo`, but kind of through a hack. It also lacks the possibility to generate points on the fly, which is good for the harpy kind of logic.

2. Define a new `Algo` and use that instead of the `GeneralAlgo`. Make it follow your custom logic instead, that is, figure out the closest free point to the player in e.g. radius of 3 around the harpy and then hop onto that spot if it is free. If it is not, repeat, until all points have been accounted for. You don't have to generate a whole list of points this way. You can just walk around the player in some e.g. circular fashion and get next points this way. 

However, if your entity follows a more common pattern, that is, moves in some direction and/or does something, it is recommended to use the `GeneralAlgo` while providing a custom chain to your `Special` action.

For example, consider bombers. For bombers, your `Special` chain will have the following handlers.
1. if in the targeted cell there is a player, explode ->
2. else try moving to that spot

So nothing too crazy here.

Bear in mind, though, that the `GeneralAlgo` supports just one action at a time!
