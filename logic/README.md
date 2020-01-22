# Terminology

`Stats` is a wrapped string-integer dictionary. The `Stats` wrapper class has the following methods: set, get, setIfHigher, mingle, clone, decrement.

A `Modifier` is an object, the exact type of which is specified by objects that would use it. 
The most relevant place where `Modifiers` are used is the table `Entity.baseModifiers`, that has fields for attack,armor, push, status and possibly resistances (not yet implemented fully). 

The `Modifier` class is a wrapper class around a field or a couple of field. (Possible just the general term for it, not an actual class).

