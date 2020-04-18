return function()

    local p = { 1 }
    print(#p)
    local ch = Chain(p)
    print(ch)
    print(ch.handlers == p)

end