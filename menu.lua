local composer = require("composer")
local scene = composer.newScene()
local widget = require("widget")

local backgroundMusic 
local volumeSliderMusic
local volumeSliderSounds
local volumeImageSounds

-- Function to handle music volume slider change
local function onVolumeSliderMusicChange(event)
    local volume = event.value / 100
    audio.setVolume(volume, {channel = 1})
end

-- Function to handle sounds volume slider change
local function onVolumeSliderSoundsChange(event)
    local volume = event.value / 100
    audio.setVolume(volume, {channel = 2})
end

-- Function to create the scene
function scene:create(event)
    local sceneGroup = self.view

    -- Create animated background with increased width
    local backgroundWidth = display.contentWidth * 2
    local background1 = display.newImageRect(sceneGroup, "pictures/backgroundMenu.jpg", backgroundWidth, display.contentHeight)
    background1.x = display.contentCenterX
    background1.y = display.contentCenterY

    local background2 = display.newImageRect(sceneGroup, "pictures/backgroundMenu.jpg", backgroundWidth, display.contentHeight)
    background2.x = display.contentCenterX + backgroundWidth
    background2.y = display.contentCenterY

    -- Function to move the background
    local function moveBackground()
        background1.x = background1.x - 2
        background2.x = background2.x - 2

        if background1.x + background1.contentWidth / 2 < 0 then
            background1.x = background2.x + backgroundWidth
        end
        if background2.x + background2.contentWidth / 2 < 0 then
            background2.x = background1.x + backgroundWidth
        end
    end

    Runtime:addEventListener("enterFrame", moveBackground)

    -- Add logo with padding from the top
    local logoPadding = 10
    local logo = display.newImageRect(sceneGroup, "pictures/logo.png", 350, 150)
    logo.x = display.contentCenterX
    logo.y = logo.height / 2 + logoPadding

    local buttonYOffset = 60

    -- Replace buttons with images
    local firstButtonTopPadding = 40
    local level1Button = display.newImageRect(sceneGroup, "pictures/level1Button.png", 200, 70)
    level1Button.x = display.contentCenterX
    level1Button.y = logo.y + logo.height / 2 + firstButtonTopPadding

    local level2Button = display.newImageRect(sceneGroup, "pictures/level2Button.png", 200, 70)
    level2Button.x = display.contentCenterX
    level2Button.y = level1Button.y + buttonYOffset

    local level3Button = display.newImageRect(sceneGroup, "pictures/level3Button.png", 200, 70)
    level3Button.x = display.contentCenterX
    level3Button.y = level2Button.y + buttonYOffset

    -- Create settings button
    local settingsButton = display.newImageRect(sceneGroup, "pictures/settingsButton.png", 200, 70)
    settingsButton.x = display.contentCenterX
    settingsButton.y = level3Button.y + buttonYOffset + settingsButton.height / 2 + 10
    sceneGroup:insert(settingsButton)

    -- Add event listeners for level buttons
    local function goToLevel1()
        composer.removeScene("level1")
        composer.gotoScene("level1")
    end

    local function goToLevel2()
        composer.removeScene("level2")
        composer.gotoScene("level2")
    end

    local function goToLevel3()
        composer.removeScene("level3")
        composer.gotoScene("level3")
    end

    level1Button:addEventListener("tap", goToLevel1)
    level2Button:addEventListener("tap", goToLevel2)
    level3Button:addEventListener("tap", goToLevel3)

    -- Add background music to the main menu
    backgroundMusic = audio.loadStream("music/music.mp3")

    -- Play background music on a separate channel
    audio.play(backgroundMusic, {loops = -1, channel = 1})

    local musicVolume = 1
    audio.setVolume(musicVolume, {channel = 1})

    -- Create settings window
    local settingsWindow = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, 200, 200)
    settingsWindow:setFillColor(0.5, 0.5, 0.5, 0.5)
    settingsWindow.isVisible = false

    -- Create background for settings window
    local settingsBackground = display.newImageRect(sceneGroup, "pictures/backgroundSettings.jpg", 220, 220)
    settingsBackground.x = display.contentCenterX
    settingsBackground.y = display.contentCenterY
    settingsBackground.isVisible = false

    -- Create volume slider for music
    volumeSliderMusic = widget.newSlider {
        x = display.contentCenterX,
        y = display.contentCenterY - 20,
        width = 150,
        value = 100,
        listener = onVolumeSliderMusicChange
    }
    volumeSliderMusic.isVisible = false
    sceneGroup:insert(volumeSliderMusic)

    -- Create volume slider for sounds
    volumeSliderSounds = widget.newSlider {
        x = display.contentCenterX,
        y = display.contentCenterY + 50,
        width = 150,
        value = 100,
        listener = onVolumeSliderSoundsChange
    }
    volumeSliderSounds.isVisible = false
    sceneGroup:insert(volumeSliderSounds)

    -- Create volume image for music
    local volumeImageMusic = display.newImageRect(sceneGroup, "pictures/music.png", 80, 40)
    volumeImageMusic.x = display.contentCenterX
    volumeImageMusic.y = display.contentCenterY - 50
    volumeImageMusic.isVisible = false

    -- Create volume image for sounds
    volumeImageSounds = display.newImageRect(sceneGroup, "pictures/sounds.png", 80, 40)
    volumeImageSounds.x = display.contentCenterX
    volumeImageSounds.y = display.contentCenterY + 20
    volumeImageSounds.isVisible = false

    -- Function to toggle visibility of settings window
    local function toggleSettingsWindow()
        local isVisible = not settingsWindow.isVisible
        settingsWindow.isVisible = isVisible
        settingsBackground.isVisible = isVisible
        volumeSliderMusic.isVisible = isVisible
        volumeSliderSounds.isVisible = isVisible
        volumeImageMusic.isVisible = isVisible
        volumeImageSounds.isVisible = isVisible
    end

    -- Event listener for settings button
    settingsButton:addEventListener("tap", toggleSettingsWindow)

    -- Function to handle touch event on settings window
    local function handleSettingsWindowTap(event)
        return true
    end
    settingsWindow:addEventListener("tap", handleSettingsWindowTap)

    -- Close settings window when touching outside of it
    local function closeSettingsWindow(event)
        if event.phase == "ended" then
            if settingsWindow.isVisible then
                toggleSettingsWindow()
            end
        end
        return true
    end
    Runtime:addEventListener("touch", closeSettingsWindow)
end

-- Function to destroy the scene
function scene:destroy(event)
    local sceneGroup = self.view

    -- Release background music resources
    if backgroundMusic then
        audio.stop()
        audio.dispose(backgroundMusic)
        backgroundMusic = nil
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("destroy", scene)

return scene