-- Configuration file for Geometry Dash Enhanced
local conf = {}

----------------------------------------------------------------
-- GAME CONSTANTS
----------------------------------------------------------------
TILE_SIZE = 32
WINDOW_WIDTH = 800
WINDOW_HEIGHT = 600
GAME_TITLE = "Geometry Dash Enhanced"

-- UI Constants
BUTTON_SIZE = 64

-- Physics Constants
GRAVITY = 2560          -- 32 * 80
JUMP_VELOCITY = -704    -- -32 * 22
BASE_SCROLL_SPEED = 256 -- 32 * 8

-- Performance Constants
MAX_DELTA_TIME = 1 / 30  -- Cap for smooth gameplay

----------------------------------------------------------------
-- DAILY REWARD SYSTEM
----------------------------------------------------------------
DAILY_REWARDS = {
    streakRewards = {
        [1] = {coins = 50, diamonds = 1},
        [2] = {coins = 75, diamonds = 1},
        [3] = {coins = 100, diamonds = 2},
        [4] = {coins = 150, diamonds = 2},
        [5] = {coins = 200, diamonds = 3},
        [6] = {coins = 250, diamonds = 3},
        [7] = {coins = 500, diamonds = 5}  -- Weekly bonus
    },
    maxStreak = 7
}

----------------------------------------------------------------
-- ACHIEVEMENTS SYSTEM ENHANCED
----------------------------------------------------------------
Achievements = {
    -- Gameplay Achievements
    { id = 1, name = "First Jump", description = "Make your first jump.", type = "jumps", goal = 1, rewardCoins = 10, rewardDiamonds = 0, achieved = false },
    { id = 2, name = "Jumper", description = "Make 100 jumps.", type = "jumps", goal = 100, rewardCoins = 50, rewardDiamonds = 1, achieved = false },
    { id = 3, name = "Athlete", description = "Make 10,000 jumps.", type = "jumps", goal = 10000, rewardCoins = 500, rewardDiamonds = 5, achieved = false },
    
    -- Coin Achievements
    { id = 4, name = "Coin Collector", description = "Collect 10 coins.", type = "coins", goal = 10, rewardCoins = 25, rewardDiamonds = 0, achieved = false },
    { id = 5, name = "Bank", description = "Collect 1,000 coins.", type = "coins", goal = 1000, rewardCoins = 250, rewardDiamonds = 2, achieved = false },
    
    -- Diamond Achievements
    { id = 6, name = "Diamond Miner", description = "Collect 10 diamonds.", type = "diamonds", goal = 10, rewardCoins = 100, rewardDiamonds = 5, achieved = false },
    { id = 7, name = "Rich", description = "Collect 1000 diamonds.", type = "diamonds", goal = 1000, rewardCoins = 500, rewardDiamonds = 10, achieved = false },
    
    -- Level Completion Achievements
    { id = 8, name = "Beginner", description = "Complete 1 level.", type = "levels", goal = 1, rewardCoins = 50, rewardDiamonds = 1, achieved = false },
    { id = 9, name = "Apprentice", description = "Complete 4 levels.", type = "levels", goal = 4, rewardCoins = 200, rewardDiamonds = 3, achieved = false },
    { id = 10, name = "Level Master", description = "Complete 8 levels.", type = "levels", goal = 8, rewardCoins = 500, rewardDiamonds = 5, achieved = false },
    { id = 11, name = "Level Maker", description = "Complete 12 levels.", type = "levels", goal = 12, rewardCoins = 1000, rewardDiamonds = 10, achieved = false },

    -- Skin Achievements
    { id = 12, name = "Visitor", description = "Purchase all skins from the shop.", type = "skins", goal = 7, rewardCoins = 400, rewardDiamonds = 2, achieved = false },
    { id = 13, name = "Shop Keeper", description = "Get all skins.", type = "skins", goal = 12, rewardCoins = 1000, rewardDiamonds = 5, achieved = false },
    
    -- Daily Login Achievements
    { id = 14, name = "Daily Visitor", description = "Claim your daily reward 1 time.", type = "days", goal = 1, rewardCoins = 25, rewardDiamonds = 1, achieved = false },
    { id = 15, name = "Weekly Visitor", description = "Claim your daily reward 7 times.", type = "days", goal = 7, rewardCoins = 175, rewardDiamonds = 7, achieved = false },
    { id = 16, name = "Monthly Visitor", description = "Claim your daily reward 30 times.", type = "days", goal = 30, rewardCoins = 750, rewardDiamonds = 30, achieved = false },
    
    -- Achievement Hunter
    { id = 17, name = "Determined", description = "Unlock 10 achievements.", type = "achievements", goal = 10, rewardCoins = 500, rewardDiamonds = 5, achieved = false },
    { id = 18, name = "Completionist", description = "Unlock all achievements.", type = "achievements", goal = 19, rewardCoins = 2000, rewardDiamonds = 20, achieved = false },

    { id = 19, name = "Persistent", description = "Die 100 times.", type = "deaths", goal = 100, rewardCoins = 100, rewardDiamonds = 1, achieved = false },
    { id = 20, name = "Grim Reaper", description = "Die 1000 times.", type = "deaths", goal = 1000, rewardCoins = 1000, rewardDiamonds = 5, achieved = false }
}

----------------------------------------------------------------
-- COLOR PALETTE
----------------------------------------------------------------
COLORS = {
    WHITE = {1, 1, 1},
    BLACK = {0, 0, 0},
    GRAY = {0.6, 0.6, 0.6},
    YELLOW = {1, 0.8, 0},
    RED = {1, 0.2, 0.2},
    GREEN = {0.2, 1, 0.45},
    BLUE = {0.2, 0.45, 1},
    PURPLE = {0.6, 0.2, 1},
    ORANGE = {1, 0.65, 0},
    CYAN = {0.2, 1, 1},
    PINK = {1, 0.2, 0.8},
    BROWN = {0.6, 0.4, 0.2},
    
    -- UI Colors
    UI_BACKGROUND = {0.12, 0.12, 0.12, 0.9},
    UI_BORDER = {0.4, 0.4, 0.4},
    UI_TEXT = {1, 1, 1},
    UI_HIGHLIGHT = {0.2, 0.8, 0.2},
    
    -- Achievement Colors
    ACHIEVEMENT_LOCKED = {0.3, 0.3, 0.3},
    ACHIEVEMENT_UNLOCKED = {0.2, 0.7, 0.2},
    ACHIEVEMENT_PROGRESS = {0.8, 0.8, 0.2}
}

LINE_WIDTHS = {
    BLACK = 6,
    WHITE = 4,
    THIN = 2,
    THICK = 8
}

----------------------------------------------------------------
-- PLAYER CONFIGURATION
----------------------------------------------------------------
PLAYER_CONFIG = {
    START_X = 100,
    START_Y = 0,
    WIDTH = 32,
    HEIGHT = 32,
    ROTATION_SPEED = math.pi * 2, -- radians per second
    DEFAULT_SKIN = 1,
    
    -- Physics Tweaks
    JUMP_BUFFER = 0.1, -- seconds of jump input buffer
    COYOTE_TIME = 0.1, -- seconds of coyote time for jumps
    JUMP_CUT_MULTIPLIER = 0.5, -- velocity multiplier when releasing jump

    -- Particle Effects
    JUMP_PARTICLES = 5,
    LAND_PARTICLES = 8,
    DEATH_PARTICLES = 15
}

PlayerStats = PlayerStats or {
    jumps = 0,
    deaths = 0,
    coins = 0,
    diamonds = 0,
    levelsCompleted = 0,
    ownedSkins = { [1] = true },
    daysClaimed = 0,
    achievementsUnlocked = 0
}

-- Player state (initial values)
Player = {
    x = PLAYER_CONFIG.START_X,
    y = PLAYER_CONFIG.START_Y,
    width = PLAYER_CONFIG.WIDTH,
    height = PLAYER_CONFIG.HEIGHT,
    yVelocity = 0,
    isOnGround = true,
    rotation = 0,
    rotationSpeed = PLAYER_CONFIG.ROTATION_SPEED,
    
    -- Enhanced physics
    jumpBufferTimer = 0,
    coyoteTimer = 0,
    lastGroundY = 0,
      
    -- Stats
    consecutiveJumps = 0,
    airTime = 0
}

----------------------------------------------------------------
-- PARTICLE SYSTEM CONFIGURATION
----------------------------------------------------------------
PARTICLE_CONFIG = {
    -- Jump Particles
    JUMP = {
        count = 8,
        minSize = 2,
        maxSize = 6,
        minSpeed = 50,
        maxSpeed = 150,
        minLifetime = 0.3,
        maxLifetime = 0.8,
        colors = {{1, 1, 0.5}, {1, 0.8, 0.2}, {1, 0.6, 0}}
    },
    
    -- Coin Collect Particles
    COIN = {
        count = 12,
        minSize = 3,
        maxSize = 8,
        minSpeed = 80,
        maxSpeed = 200,
        minLifetime = 0.4,
        maxLifetime = 1.0,
        colors = {{1, 1, 0}, {1, 0.9, 0.2}, {1, 0.8, 0}}
    },
    
    -- Death Particles
    DEATH = {
        count = 20,
        minSize = 4,
        maxSize = 12,
        minSpeed = 100,
        maxSpeed = 300,
        minLifetime = 0.5,
        maxLifetime = 1.5,
        colors = {{1, 0.2, 0.2}, {1, 0, 0}, {0.8, 0, 0}}
    },
    
    -- Level Complete Particles
    COMPLETE = {
        count = 30,
        minSize = 5,
        maxSize = 15,
        minSpeed = 50,
        maxSpeed = 250,
        minLifetime = 0.8,
        maxLifetime = 2.0,
        colors = {{0.2, 1, 0.2}, {0, 1, 0}, {0.2, 0.8, 0.2}}
    }
}

----------------------------------------------------------------
-- GAME STATE DEFINITIONS
----------------------------------------------------------------
GameState = {
    ACTIVE = "menu",
    MENU = "menu",
    PLAY = "play",
    GAMEOVER = "gameover",
    SETTINGS = "settings",
    LEVELSELECT = "levelselect",
    PAUSE = "pause",
    LEVELCOMPLETE = "levelcomplete",
    SHOP = "shop",
    CREDITS = "credits",
    ACHIEVEMENTS = "achievements",
    DAILY_REWARD = "dailyreward"  -- New state for daily rewards
}

----------------------------------------------------------------
-- SAVE DATA (Persistent progression)
----------------------------------------------------------------
SaveData = {
    coins = 0,
    diamonds = 0,
    ownedSkins = { [1] = true },
    equippedSkin = 1,
    lastClaim = "",  -- Last daily claim date (YYYY-MM-DD)
    streakCount = 0,  -- Current daily streak
    lastStreakDate = "",  -- Date of last streak update
    
    -- Statistics
    jumps = 0,
    deaths = 0,
    achievements = 0,
    levelsCompleted = 0,
    totalCoinsCollected = 0,
    totalDiamondsCollected = 0,
    totalPlayTime = 0,  -- in seconds
    
    -- Level Progress
    unlockedLevels = { [1] = true },
    levelStars = {},  -- Store star ratings per level
    
    -- Settings
    settings = {
        musicEnabled = true,
        scrollSpeed = 1,
        controls = "Click",
        theme = "White",
        particles = true,
        showStats = true,
    },
    
    -- Achievements Progress
    achievementProgress = {
        jumps = 0,
        coins = 0,
        diamonds = 0,
        levels = 0,
        skins = 0,
        days = 0,
        achievements = 0,
        deaths = 0,
    }
}

-- Default save snapshot used when resetting or deleting save.dat
DefaultSaveData = {
    coins = 0,
    diamonds = 0,
    ownedSkins = { [1] = true },
    equippedSkin = 1,
    lastClaim = "",
    streakCount = 0,
    lastStreakDate = "",
    jumps = 0,
    deaths = 0,
    achievements = 0,
    levelsCompleted = 0,
    totalCoinsCollected = 0,
    totalDiamondsCollected = 0,
    totalPlayTime = 0,
    unlockedLevels = { [1] = true },
    levelStars = {},
    settings = {
        musicEnabled = true,
        scrollSpeed = 1,
        controls = "Click",
        theme = "White",
        particles = false,  -- Particles disabled by default in levels
        showStats = true,
    },
    achievementProgress = {
        jumps = 0, coins = 0, diamonds = 0, levels = 0, skins = 0, days = 0, achievements = 0, deaths = 0
    }
}

----------------------------------------------------------------
-- SKINS SYSTEM EXPANDED
----------------------------------------------------------------
Skins = {
    { id = 1, name = "Default", price = 0, color = {1, 1, 1}, unlocked = true, rarity = "Common" },
    { id = 2, name = "Crimson", price = 200, color = {1.0, 0.2, 0.2}, unlocked = false, rarity = "Common" },
    { id = 3, name = "Cobalt", price = 350, color = {0.2, 0.45, 1.0}, unlocked = false, rarity = "Common" },
    { id = 4, name = "Emerald", price = 500, color = {0.2, 1.0, 0.45}, unlocked = false, rarity = "Rare" },
    { id = 5, name = "Solar", price = 700, color = {1.0, 0.85, 0.2}, unlocked = false, rarity = "Rare" },
    { id = 6, name = "Violet", price = 900, color = {0.6, 0.2, 1.0}, unlocked = false, rarity = "Rare" },
    { id = 7, name = "Golden", price = 1500, color = {1.0, 0.84, 0.0}, unlocked = false, rarity = "Epic" },
    { id = 8, name = "Rainbow", price = 2500, color = {1.0, 0.0, 0.0}, unlocked = false, rarity = "Legendary" },
    { id = 9, name = "Achiever", price = 10000, color = {0.2, 0.8, 0.2}, unlocked = false, rarity = "Special" },
    { id = 10, name = "Completionist", price = 10000, color = {0.8, 0.2, 1.0}, unlocked = false, rarity = "Special" },
    { id = 11, name = "Streak Master", price = 10000, color = {1.0, 0.5, 0.0}, unlocked = false, rarity = "Special" },
    { id = 12, name = "Diamond King", price = 10000, color = {0.2, 1.0, 1.0}, unlocked = false, rarity = "Special" }
}

-- Skin rarity colors
SKIN_RARITY_COLORS = {
    Common = {0.8, 0.8, 0.8},
    Rare = {0.2, 0.6, 1.0},
    Epic = {0.8, 0.2, 1.0},
    Legendary = {1.0, 0.84, 0.0},
    Special = {0.2, 1.0, 0.2}
}

----------------------------------------------------------------
-- LEVEL REWARDS SYSTEM
----------------------------------------------------------------
LEVEL_REWARDS = {
    [1] = {coins = 5, diamonds = 1},
    [2] = {coins = 5, diamonds = 1},
    [3] = {coins = 10, diamonds = 1},
    [4] = {coins = 10, diamonds = 1},
    [5] = {coins = 15, diamonds = 2},
    [6] = {coins = 15, diamonds = 2},
    [7] = {coins = 20, diamonds = 2},
    [8] = {coins = 20, diamonds = 2},
    [9] = {coins = 25, diamonds = 3},
    [10] = {coins = 25, diamonds = 3},
    [11] = {coins = 30, diamonds = 3},
    [12] = {coins = 50, diamonds = 5}
}

----------------------------------------------------------------
-- UI BUTTON DEFINITIONS
----------------------------------------------------------------
Buttons = {
    start = {x = BUTTON_SIZE * 4.25, y = 250, width = BUTTON_SIZE * 4, height = 50, text = "Start Game"},
    levelselect = {x = BUTTON_SIZE * 4.25, y = 310, width = BUTTON_SIZE * 4, height = 50, text = "Level Select"},
    settings = {x = BUTTON_SIZE * 4.25, y = 370, width = BUTTON_SIZE * 4, height = 50, text = "Settings"},
    exit = {x = BUTTON_SIZE * 4.25, y = 430, width = BUTTON_SIZE * 4, height = 50, text = "Exit"},
    credits = {x = BUTTON_SIZE * 9.25, y = WINDOW_HEIGHT - 48, width = BUTTON_SIZE * 3, height = 40, text = "Credits"},
    achievements = {x = BUTTON_SIZE / 3.5, y = WINDOW_HEIGHT - 48, width = BUTTON_SIZE * 5, height = 40, text = "Achievements"},
    shop = {x = BUTTON_SIZE * 5.75, y = WINDOW_HEIGHT - 48, width = BUTTON_SIZE * 3, height = 40, text = "Shop"},
    daily = {x = BUTTON_SIZE / 3.5, y = 8, width = BUTTON_SIZE * 2, height = 40, text = "Daily"}  -- New daily button
}
-- In-game pause button
ButtonPause = {
    x = WINDOW_WIDTH - 110, y = 10, width = 100, height = 30, text = "Pause"
}

-- Pause menu buttons
ButtonsPause = {
    Resume = {x = WINDOW_WIDTH / 2 - 100, y = 250, width = 200, height = 50, text = "Resume"},
    Exit = {x = WINDOW_WIDTH / 2 - 100, y = 310, width = 200, height = 50, text = "Exit to Menu"},
    Settings = {x = WINDOW_WIDTH / 2 - 100, y = 370, width = 200, height = 50, text = "Settings"}
}

-- Game over buttons
ButtonsGameover = {
    Retry = {x = WINDOW_WIDTH / 2 - 100, y = 250, width = 200, height = 50, text = "Retry"},
    Exit = {x = WINDOW_WIDTH / 2 - 100, y = 310, width = 200, height = 50, text = "Exit to Menu"}
}

-- Level complete buttons
LevelCompleteButtons = {
    next = {x = WINDOW_WIDTH/2 - 120, y = 330, width = 240, height = 50, text = "Next Level"},
    menu = {x = WINDOW_WIDTH/2 - 120, y = 400, width = 240, height = 50, text = "Back To Menu"},
    replay = {x = WINDOW_WIDTH/2 - 120, y = 260, width = 240, height = 50, text = "Play Again"}
}

ButtonsSettings = {
    Music = {x = BUTTON_SIZE, y = BUTTON_SIZE, width = BUTTON_SIZE * 4, height = BUTTON_SIZE, text = "Music"},
    MusicOption = {x = 480, y = BUTTON_SIZE, width = BUTTON_SIZE * 2, height = BUTTON_SIZE, text = "Y"},
    Speed = {x = BUTTON_SIZE, y = BUTTON_SIZE * 2.5, width = BUTTON_SIZE * 4, height = BUTTON_SIZE, text = "Speed"},
    SpeedOption = {x = 480, y = BUTTON_SIZE * 2.5, width = BUTTON_SIZE * 2, height = BUTTON_SIZE, text = "1"},
    Controls = {x = BUTTON_SIZE, y = BUTTON_SIZE * 4, width = BUTTON_SIZE * 4, height = BUTTON_SIZE, text = "Controls"},
    ControlOption = {x = 480, y = BUTTON_SIZE * 4, width = BUTTON_SIZE * 2.5, height = BUTTON_SIZE, text = "Click"},
    Theme = {x = BUTTON_SIZE, y = BUTTON_SIZE * 5.5, width = BUTTON_SIZE * 4, height = BUTTON_SIZE, text = "Theme"},
    ThemeOption = {x = 480, y = BUTTON_SIZE * 5.5, width = BUTTON_SIZE * 2, height = BUTTON_SIZE, text = "White"},
    Exit = {x = BUTTON_SIZE * 4, y = BUTTON_SIZE * 7.25, width = BUTTON_SIZE * 4, height = BUTTON_SIZE, text = "Exit"}
}

-- Daily Reward buttons
ButtonsDaily = {
    claim = {x = WINDOW_WIDTH/2 - 100, y = 300, width = 200, height = 50, text = "Claim Reward"},
    close = {x = WINDOW_WIDTH/2 - 100, y = 360, width = 200, height = 50, text = "Close"}
}

----------------------------------------------------------------
-- SHOP BUTTONS (Generated dynamically)
----------------------------------------------------------------
ButtonsShop = {}
do
    local startX = BUTTON_SIZE
    local startY = BUTTON_SIZE
    local itemWidth = BUTTON_SIZE * 6
    local itemHeight = BUTTON_SIZE / 2
    local gap = 12
    local itemsPerColumn = 6
    
    local leftX = 16
    local rightX = 409.6
    
    for i, skin in ipairs(Skins) do
        
        local column = math.ceil(i / itemsPerColumn)
        local row = ((i - 1) % itemsPerColumn) + 1
        
        local x = (column == 1) and leftX or rightX
        local y = startY + (row - 1) * (itemHeight + gap)

        ButtonsShop['skin' .. i] = {
            x = x,
            y = y,
            width = itemWidth,
            height = itemHeight,
            text = skin.name .. " - " .. skin.price .. " coins",
            id = skin.id,
            price = skin.price,
            rarity = skin.rarity
        }
    end
    
    ButtonsShop.Exit = {
        x = BUTTON_SIZE * 4,
        y = BUTTON_SIZE * 7.5,
        width = BUTTON_SIZE * 4,
        height = BUTTON_SIZE,
        text = "Exit"
    }
end

----------------------------------------------------------------
-- CURRENCY AND INVENTORY BUTTONS
----------------------------------------------------------------
ButtonsCurrency = {
    Diamond = { x = WINDOW_WIDTH - 220, y = 10, width = 100, height = 36, text = "Diamonds"},
    Coin = { x = WINDOW_WIDTH - 120, y = 10, width = 100, height = 36, text = "Coins"},
}

ButtonsInventory = {
    Inventory = { x = WINDOW_WIDTH - 320, y = 10, width = BUTTON_SIZE * 3, height = 36, text = "Skin =" }
}

----------------------------------------------------------------
-- ACHIEVEMENTS BUTTONS (Generated dynamically)
----------------------------------------------------------------
ButtonsAchievements = {}
do
    local startX = BUTTON_SIZE
    local startY = BUTTON_SIZE
    local itemWidth = BUTTON_SIZE * 6
    local itemHeight = BUTTON_SIZE / 2
    local gap = 12
    local itemsPerColumn = 11
    
    local leftX = 16
    local rightX = 409.6
    
    for i, achievement in ipairs(Achievements) do
        local column = math.ceil(i / itemsPerColumn)
        local row = ((i - 1) % itemsPerColumn) + 1
        
        local x = (column == 1) and leftX or rightX
        local y = startY + (row - 1) * (itemHeight + gap)
        
        ButtonsAchievements["achievement" .. i] = {
            x = x,
            y = y,
            width = itemWidth,
            height = itemHeight,
            text = achievement.name,
            id = achievement.id,
            description = achievement.description,
            achieved = achievement.achieved
        }
    end

    local totalHeight = 504
    local centerX = (leftX + rightX) / 2
    
    ButtonsAchievements.Exit = {
        x = centerX,
        y = totalHeight,
        width = itemWidth,
        height = itemHeight * 2,
        text = "Exit"
    }
    
end

----------------------------------------------------------------
-- CREDITS SCREEN
----------------------------------------------------------------
ButtonsCredits = {
    credit1 = {x = BUTTON_SIZE, y = BUTTON_SIZE, width = BUTTON_SIZE * 10.5, height = BUTTON_SIZE, text = "Developer/Designer:"},
    credit1name = {x = BUTTON_SIZE * 2, y = BUTTON_SIZE * 2.16, width = BUTTON_SIZE * 8, height = BUTTON_SIZE, text = "Muhammad Arsal"},
    credit2 = {x = BUTTON_SIZE, y = BUTTON_SIZE * 4, width = BUTTON_SIZE * 10.5, height = BUTTON_SIZE, text = "Studio/Community Support:"},
    credit2name = {x = BUTTON_SIZE * 2, y = BUTTON_SIZE * 5.16, width = BUTTON_SIZE * 8, height = BUTTON_SIZE, text = "LoomShade/Love2D Community"},
    Exit = {x = BUTTON_SIZE * 4, y = BUTTON_SIZE * 6.5, width = BUTTON_SIZE * 4, height = BUTTON_SIZE, text = "Exit"}
}    

ButtonsLevelSelect = {
    Exit = {x = BUTTON_SIZE * (math.sqrt(2) * 2), y = BUTTON_SIZE * 7.5, width = BUTTON_SIZE * 7, height = BUTTON_SIZE, text = "Exit"}
}

----------------------------------------------------------------
-- LEVEL SYSTEM
----------------------------------------------------------------
LevelNames = {
    "Scramble", "Platformis", "Shadow Run", "Pulse Drift", "Echo Breaker", "Wave Storm",
    "Neon Bloom", "Frost Edge", "Hyper Dash", "Prism Crash", "Quantum Leap", "Star Burst"
}

-- Level selection grid
LevelButtons = {}
do
    local startX = BUTTON_SIZE/math.sqrt(2)
    local startY = 100
    local gapX = 240
    local gapY = BUTTON_SIZE*math.sqrt(2)
    local columns = 3
    local totalLevels = 12
    local width = BUTTON_SIZE*3.5
    local height = BUTTON_SIZE*1.3
    
    for i = 1, totalLevels do
        local row = math.floor((i - 1) / columns)
        local col = (i - 1) % columns
        
        table.insert(LevelButtons, {
            x = startX + col * gapX,
            y = startY + row * gapY,
            width = width,
            height = height,
            text = "Level " .. i .. "\n" .. LevelNames[i],
            id = i,
            locked = not (SaveData.unlockedLevels and SaveData.unlockedLevels[i])
        })
    end
end

----------------------------------------------------------------
-- SPRITE SYSTEM
----------------------------------------------------------------
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

-- Safe sprite loading
local function safeLoad(path)
    if path and love.filesystem.getInfo(path) then
        local success, image = pcall(love.graphics.newImage, path)
        if success then return image end
    end
    return nil
end

function LoadSprites()
    Sprites.block = safeLoad("Sprites/block.png")
    Sprites.coin = safeLoad("Sprites/coin.png")
    Sprites.player = safeLoad("Sprites/player.png")
    Sprites.spike = safeLoad("Sprites/spike.png")
    Sprites.minispike = safeLoad("Sprites/mini_spike.png")
    Sprites.bigspike = safeLoad("Sprites/big_spike.png")
    Sprites.flippedminispike = safeLoad("Sprites/flipped_mini_spike.png")
    Sprites.platform = safeLoad("Sprites/platform.png") or Sprites.block
    
    -- Load particle sprites if available
    Sprites.particle = safeLoad("Sprites/particle.png")
    Sprites.star = safeLoad("Sprites/star.png")
end

-- Draw sprite with auto-scaling
function DrawTileSprite(image, x, y, width, height, r, g, b)
    if image then
        local imgWidth, imgHeight = image:getWidth(), image:getHeight()
        if imgWidth == 0 or imgHeight == 0 then return end
        
        if r and g and b then
            love.graphics.setColor(r, g, b)
        else
            love.graphics.setColor(1, 1, 1)
        end
        
        love.graphics.draw(image, x, y, 0, width / imgWidth, height / imgHeight)
    else
        -- Fallback rectangle
        if r and g and b then
            love.graphics.setColor(r, g, b)
        else
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.rectangle("fill", x, y, width, height)
    end
end

----------------------------------------------------------------
-- SOUND SYSTEM CONFIGURATION
----------------------------------------------------------------
SoundEffects = {
    enabled = true,
    volume = 0.7,
    
    -- Sound file paths (to be loaded)
    jump = nil,
    coin = nil,
    death = nil,
    complete = nil,
    click = nil,
    achievement = nil
}

----------------------------------------------------------------
-- UTILITY FUNCTIONS
----------------------------------------------------------------

-- Get level reward with bug fix
function GetLevelReward(levelId)
    if not levelId or levelId < 1 or levelId > 12 then
        return 0, 0
    end
    
    local reward = LEVEL_REWARDS[levelId]
    if reward then
        return reward.coins, reward.diamonds
    end
    
    -- Fallback rewards
    if levelId <= 4 then
        return 5, 1
    elseif levelId <= 8 then
        return 10, 2
    else
        return 20, 3
    end
end

-- Check if level is unlocked with error handling
function IsLevelUnlocked(levelId)
    if not levelId or levelId < 1 then return false end
    if levelId == 1 then return true end
    return SaveData.unlockedLevels and SaveData.unlockedLevels[levelId] or false
end

-- Format large numbers for display
function FormatNumber(num)
    if not num then return "0" end
    
    num = math.floor(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 10000 then
        return string.format("%.1fK", num / 1000)
    elseif num >= 1000 then
        return string.format("%d,%03d", math.floor(num / 1000), num % 1000)
    else
        return tostring(num)
    end
end

-- Check daily reward eligibility
function CanClaimDaily()
    local today = os.date("%Y-%m-%d")
    local lastClaim = SaveData.lastClaim or ""
    local streakCount = SaveData.streakCount or 0
    local lastStreakDate = SaveData.lastStreakDate or ""
    
    -- If never claimed before
    if lastClaim == "" then
        return true, 1, "First claim!"
    end
    
    -- If claimed today already
    if lastClaim == today then
        return false, streakCount, "Already claimed today"
    end
    
    -- Check if streak continues (claimed yesterday)
    local yesterday = os.date("%Y-%m-%d", os.time() - 86400)
    if lastClaim == yesterday then
        -- Continue streak
        local newStreak = math.min((streakCount or 0) + 1, DAILY_REWARDS.maxStreak)
        return true, newStreak, "Day " .. newStreak .. " streak!"
    else
        -- Broken streak, start over
        return true, 1, "New streak started!"
    end
end

-- Get daily reward amount
function GetDailyReward(streakDay)
    streakDay = math.min(streakDay or 1, DAILY_REWARDS.maxStreak)
    local reward = DAILY_REWARDS.streakRewards[streakDay]
    if reward then
        return reward.coins, reward.diamonds
    end
    return 50, 1  -- Default reward
end

----------------------------------------------------------------
-- INITIALIZATION
----------------------------------------------------------------

-- Initialize default values
function InitializeDefaults()
    -- Ensure SaveData has all required fields
    SaveData = SaveData or {}
    SaveData.settings = SaveData.settings or {}
    
    -- Set defaults if not present
    SaveData.settings.musicEnabled = SaveData.settings.musicEnabled ~= false
    SaveData.settings.scrollSpeed = SaveData.settings.scrollSpeed or 1
    SaveData.settings.controls = SaveData.settings.controls or "Click"
    SaveData.settings.theme = SaveData.settings.theme or "White"
    SaveData.settings.particles = SaveData.settings.particles ~= false
    SaveData.settings.showStats = SaveData.settings.showStats ~= false
    
    -- Initialize achievement progress
    SaveData.achievementProgress = SaveData.achievementProgress or {
        jumps = 0,
        coins = 0,
        diamonds = 0,
        levels = 0,
        skins = 0,
        days = 0,
        achievements = 0,
        deaths = 0
    }
    
    -- Initialize level stars
    SaveData.levelStars = SaveData.levelStars or {}
    
    -- Initialize unlocked levels
    SaveData.unlockedLevels = SaveData.unlockedLevels or {}
    if not SaveData.unlockedLevels[1] then
        SaveData.unlockedLevels[1] = true
    end
end

-- Call initialization
InitializeDefaults()

return conf