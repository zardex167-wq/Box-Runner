-- main.lua
-- Geometry Dash Style Mini Game (Enhanced with Difficulty Scaling)

-- ======================================================================
-- CONFIGURATION
-- ======================================================================

WindowWidth = 800
WindowHeight = 600
GravityBase = 800

Font = love.graphics.newFont("Fonts/PressStart2P-Regular.ttf", 14)
love.graphics.setFont(Font)

-- ======================================================================
-- GAME STATES
-- ======================================================================

GameStates = {
    active = "menu",
    menu = "menu",
    play = "play",
    levelselect = "levelselect",
    settings = "settings",
    over = "over"
}

-- ======================================================================
-- BUTTON DEFINITIONS
-- ======================================================================

Buttons = {
    start = {x = WindowWidth / 2 - 100, y = 250, width = 200, height = 50, text = "Start Game"},
    levelselect = {x = WindowWidth / 2 - 100, y = 310, width = 200, height = 50, text = "Level Select"},
    settings = {x = WindowWidth / 2 - 100, y = 370, width = 200, height = 50, text = "Settings"},
    exit = {x = WindowWidth / 2 - 100, y = 430, width = 200, height = 50, text = "Exit"},
    pause = {x = WindowWidth - 80, y = 20, width = 70, height = 30, text = "Pause"}
}

-- ======================================================================
-- LEVELS
-- ======================================================================

Levels = {
    {name = "Level 1", coins = 1, coinSpeed = 150, gravity = 800, jump = 300},
    {name = "Level 2", coins = 2, coinSpeed = 200, gravity = 850, jump = 320},
    {name = "Level 3", coins = 3, coinSpeed = 250, gravity = 900, jump = 340},
    {name = "Level 4", coins = 4, coinSpeed = 300, gravity = 950, jump = 360}
}

CurrentLevel = 1
TotalCoinsCollected = 0

-- ======================================================================
-- PLAYER & OBJECTS
-- ======================================================================

Player = {
    x = 100,
    y = 376,
    width = 32,
    height = 32,
    yVelocity = 0,
    isOnGround = true,
    jumpStrength = 300
}

Ground = {
    x = 0,
    y = WindowHeight - 192,
    width = WindowWidth,
    height = 192
}

Coins = {}

-- ======================================================================
-- UTILITY FUNCTIONS
-- ======================================================================

local function distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

local function isMouseOverButton(button)
    return love.mouse.getX() >= button.x and love.mouse.getX() <= button.x + button.width
       and love.mouse.getY() >= button.y and love.mouse.getY() <= button.y + button.height
end

local function spawnCoins(level)
    Coins = {}
    local data = Levels[level]
    for i = 1, data.coins do
        table.insert(Coins, {
            x = 800 + (i - 1) * 300,
            y = 376,
            radius = 8,
            speed = data.coinSpeed,
            collected = false
        })
    end
    Player.jumpStrength = data.jump
    Gravity = data.gravity
end

-- ======================================================================
-- LOVE CALLBACKS
-- ======================================================================

function love.load()
    love.window.setTitle("Geometry Dash Style Game")
    love.window.setMode(WindowWidth, WindowHeight)
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
end

function love.update(dt)
    if GameStates.active == GameStates.play then
        -- Apply gravity
        Player.yVelocity = Player.yVelocity + Gravity * dt
        Player.y = Player.y + Player.yVelocity * dt

        -- Ground collision
        if Player.y >= Ground.y - Player.height then
            Player.y = Ground.y - Player.height
            Player.isOnGround = true
            Player.yVelocity = 0
        end

        -- Pause button
        if isMouseOverButton(Buttons.pause) and love.mouse.isDown(1) then
            GameStates.active = GameStates.menu
        end

        -- Update coins
        for _, coin in ipairs(Coins) do
            coin.x = coin.x - coin.speed * dt
            if coin.x < -coin.radius then
                coin.x = WindowWidth + math.random(200, 600)
                coin.collected = false
            end

            local cx = math.max(Player.x, math.min(coin.x, Player.x + Player.width))
            local cy = math.max(Player.y, math.min(coin.y, Player.y + Player.height))
            local dist = distance(coin.x, coin.y, cx, cy)

            if dist <= coin.radius and not coin.collected then
                coin.collected = true
                TotalCoinsCollected = TotalCoinsCollected + 1
            end
        end
    end
end

function love.mousepressed(x, y, button)
    if button ~= 1 then return end

    if GameStates.active == GameStates.menu then
        if isMouseOverButton(Buttons.start) then
            CurrentLevel = 1
            spawnCoins(CurrentLevel)
            GameStates.active = GameStates.play
        elseif isMouseOverButton(Buttons.levelselect) then
            GameStates.active = GameStates.levelselect
        elseif isMouseOverButton(Buttons.settings) then
            GameStates.active = GameStates.settings
        elseif isMouseOverButton(Buttons.exit) then
            love.event.quit()
        end

    elseif GameStates.active == GameStates.levelselect then
        for i, lvl in ipairs(Levels) do
            local bx, by = WindowWidth / 2 - 100, 150 + (i - 1) * 70
            if x >= bx and x <= bx + 200 and y >= by and y <= by + 50 then
                CurrentLevel = i
                spawnCoins(CurrentLevel)
                GameStates.active = GameStates.play
            end
        end

    elseif GameStates.active == GameStates.play then
        if Player.isOnGround then
            Player.yVelocity = -Player.jumpStrength
            Player.isOnGround = false
        end
    end
end

function love.keypressed(key)
    if key == "escape" then
        if GameStates.active == GameStates.play or GameStates.active == GameStates.levelselect or GameStates.active == GameStates.settings then
            GameStates.active = GameStates.menu
        end
    end
end

-- ======================================================================
-- DRAW
-- ======================================================================

function love.draw()
    if GameStates.active == GameStates.menu then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("GEOMETRY DASH MINI", 0, 150, WindowWidth, "center")

        for _, button in pairs(Buttons) do
            if button.text ~= "Pause" then
                love.graphics.setColor(isMouseOverButton(button) and 0.8 or 1, 1, 1)
                love.graphics.rectangle("line", button.x, button.y, button.width, button.height)
                love.graphics.printf(button.text, button.x, button.y + 15, button.width, "center")
            end
        end

    elseif GameStates.active == GameStates.levelselect then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("SELECT A LEVEL", 0, 80, WindowWidth, "center")

        for i, lvl in ipairs(Levels) do
            local bx, by = WindowWidth / 2 - 100, 150 + (i - 1) * 70
            love.graphics.rectangle("line", bx, by, 200, 50)
            love.graphics.printf(lvl.name, bx, by + 15, 200, "center")
        end

        love.graphics.printf("Press ESC to go back", 0, WindowHeight - 50, WindowWidth, "center")

    elseif GameStates.active == GameStates.play then
        -- Player
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", Player.x, Player.y, Player.width, Player.height)

        -- Coins
        for _, coin in ipairs(Coins) do
            if not coin.collected then
                love.graphics.setColor(1, 1, 0)
                love.graphics.circle("fill", coin.x, coin.y, coin.radius)
            end
        end

        -- Ground
        love.graphics.setColor(0.4, 0.2, 0)
        love.graphics.rectangle("fill", Ground.x, Ground.y, Ground.width, Ground.height)

        -- Pause Button
        love.graphics.setColor(0, 0, 1)
        love.graphics.rectangle("line", Buttons.pause.x, Buttons.pause.y, Buttons.pause.width, Buttons.pause.height)
        love.graphics.printf("Pause", Buttons.pause.x, Buttons.pause.y + 8, Buttons.pause.width, "center")

        -- HUD
        love.graphics.setColor(0, 1, 0)
        love.graphics.print("Level: " .. Levels[CurrentLevel].name, 10, 10)
        love.graphics.print("Coins: " .. TotalCoinsCollected, 10, 30)
        love.graphics.print("Gravity: " .. Gravity, 10, 50)

    elseif GameStates.active == GameStates.settings then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("SETTINGS (Coming Soon)", 0, WindowHeight / 2 - 20, WindowWidth, "center")
    end
end
