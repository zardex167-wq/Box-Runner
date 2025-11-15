-- main.lua
-- Geo Dash
-- Tile size = 32px

-- ------------------------
-- CONFIG / CONSTANTS
-- ------------------------
TILE = 32
WindowWidth = 800
WindowHeight = 600

-- Gravity
Gravity = 800

-- Player
Player = {
    x = 100,
    y = 0,
    width = 32,
    height = 32,
    yVelocity = 0,
    isOnGround = true
}

-- UI / Buttons
Buttons = {
    start = {x = WindowWidth / 2 - 100, y = 250, width = 200, height = 50, text = "Start Game"},
    levelselect = {x = WindowWidth / 2 - 100, y = 310, width = 200, height = 50, text = "Level Select"},
    settings = {x = WindowWidth / 2 - 100, y = 370, width = 200, height = 50, text = "Settings"},
    exit = {x = WindowWidth / 2 - 100, y = 430, width = 200, height = 50, text = "Exit"}
}
ButtonPause = { x = WindowWidth - 110, y = 10, width = 100, height = 30, text = "Pause" }

-- GameState
GameState = {
    active = "menu",
    menu = "menu",
    play = "play",
    gameover = "gameover",
    settings = "settings",
    levelselect = "levelselect",
    pause = "pause"
}

-- Level select buttons (20 buttons)
LevelButtons = {}
do
    local startX = WindowWidth / 2 - 320
    local startY = 140
    local gapX = 160
    local gapY = 80
    local columns = 4
    local totalLevels = 20
    for i = 1, totalLevels do
        local row = math.floor((i - 1) / columns)
        local col = (i - 1) % columns
        table.insert(LevelButtons, {
            x = startX + col * gapX,
            y = startY + row * gapY,
            width = 140,
            height = 60,
            text = "Level " .. i,
            id = i
        })
    end
end

-- Collections filled per level
GroundObjects = {}
SpikeObjects = {}
CoinObjects = {}

-- Score
TotalCoinsCollected = 0

-- Current level data (created by LoadLevel)
CurrentLevel = nil

-- ------------------------
-- INLINE LEVELS (string maps)
-- Each string row is left->right, each char is one tile.
-- Legend: G = ground, B = block, S = spike, C = coin, space = empty
-- ------------------------
Levels = {
    -- Level 1 (easy)
    [1] = {
        scrollSpeed = 150,
        rows = {
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                     C                                                          ",
            "             B      B            S                    B                         ",
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG"
        }
    },

    -- Level 2 (a bit harder)
    [2] = {
        scrollSpeed = 170,
        rows = {
            "                                                                                ",
            "                                                                                ",
            "              C               C                                                 ",
            "         B     B     B         S                 B       B                     ",
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG"
        }
    },

    -- Level 3 (platforms)
    [3] = {
        scrollSpeed = 180,
        rows = {
            "                                                                                ",
            "                                                                                ",
            "      C           B    C                                                         ",
            "   B   B     B       B      S                  B    B                          ",
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG"
        }
    },

    -- Add more sample levels here 
}

-- ------------------------
-- love.load: set window & font 
-- ------------------------
function love.load()
    love.window.setTitle("GEO DASH")
    love.window.setMode(WindowWidth, WindowHeight)
    -- Try loading your PressStart font; fallback to default if missing
    if love.filesystem.getInfo("Fonts/PressStart2P-Regular.ttf") then
        -- Font 1
        Font1 = love.graphics.newFont("Fonts/PressStart2P-Regular.ttf", 28)
        -- Font 2
        Font = love.graphics.newFont("Fonts/PressStart2P-Regular.ttf", 14)
    end
    -- Start in menu
    GameState.active = GameState.menu
end
-- AABB collision check between player (a) and tile-sized object (b)
local function AABB(a, b)
    return a.x < b.x + TILE and
           b.x < a.x + a.width and
           a.y < b.y + TILE and
           b.y < a.y + a.height
end

-- ------------------------
-- LoadLevel: parse inline strings into object tables
-- levelID: integer
-- ------------------------
function LoadLevel(levelID)
    -- pick level definition
    CurrentLevel = Levels[levelID] or makeFallbackLevel(levelID)

    -- clear previous objects
    GroundObjects = {}
    SpikeObjects = {}
    CoinObjects = {}

    -- parse rows (y increases downward)
    local rows = CurrentLevel.rows
    for row = 1, #rows do
        local line = rows[row]
        for col = 1, #line do
            local ch = line:sub(col, col)
            local x = (col - 1) * TILE
            local y = (row - 1) * TILE
            if ch == "G" then
                table.insert(GroundObjects, { x = x, y = y, width = TILE, height = TILE })
            elseif ch == "B" then
                table.insert(GroundObjects, { x = x, y = y, width = TILE, height = TILE }) -- block treated as ground for collision
            elseif ch == "S" then
                table.insert(SpikeObjects,  { x = x, y = y, width = TILE, height = TILE })
            elseif ch == "C" then
                table.insert(CoinObjects,   { x = x, y = y, width = TILE, height = TILE, collected = false })
            end
        end
    end

    -- place player on top of the rightmost ground found at player's x, otherwise bottom
    local groundY = WindowHeight - TILE - Player.height
    for _, g in ipairs(GroundObjects) do
        if g.x <= Player.x and g.x + g.width >= Player.x then
            groundY = g.y - Player.height
            break
        end
    end
    Player.x = 100
    Player.y = groundY
    Player.yVelocity = 0
    Player.isOnGround = true

    -- reset score for this level
    TotalCoinsCollected = 0
end
-- ------------------------
-- Update functions
-- ------------------------
function UpdatePlayer(dt)
    -- apply gravity
    Player.y = Player.y + Player.yVelocity * dt
    Player.yVelocity = Player.yVelocity + Gravity * dt

    -- basic ground collision AABB (after movement)
    Player.isOnGround = false

    for _, g in ipairs(GroundObjects) do
        -- Create a box for ground (tile height = TILE)
        local box = { x = g.x, y = g.y, width = g.width, height = g.height }

        if Player.x + Player.width > box.x and Player.x < box.x + box.width then
            -- Vertical overlap check: player is falling onto ground
            if Player.y + Player.height >= box.y and Player.y < box.y + box.height then
                -- Place player on top
                Player.y = box.y - Player.height
                Player.yVelocity = 0
                Player.isOnGround = true
            end
        end
    end
end

function UpdateObjects(dt)
    local speed = CurrentLevel and CurrentLevel.scrollSpeed or 150

    -- Move coins left and check collect
    for _, coin in ipairs(CoinObjects) do
        coin.x = coin.x - speed * dt

        if not coin.collected then
            if Player.x + Player.width > coin.x and Player.x < coin.x + coin.width and
               Player.y + Player.height > coin.y and Player.y < coin.y + coin.height then
                coin.collected = true
                TotalCoinsCollected = TotalCoinsCollected + 1
            end
        end

        -- Respawn off-screen to the right when fully passed (optional)
        if coin.x + coin.width < -TILE then
            coin.x = WindowWidth + math.random(0, 400)
            coin.collected = false
        end
    end

    -- Move spikes left and check collision -> gameover
    for _, spike in ipairs(SpikeObjects) do
        spike.x = spike.x - speed * dt

        if Player.x + Player.width > spike.x and Player.x < spike.x + spike.width and
           Player.y + Player.height > spike.y and Player.y < spike.y + spike.height then
            GameState.active = GameState.gameover
        end

        -- recycle spike off screen
        if spike.x + spike.width < -TILE then
            spike.x = WindowWidth + math.random(0, 600)
        end
    end

    -- Move ground objects left as well (blocks/ground scroll)
    for _, g in ipairs(GroundObjects) do
        g.x = g.x - speed * dt
        if g.x + g.width < -TILE then
            g.x = WindowWidth + math.random(0, 600)
        end
    end
end
function love.mousepressed(x, y, button, istouch, presses)
    if GameState.active == GameState.menu then
        for _, btn in pairs(Buttons) do
            if x >= btn.x and x <= btn.x + btn.width and y >= btn.y and y <= btn.y + btn.height then
                if btn.text == "Start Game" then
                    LoadLevel(1)
                    GameState.active = GameState.play
                elseif btn.text == "Level Select" then
                    GameState.active = GameState.levelselect
                elseif btn.text == "Settings" then
                    GameState.active = GameState.settings
                elseif btn.text == "Exit" then
                    love.event.quit()
                end
            end
        end

    elseif GameState.active == GameState.play then
        -- Pause button clicked?
        if x >= ButtonPause.x and x <= ButtonPause.x + ButtonPause.width and y >= ButtonPause.y and y <= ButtonPause.y + ButtonPause.height then
            GameState.active = GameState.pause
            return
        end

        -- Jump if left-click (button 1)
        if button == 1 and Player.isOnGround then
            Player.yVelocity = -300
            Player.isOnGround = false
        end

    elseif GameState.active == GameState.levelselect then
        for _, lvl in ipairs(LevelButtons) do
            if x >= lvl.x and x <= lvl.x + lvl.width and y >= lvl.y and y <= lvl.y + lvl.height then
                LoadLevel(lvl.id)
                GameState.active = GameState.play
            end
        end
    elseif GameState.active == GameState.pause then
        -- clicking anywhere resumes (simple)
        GameState.active = GameState.play
    elseif GameState.active == GameState.gameover then
        -- clicking restarts level 1 for now
        LoadLevel(1)
        GameState.active = GameState.menu
    end
end

-- ------------------------
-- Keyboard controls (optional)
-- ------------------------
function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

-- ------------------------
-- Main update
-- ------------------------
function love.update(dt)
    if GameState.active == GameState.play then
        UpdatePlayer(dt)
        UpdateObjects(dt)
    end
end

-- ------------------------
-- Drawing functions
-- ------------------------
local function DrawMenu()
    love.graphics.setFont(Font1)
    love.graphics.printf("Geo Dash", 0, 150, WindowWidth, "center")
    love.graphics.setFont(Font)
    for _, btn in pairs(Buttons) do
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", btn.x, btn.y, btn.width, btn.height)
        love.graphics.printf(btn.text, btn.x, btn.y + 15, btn.width, "center")
    end
end

local function DrawLevelSelect()
    love.graphics.printf("Select Level", 0, 100, WindowWidth, "center")
    for _, lvl in ipairs(LevelButtons) do
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", lvl.x, lvl.y, lvl.width, lvl.height)
        love.graphics.printf(lvl.text, lvl.x, lvl.y + 20, lvl.width, "center")
    end
end

-- Main draw
function love.draw()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)

    if GameState.active == GameState.menu then
        DrawMenu()

    elseif GameState.active == GameState.levelselect then
        DrawLevelSelect()

    elseif GameState.active == GameState.play then
        -- Draw ground tiles
        love.graphics.setColor(0.5, 0.25, 0)
        for _, g in ipairs(GroundObjects) do
            love.graphics.rectangle("fill", g.x, g.y, g.width, g.height)
        end

        -- Draw blocks (treated as ground visually too)
        love.graphics.setColor(0.6, 0.4, 0.2)
        for _, g in ipairs(GroundObjects) do
            -- If you had separate block sprites you can differentiate by other flags.
        end

        -- Draw spikes
        love.graphics.setColor(1, 0.2, 0.2)
        for _, s in ipairs(SpikeObjects) do
            love.graphics.rectangle("fill", s.x, s.y, s.width, s.height)
        end

        -- Draw coins
        love.graphics.setColor(1, 1, 0)
        for _, c in ipairs(CoinObjects) do
            if not c.collected then
                love.graphics.rectangle("fill", c.x + 6, c.y + 6, c.width - 12, c.height - 12)
            end
        end

        -- Draw player
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", Player.x, Player.y, Player.width, Player.height)

        -- Pause button
        love.graphics.setColor(0, 0, 1)
        love.graphics.rectangle("line", ButtonPause.x, ButtonPause.y, ButtonPause.width, ButtonPause.height)
        love.graphics.printf(ButtonPause.text, ButtonPause.x, ButtonPause.y + 8, ButtonPause.width, "center")

        -- UI
        love.graphics.setColor(0, 1, 0)
        love.graphics.print("Coins: " .. TotalCoinsCollected, 10, 10)

    elseif GameState.active == GameState.pause then
        love.graphics.printf("Game Paused - Click to Resume", 0, WindowHeight / 2 - 20, WindowWidth, "center")

    elseif GameState.active == GameState.gameover then
        love.graphics.printf("Game Over - Click to Return to Menu", 0, WindowHeight / 2 - 20, WindowWidth, "center")
    end
end