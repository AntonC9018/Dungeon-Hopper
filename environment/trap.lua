Trap = Animated:new()


function Trap:bePushed()
    self.sprite:setFrame(2)
    self:playAudio('action')
end


function Trap:reset()
    self.sprite:setFrame(1)
    self.active = true
end



