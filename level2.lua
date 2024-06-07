local composer = require("composer")
local scene = composer.newScene()
local snakeModule = require("snake")
local dataManager = require("dataManager")

local cellSize = 20
local minDistance = 40
local minDistanceFromSnake = 80
local margin = 2 * cellSize

local food
local snake
local moveTimer
local bombTimer
local bombs = {}
local maxBombs = 3
local foodCount = 0
local highScore = 0
local background
local foodCountText
local highScoreText
local pauseOverlay
local infoBg

local currentLevel = "level2"

local explosionSound = audio.loadSound("music/explosion.wav")
local eatingSound = audio.loadSound("music/eating.mp3")

local swipeStartX, swipeStartY

-- Function to handle swipe gestures
local function onScreenSwipe(event)
    if event.phase == "began" then
        swipeStartX = event.x
        swipeStartY = event.y
    elseif event.phase == "ended" then
        local deltaX = event.x - swipeStartX
        local deltaY = event.y - swipeStartY

        if math.abs(deltaX) > math.abs(deltaY) then
            if deltaX > 0 then
                if snake.direction ~= "left" then
                    snake.nextDirection = "right"
                end
            else
                if snake.direction ~= "right" then
                    snake.nextDirection = "left"
                end
            end
        else
            if deltaY > 0 then
                if snake.direction ~= "up" then
                    snake.nextDirection = "down"
                end
            else
                if snake.direction ~= "down" then
                    snake.nextDirection = "up"
                end
            end
        end
    end
    return true
end

-- Function to create food
local function createFood()
    local x = math.random(1, math.floor(display.contentWidth / cellSize) - 2) * cellSize
    local y = math.random(3, math.floor(display.contentHeight / cellSize) - 4) * cellSize
    if food then food:removeSelf() end
    food = display.newImageRect(scene.view, "pictures/appleRed.png", cellSize, cellSize)
    food.x = x
    food.y = y
end

-- Function to clear bombs
local function clearBombs()
    for i = #bombs, 1, -1 do
        if bombs[i] then
            bombs[i]:removeSelf()
            table.remove(bombs, i)
        end
    end
end

-- Function to check if the position is valid for placing bombs
local function isPositionValid(x, y)
    -- Check for minimum distance between bombs
    for _, bomb in ipairs(bombs) do
        local dx = bomb.x - x
        local dy = bomb.y - y
        if math.sqrt(dx * dx + dy * dy) < minDistance then
            return false
        end
    end
    -- Check for minimum distance from the snake
    local head = snake.segments[1]
    if head then
        local dx = head.x - x
        local dy = head.y - y
        if math.sqrt(dx * dx + dy * dy) < minDistanceFromSnake then
            return false
        end
    end
    return true
end

-- Function to create bombs
local function createBombs()
    clearBombs()
    local attempts = 0
    for i = 1, maxBombs do
        local x, y
        repeat
            x = math.random(margin, display.contentWidth - margin - cellSize)
            y = math.random(margin + 40, display.contentHeight - margin - cellSize)
            x = math.floor(x / cellSize) * cellSize
            y = math.floor(y / cellSize) * cellSize
            attempts = attempts + 1
        until isPositionValid(x, y) or attempts > 100

        if attempts <= 100 then
            local bomb = display.newImageRect(scene.view, "pictures/bomb.png", cellSize, cellSize)
            bomb.x = x
            bomb.y = y
            table.insert(bombs, bomb)
        end
    end
end

-- Function to play explosion animation and sound
local function playExplosion(x, y)
    audio.play(explosionSound, {channel = 2}) 
    local explosionGroup = display.newGroup()
    scene.view:insert(explosionGroup)

    for i = 1, 16 do
        local frame = display.newImageRect(explosionGroup, "pictures/explosion/" .. i .. ".png", cellSize * 4, cellSize * 4)
        frame.x = x
        frame.y = y
        frame.isVisible = false
    end

    local frameIndex = 1

    local function showNextFrame()
        if frameIndex > 1 then
            explosionGroup[frameIndex - 1].isVisible = false
        end

        if frameIndex <= 16 then
            explosionGroup[frameIndex].isVisible = true
            frameIndex = frameIndex + 1
            timer.performWithDelay(100, showNextFrame)
        else
            explosionGroup:removeSelf()
        end
    end

    showNextFrame()
end

-- Function to check for bomb collisions
local function checkBombCollision()
    local head = snake.segments[1]
    for _, bomb in ipairs(bombs) do
        if head.x == bomb.x and head.y == bomb.y then
            playExplosion(bomb.x, bomb.y)
            scene:resetSnake()
            break
        end
    end
end

-- Function to pause the game
local function pauseGame()
    if moveTimer then
        timer.pause(moveTimer)
    end

    if bombTimer then
        timer.pause(bombTimer)
    end

    if snake then
        for _, segment in ipairs(snake.segments) do
            segment.isVisible = false
        end
    end

    pauseOverlay = display.newGroup()

    local overlayRect = display.newRect(pauseOverlay, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
    overlayRect:setFillColor(0, 0, 0, 0.5)

    local pauseButton = display.newImageRect(pauseOverlay, "pictures/gamePausedLvl2Button.png", 350, 130)
    pauseButton.x = display.contentCenterX
    pauseButton.y = display.contentCenterY - 80

    local resumeButton = display.newImageRect(pauseOverlay, "pictures/resumeLvl2Button.png", 200, 70)
    resumeButton.x = display.contentCenterX
    resumeButton.y = display.contentCenterY

    local menuButton = display.newImageRect(pauseOverlay, "pictures/returnLvl2Button.png", 200, 70)
    menuButton.x = display.contentCenterX
    menuButton.y = display.contentCenterY + 60

    -- Function to resume the game
    local function resumeGame()
        display.remove(pauseOverlay)
        pauseOverlay = nil

        if snake then
            for _, segment in ipairs(snake.segments) do
                segment.isVisible = true
            end
        end

        if moveTimer then
            timer.resume(moveTimer)
        end

        if bombTimer then
            timer.resume(bombTimer)
        end
    end

    -- Function to return to the main menu
    local function returnToMenu()
        display.remove(pauseOverlay)
        pauseOverlay = nil
        composer.gotoScene("menu", {effect = "fade", time = 500})
    end

    resumeButton:addEventListener("tap", resumeGame)
    menuButton:addEventListener("tap", returnToMenu)
end

-- Function to initialize the scene
function scene:create(event)
    local sceneGroup = self.view
    foodCount = 0

    local data = dataManager.load()
    highScore = data.level2.highScore or 0

    local gridWidth = math.floor(display.contentWidth / cellSize) * cellSize
    local gridHeight = math.floor(display.contentHeight / cellSize) * cellSize

    local offsetX = (display.contentWidth - gridWidth) / 2
    local offsetY = (display.contentHeight - gridHeight) / 2 - 10

    -- Load background
    background = display.newImageRect(sceneGroup, "pictures/backgroundLvl2.jpg", gridWidth, gridHeight)
    background.anchorX = 0
    background.anchorY = 0
    background.x = offsetX
    background.y = offsetY

    -- Function to draw grid
    local function drawGrid()
        for x = 0, gridWidth - cellSize, cellSize do
            for y = 40, gridHeight - cellSize, cellSize do
                local cell = display.newRect(sceneGroup, x + offsetX, y + offsetY, cellSize, cellSize)
                cell:setFillColor(0, 0, 0, 0)
            end
        end
    end

    drawGrid()

    -- Create a group for the text counters
    local textGroup = display.newGroup()
    sceneGroup:insert(textGroup)

    -- Create a single rectangle as the background for the counters
    infoBg = display.newRect(textGroup, display.contentCenterX, 10, display.contentWidth, 40)
    infoBg:setFillColor(0, 1, 0)

    foodCountText = display.newText({
        parent = textGroup,
        text = "Food: " .. foodCount,
        x = display.contentWidth * 0.15,
        y = 20,
        font = native.systemFontBold,
        fontSize = 20
    })
    foodCountText:setFillColor(1, 1, 1)

    highScoreText = display.newText({
        parent = textGroup,
        text = "High Score: " .. highScore,
        x = display.contentWidth * 0.75,
        y = 20,
        font = native.systemFontBold,
        fontSize = 20
    })
    highScoreText:setFillColor(1, 1, 1) 

    snake = snakeModule.createSnake(self)
    snake:reset()

    createFood()

    -- Function to move the snake
    local function moveSnake()
        snake:move()
        if snake:checkFoodCollision(food) then
            audio.play(eatingSound)
            foodCount = foodCount + 1
            foodCountText.text = "Food: " .. foodCount
            createFood()
        end
        checkBombCollision()
    end

    moveTimer = timer.performWithDelay(100, moveSnake, -1)
    bombTimer = timer.performWithDelay(2000, createBombs, 0)
    createBombs()

    -- Add swipe handler
    Runtime:addEventListener("touch", onScreenSwipe)

    -- Function to handle tapping on the pause area
    local function onPauseAreaTap(event)
        if event.phase == "began" then
            pauseGame()
        end
        return true
    end

    infoBg:addEventListener("touch", onPauseAreaTap)

    -- Cleanup function
    function scene:destroy(event)
        if moveTimer then
            timer.cancel(moveTimer)
            moveTimer = nil
        end

        if bombTimer then
            timer.cancel(bombTimer)
            bombTimer = nil
        end

        clearBombs()

        if food then
            food:removeSelf()
            food = nil
        end

        if snake then
            snake:clear()
        end

        -- Remove swipe handler
        Runtime:removeEventListener("touch", onScreenSwipe)

        -- Remove tap handler for the counter area
        infoBg:removeEventListener("touch", onPauseAreaTap)
    end

    scene:addEventListener("destroy", scene)
end

-- Function to reset the snake when the game is over
function scene:resetSnake()
    if foodCount > highScore then
        highScore = foodCount
        highScoreText.text = "High Score: " .. highScore
        local data = dataManager.load()
        data.level2.highScore = highScore
        dataManager.save(data)
    end

    composer.setVariable("foodCount", foodCount)
    composer.setVariable("playerScore", foodCount)
    composer.setVariable("currentLevel", currentLevel)

    self:clearObjects()

    composer.gotoScene("gameover", {effect = "fade", time = 500})

    foodCount = 0
    foodCountText.text = "Food: " .. foodCount
end

-- Function to clear game objects
function scene:clearObjects()
    if moveTimer then
        timer.cancel(moveTimer)
        moveTimer = nil
    end

    if bombTimer then
        timer.cancel(bombTimer)
        bombTimer = nil
    end

    clearBombs()

    if food then
        food:removeSelf()
        food = nil
    end

    if snake then
        snake:clear()
    end
end

-- Function to continue the game
function scene:continueGame()
    self:clearObjects()
    snake:reset()
    createFood()

    -- Function to move the snake
    local function moveSnake()
        snake:move()
        if snake:checkFoodCollision(food) then
            audio.play(eatingSound, {channel = 2})
            foodCount = foodCount + 1
            foodCountText.text = "Food: " .. foodCount
            createFood()
        end
        checkBombCollision()
    end

    moveTimer = timer.performWithDelay(100, moveSnake, -1)
    bombTimer = timer.performWithDelay(3000, createBombs, 0)
    createBombs()
end

-- Function to handle key events
function scene:key(event)
    if event.phase == "down" then
        if event.keyName == "escape" then
            if not pauseOverlay then
                pauseGame()
            end
        elseif not pauseOverlay then
            if event.keyName == "up" and snake.direction ~= "down" then
                snake.nextDirection = "up"
            elseif event.keyName == "down" and snake.direction ~= "up" then
                snake.nextDirection = "down"
            elseif event.keyName == "left" and snake.direction ~= "right" then
                snake.nextDirection = "left"
            elseif event.keyName == "right" and snake.direction ~= "left" then
                snake.nextDirection = "right"
            end
        end
    end
    return false
end

-- Function to handle scene showing
function scene:show(event)
    if event.phase == "did" then
        Runtime:addEventListener("key", self)
        Runtime:addEventListener("touch", onScreenSwipe)
    end
end

-- Function to handle scene hiding
function scene:hide(event)
    if event.phase == "will" then
        Runtime:removeEventListener("key", self)
        Runtime:removeEventListener("touch", onScreenSwipe)
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("key", scene)

return scene