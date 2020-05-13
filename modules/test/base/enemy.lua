local BasicEnemy = class("BasicEnemy", Entity)

BasicEnemy.layer = Layers.real

Decorators.Start(BasicEnemy)
decorate(BasicEnemy, Decorators.Acting)
decorate(BasicEnemy, Decorators.Sequential)
decorate(BasicEnemy, Decorators.Killable)
decorate(BasicEnemy, Decorators.Ticking)
decorate(BasicEnemy, Decorators.Attackable)
decorate(BasicEnemy, Decorators.Attacking)
decorate(BasicEnemy, Decorators.Moving)
decorate(BasicEnemy, Decorators.Pushable)
decorate(BasicEnemy, Decorators.Statused)
decorate(BasicEnemy, Decorators.WithHP)
decorate(BasicEnemy, Decorators.Displaceable)
decorate(BasicEnemy, Decorators.DynamicStats)
Retouchers.Algos.general(BasicEnemy)

return BasicEnemy