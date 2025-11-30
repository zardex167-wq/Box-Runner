-- main.lua
-- Geo Dash (with new block types: Transparent, Platform, Mini Spike, Big Spike)
-- Tile size = 32px
local L = require ("level")
local C = require ("conf")
local sti = require ("Libraries.sti")
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
        Font2 = love.graphics.newFont(21)
        Font  = love.graphics.newFont(14)
    end
    love.graphics.setFont(Font)
    LoadSprites()
    GameState.active = GameState.menu
end
---------------------------------------------------------
-- UPDATE PLAYER (Geometry Dash style) - improved
---------------------------------------------------------
function UpdatePlayer(dt)
    if not CurrentLevel then return end
    -- store previous Y before applying physics!
    local prevY = Player.y
    -- jump
    if love.mouse.isDown(1) and Player.isOnGround then
        Player.yVelocity = JUMP_VELOCITY
    end
    -- rotation only while airborne
    if not Player.isOnGround then
        Player.rotation = Player.rotation + Player.rotationSpeed * dt
    else
        Player.rotation = 0
    end
    -- apply physics
    Player.y = Player.y + Player.yVelocity * dt
    Player.yVelocity = Player.yVelocity + Gravity * dt
    -- death condition
    if Player.y > WindowHeight + 200 then
        GameState.active = GameState.gameover
        return
    end
    Player.isOnGround = false
    --------------------------------------------------------
    -- LANDING COLLISION (Ground + Blocks)
    --------------------------------------------------------
    local function resolveLanding(list)
        for _, obj in ipairs(list) do
            -- Only land if falling
            if Player.yVelocity > 0 then
                local prevBottom = prevY + Player.height
                local currBottom = Player.y + Player.height
                -- crossed top surface
                if prevBottom <= obj.y and currBottom >= obj.y then
                    -- horizontal overlap
                    if Player.x + Player.width > obj.x and Player.x < obj.x + obj.width then
                        Player.y = obj.y - Player.height
                        Player.yVelocity = 0
                        Player.isOnGround = true
                        return true
                    end
                end
            end
        end
        return false
    end
    -- check blocks first, then ground
    if resolveLanding(BlockObjects) then return end
    if resolveLanding(GroundObjects) then return end
    --------------------------------------------------------
    -- PLATFORM TOP-ONLY COLLISION
    --------------------------------------------------------
    for _, p in ipairs(PlatformObjects) do
        if Player.yVelocity > 0 then
            local prevBottom = prevY + Player.height
            local currBottom = Player.y + Player.height

            if prevBottom <= p.y and currBottom >= p.y then
                if Player.x + Player.width > p.x and Player.x < p.x + p.width then
                    Player.y = p.y - Player.height
                    Player.yVelocity = 0
                    Player.isOnGround = true
                    return
                end
            end
        end
    end
    --------------------------------------------------------
    -- HEAD-BUMP COLLISION (Ceiling)
    --------------------------------------------------------
    local function resolveHeadHit(list)
        for _, obj in ipairs(list) do
            if AABBRect(Player.x, Player.y, Player.width, Player.height,
                        obj.x, obj.y, obj.width, obj.height) then

                -- was player below the block last frame?
                if prevY >= (obj.y + obj.height) then
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
    --FlippedMiniSpikeObjects
    for i = #FlippedMiniSpikeObjects, 1, -1 do
        local s = FlippedMiniSpikeObjects[i]
        s.x = s.x - speed * dt
        if AABBRect(Player.x, Player.y, Player.width, Player.height, s.x, s.y, s.width, s.height) then
            GameState.active = GameState.gameover
            return
        end
        if s.x + s.width < -TILE then table.remove(FlippedMiniSpikeObjects, i) end
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
                    LoadLevel(3)
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
    if key == "return" then
        GameState.active = GameState.menu
    end
end
---------------------------------------------------------
-- MAIN UPDATE
---------------------------------------------------------
function love.update(dt)
    local MAX_DT = 1/30
    dt = math.min(dt, MAX_DT)
    if GameState.active == GameState.play then
        UpdatePlayer(dt)
        UpdateObjects(dt)
    end
end
---------------------------------------------------------
-- DRAW HELPERS
---------------------------------------------------------
--Drawblock
local function Drawblock()
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
    for _, s in pairs(FlippedMiniSpikeObjects) do 
        DrawTileSprite(Sprites.flippedminispike or Sprites.spike, s.x, s.y, s.width, s.height, 1,0,0)
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
end
-- Drawbutton
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
        for i, btn in ipairs(LevelButtons) do DrawButton(btn)end
    elseif GameState.active == GameState.play then
        -- Blocks
        Drawblock()
        -- Debug Collision Boxes
        love.graphics.setColor(0, 1, 0) -- green color
        for _, block in ipairs(BlockObjects) do
            love.graphics.rectangle("line", block.x, block.y, block.width, block.height)
        end
        love.graphics.setColor(1, 1, 1) -- reset to white
        -- player
        love.graphics.draw(
        Sprites.player,
        Player.x + Player.width/2,   -- center X
        Player.y + Player.height/2,  -- center Y
        Player.rotation,             -- rotation angle
        Player.width / Sprites.player:getWidth(),    -- scale X
        Player.height / Sprites.player:getHeight(),  -- scale Y
        Sprites.player:getWidth()/2, -- origin X (center)
        Sprites.player:getHeight()/2 -- origin Y (center)
        )
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