-- conf.lua (FULL VERSION)
local conf = {}

---------------------------------------------------------
-- GLOBAL CONSTANTS
---------------------------------------------------------
TILE = 32
WindowWidth = 800
WindowHeight = 600
Title = "Geometry Dash"
SB = 64

Gravity = (32 * 80)          -- 2560
JUMP_VELOCITY = (-32 * 22)   -- -704
Ss = (32 * 8)  -- 256 scroll speed

Color = {
    white = {1, 1, 1},
    black = {0, 0, 0},
    gray = {0.6,0.6,0.6},
    yellow = {1,0.8,0}
}

Linewidth = {
    black = 6,
    white = 4
}

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
    start = {x = SB*4.25, y = 250, width = SB*4, height = 50, text = "Start Game"},
    levelselect = {x = SB*4.25, y = 310, width = SB*4, height = 50, text = "Level Select"},
    settings = {x = SB*4.25, y = 370, width = SB*4, height = 50, text = "Settings"},
    exit = {x = SB*4.25, y = 430, width = SB*4, height = 50, text = "Exit"},
    credits = {x = 624, y = WindowHeight - 48, width = 160, height = 40, text = "Credits"},
    achievements = {x = 8, y = WindowHeight - 48, width = SB*4, height = 40, text = "Achievements"},
    changelog = {x = 272, y = WindowHeight - 48, width = SB*3.25, height = 40, text = "Changelog"},
    shop = {x = 488, y = WindowHeight - 48, width = SB*2, height = 40, text = "Shop"}
}

ButtonPause = {
     x = WindowWidth - 110, y = 10, width = 100, height = 30, text = "Pause" 
}

ButtonsMobile = {
    -- Large on-screen jump button for mobile testing
    Jump = { x = WindowWidth - 110, y = WindowHeight - 110, width = 100, height = 100, text = "Jump" }
}

ButtonsPause = {
    Resume = {x = WindowWidth / 2 - 100, y = 250, width = 200, height = 50, text = "Resume"},
    Exit    = {x = WindowWidth / 2 - 100, y = 310, width = 200, height = 50, text = "Exit to Menu"},
    Settings= {x = WindowWidth / 2 - 100, y = 370, width = 200, height = 50, text = "Settings"}
}

ButtonsGameover = {
    Retry = {x = WindowWidth / 2 - 100, y = 250, width = 200, height = 50, text = "Retry"},
    Exit = {x = WindowWidth / 2 - 100, y = 310, width = 200, height = 50, text = "Exit to Menu"}
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
    Theme = {x = SB, y = SB*5.5, width = SB*4, height = SB, text = "Theme"},
    ThemeOption = {x = 480, y = SB*5.5, width = SB*2, height = SB, text = "White"},
    be2 = {x = SB, y = SB*7, width = SB*4, height = SB, text = "be2"},
    be2Option = {x = 480, y = SB*7, width = SB*2, height = SB, text = "Null"},
    Exit = {x = SB*4, y = SB*8.25, width = SB*4, height = SB, text = "Exit"}
}

-- Currency & Save data
-- SaveData holds persistent progression (coins, diamonds, owned skins, equipped skin)
SaveData = {
    coins = 300,       -- start with some coins for testing
    diamonds = 3,      -- starting diamonds
    ownedSkins = { [1] = true }, -- default skin (id=1) is owned
    equippedSkin = 1,
    lastClaim = "" -- YYYY-MM-DD when daily was last claimed
}

-- Skins available in the shop (id, name, price in coins, color swatch)
Skins = {
    { id = 1, name = "Default", price = 0, color = {1,1,1} },
    { id = 2, name = "Crimson", price = 200, color = {1.0,0.2,0.2} },
    { id = 3, name = "Cobalt", price = 350, color = {0.2,0.45,1.0} },
    { id = 4, name = "Emerald", price = 500, color = {0.2,1.0,0.45} },
    { id = 5, name = "Solar", price = 700, color = {1.0,0.85,0.2} },
    { id = 6, name = "Violet", price = 900, color = {0.6,0.2,1.0} },
}

-- Generate ButtonsShop dynamically from Skins
ButtonsShop = {}
do
    local startX = SB
    local startY = SB
    local itemWidth = SB * 6
    local itemHeight = SB / 2
    local gap = 12
    for i, s in ipairs(Skins) do
        ButtonsShop['skin' .. i] = { x = startX, y = startY + (i - 1) * (itemHeight + gap), width = itemWidth, height = itemHeight, text = s.name, id = s.id, price = s.price }
    end
    ButtonsShop.Exit = { x = SB*4, y = startY + (#Skins) * (itemHeight + gap) + 24, width = SB*4, height = SB, text = "Exit" }
    -- Claim daily diamonds button (at top of shop view)
    ButtonsShop.Claim = { x = SB, y = startY - (itemHeight + gap), width = SB*4, height = itemHeight, text = "Claim Daily" }
end

-- Small clickable currency displays and inventory (skin changer) in top-right of menu
ButtonsCurrency = {
    Diamond = { x = WindowWidth - 220, y = 10, width = 100, height = 36, text = "Diamonds"},
    Coin =    { x = WindowWidth - 120, y = 10, width = 100, height = 36, text = "Coins"},
}

ButtonsInventory = {
    Inventory = { x = SB * 5.8, y = 10, width = SB * 3, height = 36, text = "Skin =" }
}

-- Account button in top-right
ButtonsAccount = {
    Account = { x = 8, y = 10, width = SB * 2, height = 36, text = "Account" }
}

ButtonsAchievements = {
    achievement1 = {x = SB, y = SB, width = SB*6, height = SB, text = "Achievement 1"},
    achievement2 = {x = SB, y = SB*2.5, width = SB*6, height = SB, text = "Achievement 2"},
    achievement3 = {x = SB, y = SB*4, width = SB*6, height = SB, text = "Achievement 3"},
    Exit = {x = SB*4, y = SB*6.5, width = SB*4, height = SB, text = "Exit"}
}

-- Changelog entries with details (add more entries here)
ChangelogEntries = {
    { title = "Update 1.0 - Initial", details = "Initial release with basic platforming, spikes, and coins." },
    { title = "Update 1.1 - Blocks & Spikes", details = "Added mini spikes, big spikes, and block collision improvements." },
    { title = "Update 1.2 - Levels", details = "Added more levels and improved level parsing. Added duration variability and environmental polish." },
    { title = "Update 1.3 - Rotation", details = "Improved player rotation and landing snap for a smoother experience." },
    { title = "Update 1.4 - Music & UI", details = "Added procedural music and better menu flow." },
    { title = "Update 1.5 - Platform & Coins", details = "Platform collision now only detects from the top; coins got visual polish." },
    { title = "Update 1.6 - Shop", details = "Added a shop screen with placeholder items and currency handling." },
    { title = "Update 1.7 - Achievements", details = "Added an achievements UI panel with tracking logic." },
    { title = "Update 1.8 - Improvements", details = "Various performance fixes and level balancing." },
}

-- Generate ButtonsChangelog from ChangelogEntries (vertical list)
ButtonsChangelog = {}
do
    local startX = SB 
    local startY = SB + 16
    local itemWidth = SB * 8.8
    local itemHeight = SB / 2
    local gap = 12
    for i, entry in ipairs(ChangelogEntries) do
        ButtonsChangelog['changelog' .. i] = { x = startX, y = startY + (i - 1) * (itemHeight + gap), width = itemWidth, height = itemHeight, text = entry.title, id = i }
    end
    ButtonsChangelog.Exit = { x = SB*4, y = startY + (#ChangelogEntries) * (itemHeight + gap) + 24, width = SB*4, height = SB, text = "Exit" }
end

-- Current vertical scroll position for the changelog list (negative = scrolled up)
ChangelogScroll = 0
ShopScroll = 0

ButtonsCredits = {
    credit1 = {x = SB, y = SB, width = SB*10.5, height = SB, text = "Developer/Designer:"},
    credit1name = {x = SB*2, y = SB*2.16, width = SB*8, height = SB, text = "Muhammad Arsal"},
    credit2 = {x = SB*2.24, y = SB*4, width = SB*7.5, height = SB, text = "Helper/Music:"},
    credit2name = {x = SB*2.32, y = SB*5.16, width = SB*7, height = SB, text = "Gotham Kumar"},
    Exit = {x = SB*4, y = SB*6.5, width = SB*4, height = SB, text = "Exit"}
}

ButtonsLevelSelect = {
    Exit = {x = SB*4, y = SB*8.25, width = SB*4, height = SB, text = "Exit"}
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
    local startX = 50
    local startY = 80
    local gapX = 240
    local gapY = 112
    local columns = 3
    local totalLevels = 12

    for i = 1, totalLevels do
        local row = math.floor((i - 1) / columns)
        local col = (i - 1) % columns

        table.insert(LevelButtons, {
            x = startX + col * gapX,
            y = startY + row * gapY,
            width = 220,
            height = 96,
            text = "Level " .. i .. "\n" .. LevelNames[i],
            id = i
        })
    end
end

return conf