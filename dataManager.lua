local M = {}

local json = require("json")
local path = system.pathForFile("gameData.json", system.DocumentsDirectory)

-- Function to save data to a JSON file
function M.save(data)
    local file = io.open(path, "w") -- Open the file in write mode
    if file then
        file:write(json.encode(data)) -- Encode the data as JSON and write it to the file
        io.close(file) -- Close the file
    end
end

-- Function to load data from a JSON file
function M.load()
    local file = io.open(path, "r") -- Open the file in read mode
    local data
    if file then
        local contents = file:read("*a") -- Read the entire contents of the file
        data = json.decode(contents) -- Decode the JSON data
        io.close(file) -- Close the file
    end
    if not data then
        -- If no data is found, initialize with default values
        data = {
            level1 = {highScore = 0},
            level2 = {highScore = 0},
            level3 = {highScore = 0}
        }
    else
        -- Ensure all levels have highScore initialized
        data.level1 = data.level1 or {highScore = 0}
        data.level2 = data.level2 or {highScore = 0}
        data.level3 = data.level3 or {highScore = 0}
    end
    return data
end

return M
