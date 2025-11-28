-- Conf .lua

local conf = {}

---------------------------------------------------------
-- CONFIG / CONSTANTS
---------------------------------------------------------
TILE = 32
WindowWidth = 800
WindowHeight = 600

Gravity = (32 * 80)   -- 2560       -- gravity (tuned for snappy jumps)
JUMP_VELOCITY = (-32 * 22)   --~800    -- initial jump impulse
Ss = (32 * 6.4)   ---204.8                -- Scroll speed

-- Player
Player = {
    x = 100,
    y = 0,
    width = 32,
    height = 32,
    yVelocity = 0,
    isOnGround = true,
    rotation = 0,
    rotationSpeed = (math.pi * 2) 
}

prevX = Player.x
prevY = Player.y

-- UI / Buttons
Buttons = {
    start = {x = WindowWidth / 2 - 100, y = 250, width = 200, height = 50, text = "Start Game"},
    levelselect = {x = WindowWidth / 2 - 100, y = 310, width = 200, height = 50, text = "Level Select"},
    settings = {x = WindowWidth / 2 - 100, y = 370, width = 200, height = 50, text = "Settings"},
    exit = {x = WindowWidth / 2 - 100, y = 430, width = 200, height = 50, text = "Exit"}
}

ButtonPause = { x = WindowWidth - 110, y = 10, width = 100, height = 30, text = "Pause" }

-- Level complete screen buttons
LevelCompleteButtons = {
    next = {x = WindowWidth/2 - 120, y = 330, width = 240, height = 50, text = "Next Level"},
    menu = {x = WindowWidth/2 - 120, y = 400, width = 240, height = 50, text = "Back To Menu"}
}

-- Sprites
Sprites = {
    block       = nil, -- Sprites/block.png
    coin        = nil, -- Sprites/coin.png
    player      = nil, -- Sprites/player.png
    spike       = nil, -- Sprites/spike.png
    transparent = nil, -- Sprites/transparent.png
    platform    = nil, -- Sprites/platform.png
    minispike   = nil, -- Sprites/minispike.png
    bigspike    = nil,  -- Sprites/bigspike.png
    flippedminispike = nil -- Sprites/flippedminispike.png
}

---------------------------------------------------------
-- SAFE SPRITE LOADING & DRAW HELPERS
---------------------------------------------------------
local function safeLoad(path)
    if path and love.filesystem.getInfo(path) then
        local ok, img = pcall(love.graphics.newImage, path)
        if ok then return img end
    end
    return nil
end

function LoadSprites()
    Sprites.block       = safeLoad("Sprites/block.png")
    Sprites.coin        = safeLoad("Sprites/coin.png")
    Sprites.player      = safeLoad("Sprites/player.png")
    Sprites.spike       = safeLoad("Sprites/spike.png")
    Sprites.transparent = safeLoad("Sprites/transparent.png")
    Sprites.platform    = safeLoad("Sprites/platform.png")
    Sprites.minispike   = safeLoad("Sprites/minispike.png")
    Sprites.bigspike    = safeLoad("Sprites/bigspike.png")
    Sprites.flippedminispike = safeLoad("Sprites/flipped_mini_spike.png")
end

-- draw sprite scaled to tile area, or fallback colored rect
function DrawTileSprite(img, x, y, w, h, r, g, b)
    if img then
        local iw, ih = img:getWidth(), img:getHeight()
        if iw == 0 or ih == 0 then
            love.graphics.setColor(r or 1, g or 1, b or 1)
            love.graphics.rectangle("fill", x, y, w, h)
            love.graphics.setColor(1,1,1)
            return
        end
        local sx, sy = w / iw, h / ih
        love.graphics.setColor(1,1,1)
        love.graphics.draw(img, x, y, 0, sx, sy)
    else
        love.graphics.setColor(r or 1, g or 1, b or 1)
        love.graphics.rectangle("fill", x, y, w, h)
        love.graphics.setColor(1,1,1)
    end
end

---------------------------------------------------------
-- GameState
---------------------------------------------------------
GameState = {
    active = "menu",
    menu = "menu",
    play = "play",
    gameover = "gameover",
    settings = "settings",
    levelselect = "levelselect",
    pause = "pause",
    levelcomplete = "levelcomplete"
}

LevelNames = {
    "Scramble",
    "Platformis",
    "Shadow Run",
    "Pulse Drift",
    "Echo Breaker",
    "Wave Storm",
    "Neon Bloom",
    "Frost Edge",
    "Hyper Dash",
    "Prism Crash",
    "Quantum Leap",
    "Star Burst",
    "Vibe Flux",
    "Lava Twist",
    "Nightfall",
    "Cyber Hop",
    "Flash Tracer",
    "Redwire",
    "Moonstep",
    "End Shift"
}

---------------------------------------------------------
-- Level Buttons (grid)
---------------------------------------------------------
LevelButtons = {}

do
    local startX = WindowWidth / 2 - 320
    local startY = 200 -- you can adjust this
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
            text = "Level " .. i .. " " .. LevelNames[i],
            id = i
        })
    end
end



return conf