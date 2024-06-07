local composer = require("composer")
local scene = composer.newScene()

-- Function to create the scene
function scene:create(event)
    local sceneGroup = self.view

    -- Adding the background
    local background = display.newImageRect(sceneGroup, "pictures/backgroundGameOver.jpg", display.contentWidth, display.contentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    -- Game Over text
    local snakeImage = display.newImageRect(sceneGroup, "pictures/gameOver.png", 300, 150)
    snakeImage.x = display.contentCenterX
    snakeImage.y = display.contentCenterY - 110

    -- Adding background for the score text
    local scoreBackground = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY - 30, 100, 30)
    local paint = {
        type = "gradient",
        color1 = { 0.0, 0.75, 1.0 }, 
        color2 = { 1.0, 0.0, 0.5 },
        direction = "right"
    }
    scoreBackground.fill = paint

    -- Apple image
    local appleImage = display.newImageRect(sceneGroup, "pictures/appleGreen.png", 30, 30)
    appleImage.x = display.contentCenterX - 10
    appleImage.y = display.contentCenterY - 30

    -- Text showing the score
    self.scoreText = display.newText({
        parent = sceneGroup,
        text = "0",
        x = display.contentCenterX + 20,
        y = display.contentCenterY - 30,
        fontSize = 24
    })

    -- "Continue" button as an image
    local continueButton = display.newImageRect(sceneGroup, "pictures/continueButton.png", 200, 70)
    continueButton.x = display.contentCenterX
    continueButton.y = display.contentCenterY + 30

    -- "Return to Menu" button as an image
    local menuButton = display.newImageRect(sceneGroup, "pictures/returnButton.png", 200, 70)
    menuButton.x = display.contentCenterX
    menuButton.y = display.contentCenterY + 100

    -- Function to continue the game
    local function continueGame()
        local currentLevel = composer.getVariable("currentLevel") or "level1"
        composer.gotoScene(currentLevel, {effect = "fade", time = 500})
        timer.performWithDelay(500, function()
            local level = composer.getScene(currentLevel)
            if level and level.continueGame then
                level:continueGame()
            end
        end)
    end

    -- Function to return to the menu
    local function returnToMenu()
        composer.gotoScene("menu", {effect = "fade", time = 500})
    end

    -- Adding event listeners for the buttons
    continueButton:addEventListener("tap", continueGame)
    menuButton:addEventListener("tap", returnToMenu)
end

-- Function to show the scene
function scene:show(event)
    if event.phase == "did" then
        local playerScore = composer.getVariable("playerScore")
        self.scoreText.text = tostring(playerScore)
    end
end

-- Adding event listeners for the scene
scene:addEventListener("show", scene)
scene:addEventListener("create", scene)

return scene
