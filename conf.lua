-- conf.lua (FULL FIXED VERSION)
local conf = {}

---------------------------------------------------------
-- GLOBAL CONSTANTS
---------------------------------------------------------
TILE = 32
WindowWidth = 800
WindowHeight = 600
SB = 64

Gravity = (32 * 80)          -- 2560
JUMP_VELOCITY = (-32 * 22)   -- -704
Ss = (32 * 8)              -- ~204.8 scroll speed

---------------------------------------------------------
-- PLAYER
---------------------------------------------------------
Player = {
    x = 100,
    y = 0,
    width = 32,
    height = 32,
    yVelocity = 0,
    isOnGround = true,
    rotation = 0,
    rotationSpeed = (math.pi * 2), -- radians per second
}
---------------------------------------------------------
-- UI BUTTONS
--------------------------------------------------------

Buttons = {
    start = {x = WindowWidth / 2 - 100, y = 250, width = 200, height = 50, text = "Start Game"},
    levelselect = {x = WindowWidth / 2 - 100, y = 310, width = 200, height = 50, text = "Level Select"},
    settings = {x = WindowWidth / 2 - 100, y = 370, width = 200, height = 50, text = "Settings"},
    exit = {x = WindowWidth / 2 - 100, y = 430, width = 200, height = 50, text = "Exit"},
    credits = {x = WindowWidth - 196, y = WindowHeight - 48, width = 160, height = 40, text = "Credits"},
    achievements = {x = WindowWidth - 792, y = WindowHeight - 48, width = 240, height = 40, text = "Achievements"},
    changelog = {x = WindowWidth - 540, y = WindowHeight - 48, width = 200, height = 40, text = "Changelog"},
    shop = {x = WindowWidth - 328, y = WindowHeight - 48, width = 120, height = 40, text = "Shop"}
}

ButtonPause = { x = WindowWidth - 110, y = 10, width = 100, height = 30, text = "Pause" }

ButtonsPause = {
    Resume = {x = WindowWidth / 2 - 100, y = 250, width = 200, height = 50, text = "Resume"},
    Exit    = {x = WindowWidth / 2 - 100, y = 310, width = 200, height = 50, text = "Exit to Menu"},
    Settings= {x = WindowWidth / 2 - 100, y = 370, width = 200, height = 50, text = "Settings"}
}

LevelCompleteButtons = {
    next = {x = WindowWidth/2 - 120, y = 330, width = 240, height = 50, text = "Next Level"},
    menu = {x = WindowWidth/2 - 120, y = 400, width = 240, height = 50, text = "Back To Menu"}
}

ButtonsSettings = {
    Music = {x = SB, y = SB, width = SB*4, height = SB, text = "Music" },
    MusicOption = {x = 480, y = SB, width = SB*2, height = SB, text = "Y"},
    Speed = {x = SB, y = SB*2.5, width = SB*4, height = SB, text = "Speed"},
    SpeedOption = {x = 480, y = SB*2.5, width = SB*2, height = SB, text = "1"},
    Constrols = {x = SB, y = SB*4, width = SB*4, height = SB, text = "Controls"},
    ControlOption = {x = 480, y = SB*4, width = SB*2.5, height = SB, text = "Click"},
    be1 = {x = SB, y = SB*5.5, width = SB*4, height = SB, text = "be1"},
    be1Option = {x = 480, y = SB*5.5, width = SB*2, height = SB, text = "Null"},
    be2 = {x = SB, y = SB*7, width = SB*4, height = SB, text = "be2"},
    be2Option = {x = 480, y = SB*7, width = SB*2, height = SB, text = "Null"},
    Exit = {x = SB*4, y = SB*8.25, width = SB*4, height = SB, text = "Exit"}
}

ButtonsShop = {
    item1 = {x = SB, y = SB, width = SB*6, height = SB, text = "Item 1"},
    item2 = {x = SB, y = SB*2.5, width = SB*6, height = SB, text = "Item 2"},
    item3 = {x = SB, y = SB*4, width = SB*6, height = SB, text = "Item 3"},
    Exit = {x = SB*4, y = SB*6.5, width = SB*4, height = SB, text = "Exit"}
}

ButtonsAchievements = {
    achievement1 = {x = SB, y = SB, width = SB*6, height = SB, text = "Achievement 1"},
    achievement2 = {x = SB, y = SB*2.5, width = SB*6, height = SB, text = "Achievement 2"},
    achievement3 = {x = SB, y = SB*4, width = SB*6, height = SB, text = "Achievement 3"},
    Exit = {x = SB*4, y = SB*6.5, width = SB*4, height = SB, text = "Exit"}
}

ButtonsChangelog = {
    changelog1 = {x = SB, y = SB, width = SB*6, height = SB, text = "Update1.0"},
    changelog2 = {x = SB, y = SB*2.5, width = SB*6, height = SB, text = "Update1.1"},
    changelog3 = {x = SB, y = SB*4, width = SB*6, height = SB, text = "Update1.2"},
    changelog4 = {x = SB, y = SB*5.5, width = SB*6, height = SB, text = "Update1.3"},
    changelog5 = {x = SB, y = SB*7, width = SB*6, height = SB, text = "Update1.4"},
    changelog6 = {x = SB, y = SB*8.5, width = SB*6, height = SB, text = "Update1.5"},
    Exit = {x = SB*4, y = SB*6.5, width = SB*4, height = SB, text = "Exit"}
}

ButtonsCredits = {
    credit1 = {x = SB, y = SB, width = SB*10.5, height = SB, text = "Developer/Designer:"},
    credit1name = {x = SB*2, y = SB*2.16, width = SB*8, height = SB, text = "Muhammad Arsal"},
    credit2 = {x = SB*2.24, y = SB*4, width = SB*7.5, height = SB, text = "Helper/Music:"},
    credit2name = {x = SB*2.32, y = SB*5.16, width = SB*7, height = SB, text = "Gotham Kumar"},
    Exit = {x = SB*4, y = SB*6.5, width = SB*4, height = SB, text = "Exit"}
}

---------------------------------------------------------
-- SPRITE TABLES
---------------------------------------------------------

Sprites = {
    block = nil,
    coin = nil,
    player = nil,
    spike = nil,
    platform = nil,
    minispike = nil,
    bigspike = nil,
    flippedminispike = nil
}

---------------------------------------------------------
-- SAFE LOADER
---------------------------------------------------------
local function safeLoad(path)
    if path and love.filesystem.getInfo(path) then
        local ok, img = pcall(love.graphics.newImage, path)
        if ok then return img end
    end
    return nil
end

---------------------------------------------------------
-- LOAD ALL SPRITES
---------------------------------------------------------
function LoadSprites()
    Sprites.block         = safeLoad("Sprites/block.png")
    Sprites.coin          = safeLoad("Sprites/coin.png")
    Sprites.player        = safeLoad("Sprites/player.png")
    Sprites.spike         = safeLoad("Sprites/spike.png")
    Sprites.minispike     = safeLoad("Sprites/minispike.png")
    Sprites.bigspike      = safeLoad("Sprites/bigspike.png")
    Sprites.flippedminispike = safeLoad("Sprites/flipped_mini_spike.png")
end

---------------------------------------------------------
-- DRAW TILE (AUTO SCALED)
---------------------------------------------------------
function DrawTileSprite(img, x, y, w, h, r, g, b)
    if img then
        local iw, ih = img:getWidth(), img:getHeight()
        if iw == 0 or ih == 0 then return end

        love.graphics.setColor(1,1,1)
        love.graphics.draw(img, x, y, 0, w/iw, h/ih)
    else
        love.graphics.setColor(r or 1, g or 1, b or 1)
        love.graphics.rectangle("fill", x, y, w, h)
        love.graphics.setColor(1,1,1)
    end
end

---------------------------------------------------------
-- GAME STATE
---------------------------------------------------------
GameState = {
    active = "menu",
    menu = "menu",
    play = "play",
    gameover = "gameover",
    settings = "settings",
    levelselect = "levelselect",
    pause = "pause",
    levelcomplete = "levelcomplete",
    shop = "shop",
    credits = "credits",
    achievements = "achievements",
    changelog = "changelog"
}

---------------------------------------------------------
-- LEVEL NAME LIST
---------------------------------------------------------
LevelNames = {
    "Scramble", "Platformis", "Shadow Run", "Pulse Drift",
    "Echo Breaker", "Wave Storm", "Neon Bloom", "Frost Edge",
    "Hyper Dash", "Prism Crash", "Quantum Leap", "Star Burst",
    "Vibe Flux", "Lava Twist", "Nightfall", "Cyber Hop",
    "Flash Tracer", "Redwire", "Moonstep", "End Shift"
}

---------------------------------------------------------
-- LEVEL SELECTION GRID
---------------------------------------------------------
LevelButtons = {}
do
    local startX = WindowWidth / 2 - 340
    local startY = 200
    local gapX = 180
    local gapY = 120
    local columns = 4
    local totalLevels = 12

    for i = 1, totalLevels do
        local row = math.floor((i - 1) / columns)
        local col = (i - 1) % columns

        table.insert(LevelButtons, {
            x = startX + col * gapX,
            y = startY + row * gapY,
            width = 160,
            height = 80,
            text = "Level " .. i .. "\n\n" .. LevelNames[i],
            id = i
        })
    end
end

function HandleJumpInput(inputType, inputValue)
    if not Player.isOnGround then return end
    
    local bs4 = ButtonsSettings.ControlOption
    local shouldJump = false
    
    if bs4.text == "Click" then
        if inputType == "mouse" and inputValue == 1 then
            shouldJump = true
        end
    elseif bs4.text == "Space" then
        if inputType == "key" and inputValue == "space" then
            shouldJump = true
        end
    elseif bs4.text == "Arrow" then
        if inputType == "key" and inputValue == "up" then
            shouldJump = true
        end
    end
    
    if shouldJump then
        Player.yVelocity = JUMP_VELOCITY
        Player.isOnGround = false
    end
end

return conf
