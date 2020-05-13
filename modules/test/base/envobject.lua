local EnvObject = class("EnvObject", Entity)

EnvObject.layer = Layers.real

Decorators.Start(EnvObject)
decorate(EnvObject, Decorators.Attackable)
decorate(EnvObject, Decorators.Killable)
decorate(EnvObject, Decorators.Pushable)
decorate(EnvObject, Decorators.Displaceable)
decorate(EnvObject, Decorators.DynamicStats)
decorate(EnvObject, Decorators.WithHP)

Retouchers.Attackableness.constant(EnvObject, Attackableness.IF_NEXT_TO)

return EnvObject