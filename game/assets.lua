local AssetManager = class('AssetManager')

-- render pixel graphics correctly
display.setDefault('magTextureFilter', 'nearest')
display.setDefault('minTextureFilter', 'nearest')

function AssetManager:loadAssets()
    local json = require('json')

    local assets = json.decodeFile(system.pathForFile('configs/assets.json', system.ResourceDirectory ))

    for k, v in pairs(assets) do

        self[k] = {}

        -- load the image sheet
        if v.sheet then
            self[k].sheet = 
                graphics.newImageSheet(
                    '/assets/image_sheets/'..v.sheet.path, 
                    v.sheet.options
                )
        else
            error('No sheet')
        end

        -- load the audio
        if v.audio then
            self[k].audio = {}
            for _k, _v in pairs(v.audio) do
                self[k].audio[_k] = audio.loadSound('/assets/audio/'.._v)
            end
        else
            self.audio = {}
        end
    end
end

return AssetManager