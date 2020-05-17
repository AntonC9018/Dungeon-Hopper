local Generator = require 'world.generation'

return function()    
    local generator = Generator(60, 60)
    generator:start()
    generator:addNode(1)
    generator:addNode(1)
    generator:addNode(2)
    generator:addNode(2)
    generator:addNode(3)
    if generator:generate() then
        print('Success')
        generator:print()
    else
        print('Generation unsuccessful')
    end
end