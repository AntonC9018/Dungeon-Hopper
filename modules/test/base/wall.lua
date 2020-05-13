
local Wall = class("Wall", Entity)
Wall.layer = Layers.wall

Decorators.Start(Wall)
decorate(Wall, Decorators.Diggable)
decorate(Wall, Decorators.WithHP)
decorate(Wall, Decorators.Attackable)
decorate(Wall, Decorators.Killable)
decorate(Wall, Decorators.DynamicStats)

Retouchers.Attackableness.no(Wall)

return Wall