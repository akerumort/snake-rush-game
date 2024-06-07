local composer = require("composer")
local scene = composer.newScene()
local snakeModule = require("snake")
local dataManager = require("dataManager")

local cellSize = 20
local minDistance = 40
local minDistanceFromSnake = 60 
local borderOffset = 2 * cellSize 

local food
local snake
local moveTimer
local obstacleTimers = {}
local obstacles = {}
local portals = {}
local maxObstacles = 3
local foodCount = 0
local highScore = 0

local foodCountText
local highScoreText
local pauseOverlay
local background
local infoBg

local currentLevel = "level3"

local deathSound = audio.loadSound("music/collision.mp3")
local eatingSound = audio.loadSound("music/eating.mp3")

local directions = {"left", "right", "up", "down"}

local swipeStartX, swipeStartY

-- Function to handle screen swipe gestures
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

-- Function to pause the game
local function pauseGame()
    if moveTimer then
        timer.pause(moveTimer)
    end

    for _, timerId in ipairs(obstacleTimers) do
        timer.pause(timerId)
    end

    if snake then
        for _, segment in ipairs(snake.segments) do
            segment.isVisible = false
        end
    end

    for _, obstacle in ipairs(obstacles) do
        transition.pause(obstacle)
    end

    pauseOverlay = display.newGroup()

    local overlayRect = display.newRect(pauseOverlay, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
    overlayRect:setFillColor(0, 0, 0, 0.5)

    local pauseButton = display.newImageRect(pauseOverlay, "pictures/gamePausedLvl3Button.png", 350, 130)
    pauseButton.x = display.contentCenterX
    pauseButton.y = display.contentCenterY - 80

    local resumeButton = display.newImageRect(pauseOverlay, "pictures/resumeLvl3Button.png", 200, 70)
    resumeButton.x = display.contentCenterX
    resumeButton.y = display.contentCenterY

    local menuButton = display.newImageRect(pauseOverlay, "pictures/returnLvl3Button.png", 200, 70)
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

        for _, timerId in ipairs(obstacleTimers) do
            timer.resume(timerId)
        end

        for _, obstacle in ipairs(obstacles) do
            transition.resume(obstacle)
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

-- Function to check if a position is valid for placing objects
local function isPositionValid(x, y)
    for _, obstacle in ipairs(obstacles) do
        local dx = obstacle.x - x
        local dy = obstacle.y - y
        if math.sqrt(dx * dx + dy * dy) < minDistance then
            return false
        end
    end
    for _, portal in ipairs(portals) do
        local dx = portal.x - x
        local dy = portal.y - y
        if math.sqrt(dx * dx + dy * dy) < minDistance then
            return false
        end
    end
    local head = snake.segments[1]
    if head then
        local dx = head.x - x
        local dy = head.y - y
        if math.sqrt(dx * dx + dy * dy) < minDistanceFromSnake then
            return false
        end
    end
    if food and (math.abs(food.x - x) < cellSize and math.abs(food.y - y) < cellSize) then
        return false
    end
    return true
end

-- Function to create food
local function createFood()
    local x, y
    repeat
        x = math.random(1, (display.contentWidth / cellSize) - 3) * cellSize
        y = math.random(2, (display.contentHeight / cellSize) - 5) * cellSize
    until isPositionValid(x, y)
    if food then food:removeSelf() end
    food = display.newImageRect(scene.view, "pictures/appleGreen.png", cellSize, cellSize)
    food.x = x
    food.y = y
end

-- Function to clear obstacles
local function clearObstacles()
    for i = #obstacles, 1, -1 do
        if obstacles[i] then
            obstacles[i]:removeSelf()
            table.remove(obstacles, i)
        end
    end
end

-- Function to check if a move is valid for obstacles
local function isMoveValid(obstacle, newX, newY)
    for _, otherObstacle in ipairs(obstacles) do
        if otherObstacle ~= obstacle then
            local dx = otherObstacle.x - newX
            local dy = otherObstacle.y - newY
            if math.sqrt(dx * dx + dy * dy) < minDistance then
                return false
            end
        end
    end
    for _, portal in ipairs(portals) do
        local dx = portal.x - newX
        local dy = portal.y - newY
        if math.sqrt(dx * dx + dy * dy) < minDistance then
            return false
        end
    end
    if food and (math.abs(food.x - newX) < cellSize and math.abs(food.y - newY) < cellSize) then
        return false
    end
    return true
end

-- Function to move an obstacle
local function moveObstacle(obstacle)
    local direction = directions[math.random(1, #directions)]
    local moveBy = cellSize * math.random(1, 3) 
    
    local newX, newY = obstacle.x, obstacle.y
    if direction == "left" then
        newX = obstacle.x - moveBy
    elseif direction == "right" then
        newX = obstacle.x + moveBy
    elseif direction == "up" then
        newY = obstacle.y - moveBy
    elseif direction == "down" then
        newY = obstacle.y + moveBy
    end

    if newX < borderOffset then newX = borderOffset
    elseif newX >= display.contentWidth - cellSize - borderOffset then newX = display.contentWidth - cellSize - borderOffset
    end

    if newY < 40 + borderOffset then newY = 40 + borderOffset
    elseif newY >= display.contentHeight - cellSize - borderOffset then newY = display.contentHeight - cellSize - borderOffset
    end

    if isMoveValid(obstacle, newX, newY) then
        transition.to(obstacle, {x = newX, y = newY, time = 1000})
    end
end

-- Function to create obstacles
local function createObstacles()
    clearObstacles()
    for i = 1, maxObstacles do
        local x, y
        repeat
            x = math.random(1, (display.contentWidth / cellSize) - 3) * cellSize
            y = math.random(2, (display.contentHeight / cellSize) - 5) * cellSize
        until isPositionValid(x, y)
        
        local obstacle = display.newImageRect(scene.view, "pictures/ghost.png", cellSize, cellSize)
        obstacle.x = x
        obstacle.y = y
        table.insert(obstacles, obstacle)
        
        local function obstacleMover()
            moveObstacle(obstacle)
        end

        local timerId = timer.performWithDelay(1000, obstacleMover, 0)
        table.insert(obstacleTimers, timerId)
    end
end

-- Function to create portals in random locations
local function createPortals()
    for i = 1, 2 do
        local x, y
        repeat
            x = math.random(1, (display.contentWidth / cellSize) - 3) * cellSize
            y = math.random(2, (display.contentHeight / cellSize) - 5) * cellSize
        until isPositionValid(x, y)
        
        local portal = display.newImageRect(scene.view, "pictures/portal.png", cellSize, cellSize)
        portal.x = x
        portal.y = y
        table.insert(portals, portal)
    end
end

-- Function to check collision with portals
local function checkPortalCollision()
    local head = snake.segments[1]
    for _, portal in ipairs(portals) do
        if head.x == portal.x and head.y == portal.y then
            local otherPortal = portals[1] == portal and portals[2] or portals[1]
            head.x = otherPortal.x
            head.y = otherPortal.y
            break
        end
    end
end

-- Function to play collision animation
local function playCollisionAnimation(x, y)
    local collisionGroup = display.newGroup()
    scene.view:insert(collisionGroup)

    for i = 1, 3 do
        local frame = display.newImageRect(collisionGroup, "pictures/death/" .. i .. ".png", cellSize * 4, cellSize * 4)
        frame.x = x
        frame.y = y
        frame.isVisible = false
    end

    local frameIndex = 1

    local function showNextFrame()
        if frameIndex > 1 then
            collisionGroup[frameIndex - 1].isVisible = false
        end

        if frameIndex <= 3 then
            collisionGroup[frameIndex].isVisible = true
            frameIndex = frameIndex + 1
            timer.performWithDelay(100, showNextFrame)
        else
            collisionGroup:removeSelf()
        end
    end

    showNextFrame()
end

-- Function to check collision with obstacles
local function checkObstacleCollision()
    for _, segment in ipairs(snake.segments) do
        for _, obstacle in ipairs(obstacles) do
            if math.abs(obstacle.x - segment.x) < cellSize and math.abs(obstacle.y - segment.y) < cellSize then
                audio.play(deathSound, {channel = 2})
                playCollisionAnimation(obstacle.x, obstacle.y)
                scene:resetSnake()
                return
            end
        end
    end
end

-- Function to move the snake
local function moveSnake()
    snake:move()
    if snake:checkFoodCollision(food) then
        audio.play(eatingSound, {channel = 2})
        foodCount = foodCount + 1
        foodCountText.text = "Food: " .. foodCount
        createFood()
    end
    checkObstacleCollision()
    checkPortalCollision()
end

-- Function to create the scene
function scene:create(event)
    local sceneGroup = self.view
    foodCount = 0

    local data = dataManager.load()
    highScore = data.level3.highScore or 0

    local gridWidth = math.floor(display.contentWidth / cellSize) * cellSize
    local gridHeight = math.floor(display.contentHeight / cellSize) * cellSize

    local offsetX = (display.contentWidth - gridWidth) / 2
    local offsetY = (display.contentHeight - gridHeight) / 2 - 10

    -- Load background
    background = display.newImageRect(sceneGroup, "pictures/backgroundLvl3.jpg", gridWidth, gridHeight)
    background.anchorX = 0
    background.anchorY = 0
    background.x = offsetX
    background.y = offsetY

    local function drawGrid()
        for x = 0, gridWidth - cellSize, cellSize do
            for y = 40, gridHeight - cellSize, cellSize do
                local cell = display.newRect(sceneGroup, x + offsetX, y + offsetY, cellSize, cellSize)
                cell:setFillColor(0, 0, 0, 0)
            end
        end
    end

    drawGrid()

    -- Moving counters to the upper black space and making them nice
    local textGroup = display.newGroup()
    sceneGroup:insert(textGroup)

    -- Create a single rectangle as the background for the counters
    infoBg = display.newRect(textGroup, display.contentCenterX, 10, display.contentWidth, 40)
    infoBg:setFillColor(1, 0, 0)

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

    moveTimer = timer.performWithDelay(100, moveSnake, -1)
    createObstacles()
    createPortals()

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
        self:clearObjects()

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
        data.level3.highScore = highScore
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

    for _, timerId in ipairs(obstacleTimers) do
        timer.cancel(timerId)
    end
    obstacleTimers = {}

    clearObstacles()

    if food then
        food:removeSelf()
        food = nil
    end

    if snake then
        snake:clear()
    end

    for _, portal in ipairs(portals) do
        if portal then
            portal:removeSelf()
        end
    end
    portals = {}
end

-- Function to continue the game
function scene:continueGame()
    self:clearObjects()
    snake = snakeModule.createSnake(self)
    snake:reset()
    createFood()

    moveTimer = timer.performWithDelay(100, moveSnake, -1)
    createObstacles()
    createPortals()
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