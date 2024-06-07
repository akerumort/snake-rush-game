local composer = require("composer")
local scene = composer.newScene()
local widget = require("widget")

local musicVolumeSlider
local soundVolumeSlider

function scene:create(event)
    local sceneGroup = self.view

    -- Create background
    local background = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
    background:setFillColor(0.8, 0.8, 0.8)

    -- Create music volume slider
    musicVolumeSlider = widget.newSlider {
        x = display.contentCenterX,
        y = display.contentCenterY - 50,
        width = 200,
        value = 100, -- Default volume value
        listener = function(event)
            local volume = event.value / 100
            audio.setVolume(volume, {channel = 1})
        end
    }
    sceneGroup:insert(musicVolumeSlider)

    -- Create sound volume slider
    soundVolumeSlider = widget.newSlider {
        x = display.contentCenterX,
        y = display.contentCenterY + 100,
        width = 200,
        value = 100, -- Default volume value
        listener = function(event)
            local volume = event.value / 100
            audio.setVolume(volume, {channel = 2})
        end
    }
    sceneGroup:insert(soundVolumeSlider)

    -- Load background music
    local backgroundMusic = audio.loadStream("backgroundMusic.mp3")
    audio.play(backgroundMusic, {loops = -1, channel = 1})
    

    -- Load game sounds
    local gameSound1 = audio.loadSound("gameSound1.wav")
    local gameSound2 = audio.loadSound("gameSound2.wav")
end

scene:addEventListener("create", scene)

return scene