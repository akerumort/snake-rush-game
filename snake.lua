local M = {}

local composer = require("composer")

local cellSize = 20
local scene

local sheetOptions = {
    width = 20,
    height = 20,
    numFrames = 3
}
local snakeSheet = graphics.newImageSheet("pictures/snake/snake.png", sheetOptions)

local sequences = {
    {
        name = "head",
        frames = {1}
    },
    {
        name = "body",
        frames = {2}
    },
    {
        name = "tail",
        frames = {3}
    }
}

-- Function to create a snake
local function createSnake(sceneRef)
    scene = sceneRef

    local snake = {}
    snake.segments = {}
    snake.direction = "right"
    snake.nextDirection = "right"
    snake.speed = 600
    snake.timer = nil
    snake.score = 0

    -- Function to reset the snake
    function snake:reset()
        self:clear()
        self.direction = "right"
        self.nextDirection = "right"
        self:addSegment(display.contentCenterX, display.contentCenterY, "head")
        self:addSegment(display.contentCenterX - cellSize, display.contentCenterY, "body")
        self:addSegment(display.contentCenterX - 2 * cellSize, display.contentCenterY, "tail")
        self.speed = 600
        self.score = 0
    end

    -- Function to clear the snake segments
    function snake:clear()
        for _, segment in ipairs(self.segments) do
            segment:removeSelf()
        end
        self.segments = {}
    end

    -- Function to add a segment to the snake
    function snake:addSegment(x, y, type)
        local segment = display.newSprite(scene.view, snakeSheet, sequences)
        segment:setSequence(type)
        segment:play()
        segment.x, segment.y = x, y
        table.insert(self.segments, segment)
    end

    -- Function to rotate a segment based on direction
    function snake:rotateSegment(segment, direction)
        if direction == "left" then
            segment.rotation = 0
        elseif direction == "right" then
            segment.rotation = 180
        elseif direction == "down" then
            segment.rotation = 270
        elseif direction == "up" then
            segment.rotation = 90
        end
    end

    -- Function to move the snake
    function snake:move()
        if #self.segments == 0 then return end

        local head = self.segments[1]
        local newX, newY = head.x, head.y
        if self.nextDirection == "right" then newX = head.x + cellSize
        elseif self.nextDirection == "left" then newX = head.x - cellSize
        elseif self.nextDirection == "up" then newY = head.y - cellSize
        elseif self.nextDirection == "down" then newY = head.y + cellSize
        end
        
        -- Wrap around screen edges
        if newX < 0 then newX = display.contentWidth
        elseif newX >= display.contentWidth + cellSize then newX = 0
        end

        if newY < 40 then newY = display.contentHeight - cellSize
        elseif newY >= display.contentHeight then newY = 40
        end

        -- Move body segments
        for i = #self.segments, 2, -1 do
            self.segments[i].x, self.segments[i].y = self.segments[i-1].x, self.segments[i-1].y
            self:rotateSegment(self.segments[i], self.direction)
        end

        head.x, head.y = newX, newY
        self.direction = self.nextDirection
        self:rotateSegment(head, self.direction)

        self:checkSelfCollision()
    end

    -- Function to check for collision with itself
    function snake:checkSelfCollision()
        if #self.segments == 0 then return end

        local head = self.segments[1]
        for i = 2, #self.segments do
            if head.x == self.segments[i].x and head.y == self.segments[i].y then
                composer.setVariable("currentScore", self.score)
                scene:resetSnake()
                break
            end
        end
    end

    -- Function to check for collision with food
    function snake:checkFoodCollision(food)
        if #self.segments == 0 then return false end

        local head = self.segments[1]
        if head.x == food.x and head.y == food.y then
            local lastSegment = self.segments[#self.segments]
            self:addSegment(lastSegment.x, lastSegment.y, "tail")

            -- Move the tail segment to the new position
            self.segments[#self.segments - 1]:setSequence("body")
            self.segments[#self.segments - 1]:play()

            self.score = self.score + 1
            return true
        end
        return false
    end

    return snake
end

M.createSnake = createSnake
return M
