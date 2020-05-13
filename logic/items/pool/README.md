The idea of item pools is to have a global list of items one can draw them from and also have sublists of those items that would keep track what items are available and whether we need to refresh the pool. So there is the `Global Pool` and the `SubPools`.

There are 3 points I'll have to figure out:
1. The best way to store items and their amounts
2. How to retrieve them
3. How to update all subpools appropriately
4. How to set up item pools (without hard code)
5. What should happen when a pool has been exhausted? It is clear that the global pool should just go back to the initial state and also send all its subpools there, but what should a subpool do in this case?
6. How to manage chests e.g. dropping gold instead of items? Should I include the gold inside the pools or should I make separate pools for them and select a pool based on a roll?
7. Can the pools be affected dynamically?


Let's focus on retieval for starters.
