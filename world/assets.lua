-- The asset manager. 
--
-- Used for registering and storing assets for each type of object.
-- 1. configs for sprites
-- 2. configs for audio


local Assets = class('Assets')

Assets.algorithms = require('engine.assets')

function Assets:__construct()
    self.spriteConfigs = {}
    self.audioConfigs = {}
    self.loadedSprites = {}
    self.loadedAudio = {}
end

function Assets:getObjectType(gameObject)
    -- leave it at that for now
    return class.name(gameObject)
end

function Assets:registerGameObjectType(type)
    self.spriteConfigs[type] = 
        self.getSpriteConfigByType(type)

    self.audioConfigs[type] = 
        self.getAudioConfigByType(type)
end

function Assets:loadAll()
    for type, config in pairs(self.spriteConfigs) do
        self.loadedSprites[type] = 
            self.algorithms.loadSprite(config)
    end

    for type, config in pairs(self.audioConfigs) do
        self.loadedAudio[type] = 
            self.algorithms.loadAudio(config)
    end
end


Assets.getSpriteConfigByType = function(type)

    -- for now, use a simpler version of assets.
    -- just include the path to image
    -- TODO: make the system full-fledged

    -- convert type to lower-case
    local name = string.lower(type)

    return { image = "assets\\"..name..".png" }
end


-- ignore the audio for now
Assets.getAudioConfigByType = function(type)
    return {}
end


return Assets