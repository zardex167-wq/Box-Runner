-- main.lua
-- Geo Dash (with new block types: Transparent, Platform, Mini Spike, Big Spike)
-- Tile size = 32px

---------------------------------------------------------
-- CONFIG / CONSTANTS
---------------------------------------------------------
TILE = 32
WindowWidth = 800
WindowHeight = 600

Gravity = 1400          -- gravity (tuned for snappy jumps)
JUMP_VELOCITY = -500    -- initial jump impulse
Ss = 200                -- Scroll speed

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
    bigspike    = nil  -- Sprites/bigspike.png
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

---------------------------------------------------------
-- Level Buttons (grid)
---------------------------------------------------------
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

---------------------------------------------------------
-- OBJECT TABLES (world positions)
---------------------------------------------------------
GroundObjects = {}   -- { x,y,width,height }
SpikeObjects = {}
CoinObjects = {}
BlockObjects = {}
FinishObjects = {}

-- NEW object lists:
TransparentObjects = {} -- T (no collision)
PlatformObjects    = {} -- P (top-only collision; half height tile visually if desired)
MiniSpikeObjects   = {} -- V (half height, 16px tall)
BigSpikeObjects    = {} -- W (double height, 64px tall)

TotalCoinsCollected = 0
CurrentLevel = nil
CurrentLevelID = 1

---------------------------------------------------------
-- INLINE LEVELS (supports new chars: T,P,V,W)
-- Characters: G ground, B block, S spike, C coin, F finish, T transparent, P platform, V minispike, W bigspike
---------------------------------------------------------
Levels = {
    [1] = {
        scrollSpeed = Ss,
        rows = {
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                           C                                    ",
            "                     C                                                          ",
            "             B      B       V    S            P       B         F              ",
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG"
        }
    },

    [2] = {
        scrollSpeed = Ss,
        rows = {
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "              C               C                                                 ",
            "         B     B     B   W     S                 B       B          F           ",
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG"
        }
    },

    [3] = {
        scrollSpeed = Ss,
        rows = {
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "        T                                                                       ",
            "        T                                                                       ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "      C           B    C                         B                              ",
            "   B   B     B       B      S                  BBBBB               F          ",
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG"
        }
    }
}

---------------------------------------------------------
-- LOVE LOAD
---------------------------------------------------------
function love.load()
    love.window.setTitle("Geo Dash")
    love.window.setMode(WindowWidth, WindowHeight)

    if love.filesystem.getInfo("Fonts/PressStart2P-Regular.ttf") then
        Font1 = love.graphics.newFont("Fonts/PressStart2P-Regular.ttf", 28)
        Font  = love.graphics.newFont("Fonts/PressStart2P-Regular.ttf", 14)
    else
        Font1 = love.graphics.newFont(28)
        Font  = love.graphics.newFont(14)
    end
    love.graphics.setFont(Font)

    LoadSprites()
    GameState.active = GameState.menu
end

---------------------------------------------------------
-- AABB helper (rectangle vs rectangle)
---------------------------------------------------------
local function AABBRect(ax, ay, aw, ah, bx, by, bw, bh)
    return ax < bx + bw and bx < ax + aw and ay < by + bh and by < ay + ah
end

---------------------------------------------------------
-- LEVEL PARSER: from rows -> object tables
---------------------------------------------------------
function LoadLevel(levelID)
    if not Levels[levelID] then
        CurrentLevel = nil
        CurrentLevelID = 0
        GameState.active = GameState.menu
        return
    end

    CurrentLevelID = levelID
    CurrentLevel = Levels[levelID]

    -- clear object lists
    GroundObjects = {}
    SpikeObjects = {}
    CoinObjects = {}
    BlockObjects = {}
    FinishObjects = {}
    TransparentObjects = {}
    PlatformObjects = {}
    MiniSpikeObjects = {}
    BigSpikeObjects = {}

    local rows = CurrentLevel.rows

    for row = 1, #rows do
        local line = rows[row]
        for col = 1, #line do
            local ch = line:sub(col, col)
            local x = (col - 1) * TILE
            local y = (row - 1) * TILE

            if ch == "G" then
                table.insert(GroundObjects, {x = x, y = y, width = TILE, height = TILE})
            elseif ch == "B" then
                table.insert(BlockObjects, {x = x, y = y, width = TILE, height = TILE})
            elseif ch == "S" then
                table.insert(SpikeObjects, {x = x, y = y, width = TILE, height = TILE})
            elseif ch == "C" then
                table.insert(CoinObjects, {x = x, y = y, width = TILE, height = TILE, collected = false})
            elseif ch == "F" then
                table.insert(FinishObjects, {x = x, y = y, width = TILE, height = TILE})
            elseif ch == "T" then
                table.insert(TransparentObjects, {x = x, y = y, width = TILE, height = TILE})
            elseif ch == "P" then
                -- platform is half-height visually (player lands on top); store full tile but collision is top-only
                table.insert(PlatformObjects, {x = x, y = y + (TILE/2), width = TILE, height = TILE/2})
            elseif ch == "V" then
                -- mini spike: half height (16px)
                table.insert(MiniSpikeObjects, {x = x, y = y + (TILE/2), width = TILE, height = TILE/2})
            elseif ch == "W" then
                -- big spike: 2x height (place its top one tile above)
                table.insert(BigSpikeObjects, {x = x, y = y - TILE, width = TILE, height = TILE * 2})
            end
        end
    end

    -- reset player
    Player.x = 100
    Player.y = WindowHeight - 150
    Player.yVelocity = 0
    Player.isOnGround = false
    TotalCoinsCollected = 0
end

---------------------------------------------------------
-- UPDATE PLAYER (Geometry Dash style) - improved
---------------------------------------------------------
function UpdatePlayer(dt)
    if not CurrentLevel then return end

    local prevY = Player.y
    Player.y = Player.y + Player.yVelocity * dt
    Player.yVelocity = Player.yVelocity + Gravity * dt

    -- death if too far below screen
    if Player.y > WindowHeight + 200 then
        GameState.active = GameState.gameover
        return
    end

    Player.isOnGround = false

    -- generic landing resolver (used for ground, blocks)
    local function resolveLanding(list)
        for _, obj in ipairs(list) do
            -- check if player was above top previously and now overlaps top region
            if (prevY + Player.height) <= (obj.y + 4) and (Player.y + Player.height) >= obj.y then
                if Player.x + Player.width > obj.x and Player.x < obj.x + obj.width then
                    -- place player on top
                    Player.y = obj.y - Player.height
                    Player.yVelocity = 0
                    Player.isOnGround = true
                    return true
                end
            end
        end
        return false
    end

    -- prefer landing on block then ground then platform
    if resolveLanding(BlockObjects) then return end
    if resolveLanding(GroundObjects) then return end

    -- platform: top-only collision; stored as half-height with its y at top of platform surface
    for _, p in ipairs(PlatformObjects) do
        if (prevY + Player.height) <= (p.y + 4) and (Player.y + Player.height) >= p.y then
            if Player.x + Player.width > p.x and Player.x < p.x + p.width then
                Player.y = p.y - Player.height
                Player.yVelocity = 0
                Player.isOnGround = true
                return
            end
        end
    end

    -- head bump detection (when moving up into underside of block/ground)
    local function resolveHeadHit(list)
        for _, obj in ipairs(list) do
            if AABBRect(Player.x, Player.y, Player.width, Player.height, obj.x, obj.y, obj.width, obj.height) then
                if prevY >= (obj.y + obj.height) then
                    -- push player below the object and stop upward velocity
                    Player.y = obj.y + obj.height
                    Player.yVelocity = 0
                    return true
                end
            end
        end
        return false
    end
    resolveHeadHit(BlockObjects)
    resolveHeadHit(GroundObjects)
end

---------------------------------------------------------
-- UPDATE OBJECTS (scroll left; collision checks)
---------------------------------------------------------
function UpdateObjects(dt)
    if not CurrentLevel then return end
    local speed = CurrentLevel.scrollSpeed or 150

    -- Coins: move, collect, cull
    for i = #CoinObjects, 1, -1 do
        local c = CoinObjects[i]
        c.x = c.x - speed * dt
        if not c.collected and AABBRect(Player.x, Player.y, Player.width, Player.height, c.x, c.y, c.width, c.height) then
            c.collected = true
            TotalCoinsCollected = TotalCoinsCollected + 1
        end
        if c.x + c.width < -TILE then table.remove(CoinObjects, i) end
    end

    -- Spikes: classic full-tile spikes
    for i = #SpikeObjects, 1, -1 do
        local s = SpikeObjects[i]
        s.x = s.x - speed * dt
        if AABBRect(Player.x, Player.y, Player.width, Player.height, s.x, s.y, s.width, s.height) then
            GameState.active = GameState.gameover
            return
        end
        if s.x + s.width < -TILE then table.remove(SpikeObjects, i) end
    end

    -- Mini spikes (half-height)
    for i = #MiniSpikeObjects, 1, -1 do
        local s = MiniSpikeObjects[i]
        s.x = s.x - speed * dt
        if AABBRect(Player.x, Player.y, Player.width, Player.height, s.x, s.y, s.width, s.height) then
            GameState.active = GameState.gameover
            return
        end
        if s.x + s.width < -TILE then table.remove(MiniSpikeObjects, i) end
    end

    -- Big spikes (double height)
    for i = #BigSpikeObjects, 1, -1 do
        local s = BigSpikeObjects[i]
        s.x = s.x - speed * dt
        if AABBRect(Player.x, Player.y, Player.width, Player.height, s.x, s.y, s.width, s.height) then
            GameState.active = GameState.gameover
            return
        end
        if s.x + s.width < -TILE then table.remove(BigSpikeObjects, i) end
    end

    -- Transparent: scroll and cull (no collision)
    for i = #TransparentObjects, 1, -1 do
        local t = TransparentObjects[i]
        t.x = t.x - speed * dt
        if t.x + t.width < -TILE then table.remove(TransparentObjects, i) end
    end

    -- Platforms: scroll and cull (top-only collision handled in Player)
    for i = #PlatformObjects, 1, -1 do
        local p = PlatformObjects[i]
        p.x = p.x - speed * dt
        if p.x + p.width < -TILE then table.remove(PlatformObjects, i) end
    end

    -- Ground & blocks: move and cull
    for i = #GroundObjects, 1, -1 do
        local g = GroundObjects[i]
        g.x = g.x - speed * dt
        if g.x + g.width < -TILE then table.remove(GroundObjects, i) end
    end
    for i = #BlockObjects, 1, -1 do
        local b = BlockObjects[i]
        b.x = b.x - speed * dt
        if b.x + b.width < -TILE then table.remove(BlockObjects, i) end
    end

    -- Finish tiles: move, detect finish, cull
    for i = #FinishObjects, 1, -1 do
        local f = FinishObjects[i]
        f.x = f.x - speed * dt
        if AABBRect(Player.x, Player.y, Player.width, Player.height, f.x, f.y, f.width, f.height) then
            GameState.active = GameState.levelcomplete
            return
        end
        if f.x + f.width < -TILE then table.remove(FinishObjects, i) end
    end
end

---------------------------------------------------------
-- INPUT: mouse / jump handling
---------------------------------------------------------
function love.mousepressed(x, y, button)
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
        if x >= ButtonPause.x and x <= ButtonPause.x + ButtonPause.width and y >= ButtonPause.y and y <= ButtonPause.y + ButtonPause.height then
            GameState.active = GameState.pause
            return
        end

        -- Jump: only while on ground (Geometry Dash style)
        if button == 1 and Player.isOnGround then
            Player.yVelocity = JUMP_VELOCITY
            Player.isOnGround = false
        end

    elseif GameState.active == GameState.levelselect then
        for _, lvl in ipairs(LevelButtons) do
            if x >= lvl.x and x <= lvl.x + lvl.width and y >= lvl.y and y <= lvl.y + lvl.height then
                LoadLevel(lvl.id)
                GameState.active = GameState.play
            end
        end

    elseif GameState.active == GameState.levelcomplete then
        local b1 = LevelCompleteButtons.next
        local b2 = LevelCompleteButtons.menu
        if x >= b1.x and x <= b1.x + b1.width and y >= b1.y and y <= b1.y + b1.height then
            local nextID = CurrentLevelID + 1
            if Levels[nextID] then
                LoadLevel(nextID)
                GameState.active = GameState.play
            else
                GameState.active = GameState.menu
            end
        end
        if x >= b2.x and x <= b2.x + b2.width and y >= b2.y and y <= b2.y + b2.height then
            GameState.active = GameState.menu
        end
    elseif GameState.active == GameState.pause then
        -- click anywhere to resume
        GameState.active = GameState.play
    elseif GameState.active == GameState.gameover then
        -- click returns to menu
        GameState.active = GameState.menu
    end
end

function love.keypressed(key)
    if key == "escape" then love.event.quit() end
    if key == "return" and GameState.active ~= GameState.play then
        GameState.active = GameState.menu
    end
end

---------------------------------------------------------
-- MAIN UPDATE
---------------------------------------------------------
function love.update(dt)
    if GameState.active == GameState.play then
        UpdatePlayer(dt)
        UpdateObjects(dt)
    end
end

---------------------------------------------------------
-- DRAW HELPERS
---------------------------------------------------------
local function DrawButton(btn)
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("line", btn.x, btn.y, btn.width, btn.height)
    love.graphics.printf(btn.text, btn.x, btn.y + 15, btn.width, "center")
    love.graphics.setColor(1,1,1)
end

---------------------------------------------------------
-- DRAW
---------------------------------------------------------
function love.draw()
    love.graphics.setBackgroundColor(0.1,0.1,0.1)
    love.graphics.setFont(Font)

    if GameState.active == GameState.menu then
        love.graphics.setFont(Font1)
        love.graphics.printf("Geo Dash", 0, 150, WindowWidth, "center")
        love.graphics.setFont(Font)
        for _, btn in pairs(Buttons) do DrawButton(btn) end

    elseif GameState.active == GameState.levelselect then
        love.graphics.printf("Select Level", 0, 100, WindowWidth, "center")
        for _, lvl in ipairs(LevelButtons) do DrawButton(lvl) end

    elseif GameState.active == GameState.play then
        -- draw ground / blocks
        for _, g in ipairs(GroundObjects) do
            DrawTileSprite(Sprites.block, g.x, g.y, g.width, g.height, 0.55, 0.35, 0.2)
        end
        for _, b in ipairs(BlockObjects) do
            DrawTileSprite(Sprites.block, b.x, b.y, b.width, b.height, 0.45,0.45,0.45)
        end

        -- draw transparent blocks (no collision)
        for _, t in ipairs(TransparentObjects) do
            DrawTileSprite(Sprites.transparent or Sprites.block, t.x, t.y, t.width, t.height, 0.7,0.7,0.7)
        end

        -- draw platforms (top-only, half height)
        for _, p in ipairs(PlatformObjects) do
            DrawTileSprite(Sprites.platform or Sprites.block, p.x, p.y, p.width, p.height, 0.3,0.6,1)
        end

        -- draw spikes
        for _, s in ipairs(SpikeObjects) do
            DrawTileSprite(Sprites.spike, s.x, s.y, s.width, s.height, 1,0,0)
        end
        for _, s in ipairs(MiniSpikeObjects) do
            DrawTileSprite(Sprites.minispike or Sprites.spike, s.x, s.y, s.width, s.height, 1,0,0)
        end
        for _, s in ipairs(BigSpikeObjects) do
            DrawTileSprite(Sprites.bigspike or Sprites.spike, s.x, s.y, s.width, s.height, 1,0,0)
        end

        -- coins
        for _, c in ipairs(CoinObjects) do
            if not c.collected then
                DrawTileSprite(Sprites.coin, c.x + 6, c.y + 6, c.width - 12, c.height - 12, 1,1,0)
            end
        end

        -- finish
        for _, f in ipairs(FinishObjects) do
            DrawTileSprite(nil, f.x, f.y, f.width, f.height, 0.2,1,0.2)
        end

        -- player
        DrawTileSprite(Sprites.player, Player.x, Player.y, Player.width, Player.height, 1,0,0)

        -- UI
        DrawButton(ButtonPause)
        love.graphics.setColor(0,1,0)
        love.graphics.print("Coins: " .. TotalCoinsCollected, 10, 10)
        love.graphics.print("Level: " .. (CurrentLevelID or "?"), 10, 30)
        love.graphics.setColor(1,1,1)

    elseif GameState.active == GameState.levelcomplete then
        love.graphics.setFont(Font1)
        love.graphics.printf("Level Complete!", 0, 200, WindowWidth, "center")
        love.graphics.setFont(Font)
        DrawButton(LevelCompleteButtons.next)
        DrawButton(LevelCompleteButtons.menu)

    elseif GameState.active == GameState.gameover then
        love.graphics.printf("Game Over - Click to return", 0, WindowHeight/2-20, WindowWidth, "center")
    elseif GameState.active == GameState.pause then
        love.graphics.printf("Paused - Click to resume", 0, WindowHeight/2-20, WindowWidth, "center")
    end
end

---------------------------------------------------------
-- END
---------------------------------------------------------
