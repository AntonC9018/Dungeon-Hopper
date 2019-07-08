Weapon = Animated:new{}


function Weapon:listenAlpha()
    self.sprite:addEventListener("sprite", function(event)
        if event.phase == "began" then
            self.sprite:toFront()
            self.sprite.alpha = 1
        elseif event.phase == "ended" then
            self.sprite.alpha = 0
        end
    end)
end


function Weapon:orient(dir)

    if          dir[1] ==  1 then self.sprite.rotation = 0
       elseif   dir[2] ==  1 then self.sprite.rotation = 90
       elseif   dir[1] == -1 then self.sprite.rotation = 180
       elseif   dir[2] == -1 then self.sprite.rotation = 270 
       else self.sprite.rotation = 0 end       
end


function Weapon:play_audio()
    audio.play(self.audio['swipe'])
end

function Weapon:play_animation(t)
    self:anim(t, 'swipe')
end
