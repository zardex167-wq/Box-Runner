-- main.lua (FIXED VERSION)
-- Geo Dash (with new block types: Transparent, Platform, Mini Spike, Big Spike)
-- Tile size = 32px
require ("level")
require ("conf")
require ("helper")
Bg = require ("backgroundstate")
Music = require("music")
---------------------------------------------------------
-- LOVE LOAD
---------------------------------------------------------
function love.load()
    love.window.setTitle("Geo Dash")
    love.window.setMode(WindowWidth, WindowHeight)
        if love.filesystem.getInfo("Fonts/PressStart2P-Regular.ttf") then
            Font1 = love.graphics.newFont("Fonts/PressStart2P-Regular.ttf", 28)
            Font2 = love.graphics.newFont("Fonts/PressStart2P-Regular.ttf", 18)
            Font3 = love.graphics.newFont("Fonts/PressStart2P-Regular.ttf", 72)
    end
    LoadSprites()
    Music.Init()
    -- start music if settings says Y
    if ButtonsSettings.MusicOption and ButtonsSettings.MusicOption.text == "Y" then
        Music.Play()
    end
    GameState.active = GameState.menu
        Bg.Load()
        -- Ensure theme is applied for the default menu level
        if Bg and Bg.SetTheme then Bg.SetTheme("default") end
end
---------------------------------------------------------
-- UPDATE PLAYER (Geometry Dash style) - improved
---------------------------------------------------------
function UpdatePlayer(dt)
    if not CurrentLevel then return end
    -- store previous Y before applying physics!
    local prevY = Player.y
    local prevX = Player.x
    
    -- rotation: continuous while airborne; when landed we may tween to nearest face
    if not Player.isOnGround then
    Player.rotation = Player.rotation + Player.rotationSpeed * dt
    else
        -- Snap to perfect 0 degrees when grounded
        Player.rotation = math.floor(Player.rotation / (math.pi / 2) + 0.5) * (math.pi / 2)
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
                        -- start smooth snap to nearest 90deg face
                        local twopi = math.pi * 2
                        local halfPi = math.pi / 2
                        local function normalize(a)
                            a = a % twopi
                            if a < 0 then a = a + twopi end
                            return a
                        end
                        local startRot = normalize(Player.rotation)
                        local target = math.floor(startRot / halfPi + 0.5) * halfPi
                        Player.landSnapTimer = 0
                        Player.landSnapDuration = 0.12
                        Player.landStartRotation = startRot
                        Player.landTargetRotation = target
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
                    -- start smooth snap to nearest 90deg face (same as ground landing)
                    local twopi = math.pi * 2
                    local halfPi = math.pi / 2
                    local function normalize(a)
                        a = a % twopi
                        if a < 0 then a = a + twopi end
                        return a
                    end
                    local startRot = normalize(Player.rotation)
                    local target = math.floor(startRot / halfPi + 0.5) * halfPi
                    Player.landSnapTimer = 0
                    Player.landSnapDuration = 0.12
                    Player.landStartRotation = startRot
                    Player.landTargetRotation = target
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

    -- Handle landing snap tween (if scheduled)
    if Player.isOnGround and Player.landSnapTimer ~= nil then
        Player.landSnapTimer = Player.landSnapTimer + dt
        local t = Player.landSnapTimer / Player.landSnapDuration
        if t >= 1 then
            -- finished
            Player.rotation = Player.landTargetRotation % (math.pi * 2)
            Player.landSnapTimer = nil
            Player.landSnapDuration = nil
            Player.landStartRotation = nil
            Player.landTargetRotation = nil
        else
            -- ease-out interpolation on shortest angular path
            local twopi = math.pi * 2
            local function shortestDiff(a, b)
                local diff = (b - a) % twopi
                if diff > math.pi then diff = diff - twopi end
                return diff
            end
            local tt = 1 - (1 - t) * (1 - t) -- ease-out quad
            local diff = shortestDiff(Player.landStartRotation, Player.landTargetRotation)
            Player.rotation = Player.landStartRotation + diff * tt
            -- keep normalized
            Player.rotation = Player.rotation % (math.pi * 2)
        end
    end
end
---------------------------------------------------------
-- UPDATE OBJECTS (scroll left; collision checks)
---------------------------------------------------------
function UpdateObjects(dt)
    if not CurrentLevel then return end
    local speed = CurrentLevel.scrollSpeed 
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
    -----------------------------------------------------
    -- MENU CLICKS
    -----------------------------------------------------
    if GameState.active == GameState.menu then
        for name, btn in pairs(Buttons) do
            if PointInButton(btn, x, y) then
                
                -- MAIN MENU BUTTON ACTIONS
                if name == "start" then
                    LoadLevel(1)
                    GameState.active = GameState.play
                    if ButtonsSettings.MusicOption and ButtonsSettings.MusicOption.text == "Y" and Music and Music.Play then Music.Play() end
                elseif name == "levelselect" then
                    GameState.active = GameState.levelselect
                elseif name == "settings" then
                    GameState.active = GameState.settings
                elseif name == "exit" then
                    love.event.quit()
                elseif name == "credits" then
                    GameState.active = GameState.credits
                elseif name == "achievements" then
                    GameState.active = GameState.achievements
                elseif name == "changelog" then
                    GameState.active = GameState.changelog
                elseif name == "shop" then
                    GameState.active = GameState.shop
                end
            end
        end
    elseif GameState.active == GameState.play then
        HandleJumpInput("mouse", button)
        if PointInButton(ButtonPause, x, y) then
            GameState.active = GameState.pause
            if Music and Music.Pause then Music.Pause() end
            return
        end
    elseif GameState.active == GameState.levelselect then
        local bls1 = ButtonsLevelSelect.Exit
        if PointInButton(bls1, x, y) then
            GameState.active = GameState.menu
        end
        for _, lvl in ipairs(LevelButtons) do
            if PointInButton(lvl, x, y) then
                LoadLevel(lvl.id)
                GameState.active = GameState.play
                if ButtonsSettings.MusicOption and ButtonsSettings.MusicOption.text == "Y" and Music and Music.Play then Music.Play() end
            end
        end
    elseif GameState.active == GameState.levelcomplete then
        local blc1 = LevelCompleteButtons.next
        local blc2 = LevelCompleteButtons.menu
        local nextID = CurrentLevelID + 1
        if PointInButton(blc1, x, y) then
            if Levels[nextID] then
                LoadLevel(nextID)
                GameState.active = GameState.play
                if ButtonsSettings.MusicOption and ButtonsSettings.MusicOption.text == "Y" and Music and Music.Play then Music.Play() end
            end
        elseif PointInButton(blc2, x, y) then
            GameState.active = GameState.menu
        end
    elseif GameState.active == GameState.pause then
        local bp1 = ButtonsPause.Resume
        local bp2 = ButtonsPause.Exit
        local bp3 = ButtonsPause.Settings
            if PointInButton(bp1, x, y) then
                GameState.active = GameState.play
                if Music and Music.Resume then Music.Resume() end
            end
            if PointInButton(bp2, x, y) then
                GameState.active = GameState.menu
            end
            if PointInButton(bp3, x, y) then
                GameState.active = GameState.settings
            end
    elseif GameState.active == GameState.gameover then
        local bg1 = ButtonsGameover.Retry
        local bg2 = ButtonsGameover.Exit
        if PointInButton(bg1, x, y) then
            LoadLevel(CurrentLevelID)
            GameState.active = GameState.play
            if ButtonsSettings.MusicOption and ButtonsSettings.MusicOption.text == "Y" and Music and Music.Play then Music.Play() end
        elseif PointInButton(bg2, x, y) then
            GameState.active = GameState.menu
        end
    elseif GameState.active == GameState.settings then
        local bs1 = ButtonsSettings.Exit
        local bs2 = ButtonsSettings.MusicOption
        local bs3 = ButtonsSettings.SpeedOption
        local bs4 = ButtonsSettings.ControlOption
        local bs5 = ButtonsSettings.be1Option
        local bs6 = ButtonsSettings.be2Option
        if PointInButton(bs1, x, y) then
            GameState.active = GameState.menu
        elseif PointInButton(bs2, x, y) then
            -- Cycle Music Options
            if bs2.text == "Y" then
                bs2.text = "N"
                if Music and Music.Stop then Music.Stop() end
            else
                bs2.text = "Y"
                if Music and Music.Play then Music.Play() end
            end
        elseif PointInButton(bs3, x, y) then
            -- Cycle Speed Options (FIXED)
            if bs3.text == "1" then
                bs3.text = "1.5"
                Ss = (32 * 10) 
            elseif bs3.text == "1.5" then
                bs3.text = "2"
                Ss = (32 * 12)
            elseif bs3.text == "2" then
                bs3.text = "2.5"
                Ss = (32 * 14)
            elseif bs3.text == "2.5" then
                bs3.text = "3"
                Ss = (32 * 16)
            else
                bs3.text = "1"
                Ss = (32 * 8) -- Back to original speed
            end
        elseif PointInButton(bs4, x, y) then
            -- Cycle Control Options
            if bs4.text == "Click" then
                bs4.text = "Space"
            elseif bs4.text == "Space" then
                bs4.text = "Arrow"
            else
                bs4.text = "Click"
            end
        elseif PointInButton(bs5, x, y) then
            -- Cycle be1 Options
            if bs5.text == "Null" then
                bs5.text = "Option1"
            elseif bs5.text == "Option1" then
                bs5.text = "Option2"
            else
                bs5.text = "Null"
            end
        elseif PointInButton(bs6, x, y) then
            -- Cycle be2 Options
            if bs6.text == "Null" then
                bs6.text = "Option1"
            elseif bs6.text == "Option1" then
                bs6.text = "Option2"
            else
                bs6.text = "Null"
            end
        end
    elseif GameState.active == GameState.shop then
        local exitBtn = ButtonsShop.Exit
        if PointInButton(exitBtn, x, y) then
            GameState.active = GameState.menu
        end
    elseif GameState.active == GameState.changelog then
        local exitBtn = ButtonsChangelog.Exit
        if PointInButton(exitBtn, x, y) then
            GameState.active = GameState.menu
        end
    elseif GameState.active == GameState.achievements then
        local exitBtn = ButtonsAchievements.Exit
        if PointInButton(exitBtn, x, y) then
            GameState.active = GameState.menu
        end
    elseif GameState.active == GameState.credits then
        local exitBtn = ButtonsCredits.Exit
        if PointInButton(exitBtn, x, y) then
            GameState.active = GameState.menu
        end
    end
end
function love.keypressed(key)
    if key == "escape" then love.event.quit() end
    if key == "return" then
        GameState.active = GameState.menu
    end
    if GameState.active == GameState.play then
        HandleJumpInput("key", key)
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
        -- Update pause button hover/animation when playing
        UpdateButton(ButtonPause, dt)
    end
    Bg.Update(dt)
    love.graphics.setColor(1, 1, 1)
    
    -- Update button hover states for all relevant states
    if GameState.active == GameState.menu then
        for _, btn in pairs(Buttons) do
            UpdateButton(btn, dt)
        end
    elseif GameState.active == GameState.pause then
        for _, btn in pairs(ButtonsPause) do
            UpdateButton(btn, dt)
        end
    elseif GameState.active == GameState.levelcomplete then
        for _, btn in pairs(LevelCompleteButtons) do
            UpdateButton(btn, dt)
        end
    elseif GameState.active == GameState.gameover then
        for _, btn in pairs(ButtonsGameover) do
            UpdateButton(btn, dt)
        end
    elseif GameState.active == GameState.settings then
        for _, btn in pairs(ButtonsSettings) do
            UpdateButton(btn, dt)
        end
    elseif GameState.active == GameState.levelselect then
        for _, lvl in ipairs(LevelButtons) do
            UpdateButton(lvl, dt)
        end
        for _, btn in pairs(ButtonsLevelSelect) do
            UpdateButton(btn, dt)
        end
    elseif GameState.active == GameState.shop then
        for _, btn in pairs(ButtonsShop) do
            UpdateButton(btn, dt)
        end
    elseif GameState.active == GameState.changelog then
        for _, btn in pairs(ButtonsChangelog) do
            UpdateButton(btn, dt)
        end
    elseif GameState.active == GameState.achievements then
        for _, btn in pairs(ButtonsAchievements) do
            UpdateButton(btn, dt)
        end
    elseif GameState.active == GameState.credits then
        for _, btn in pairs(ButtonsCredits) do
            UpdateButton(btn, dt)
        end
    end
end

---------------------------------------------------------
-- DRAW
---------------------------------------------------------
function love.draw()
    if GameState.active == GameState.menu then
        love.graphics.setFont(Font1)
        Bg.Draw()
        for _, btn in pairs(Buttons) do
            DrawButton(btn)
        end
    elseif GameState.active == GameState.levelselect then
        love.graphics.setFont(Font1)
        Bg.Draw()
        for _, lvl in ipairs(LevelButtons) do
            DrawButton(lvl)
        end
        for _, btn in pairs(ButtonsLevelSelect) do
            DrawButton(btn)
        end
    elseif GameState.active == GameState.play then
        -- Blocks
        Drawblock()

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
        Bg.Draw()
        for _, btn in pairs(LevelCompleteButtons) do
            DrawButton(btn)
        end
    elseif GameState.active == GameState.gameover then
        love.graphics.setFont(Font1)
        Bg.Draw()
        for _, btn in pairs(ButtonsGameover) do
            DrawButton(btn)
        end
    elseif GameState.active == GameState.pause then
        love.graphics.setFont(Font1)
        Bg.Draw()
        for _, btn in pairs(ButtonsPause) do
            DrawButton(btn)
        end
    elseif GameState.active == GameState.settings then 
        love.graphics.setFont(Font1)
        Bg.Draw()
        for _, btn in pairs(ButtonsSettings) do
            DrawButton(btn)
        end
    elseif GameState.active == GameState.shop then
        love.graphics.setFont(Font1)
        Bg.Draw()
        for _, btn in pairs(ButtonsShop) do
            DrawButton(btn)
        end
    elseif GameState.active == GameState.changelog then
        love.graphics.setFont(Font1)
        Bg.Draw()
        for _, btn in pairs(ButtonsChangelog) do
            DrawButton(btn)
        end
    elseif GameState.active == GameState.achievements then
        love.graphics.setFont(Font1)
        Bg.Draw()
        for _, btn in pairs(ButtonsAchievements) do
            DrawButton(btn)
        end
    elseif GameState.active == GameState.credits then
        love.graphics.setFont(Font1)
        Bg.Draw()
        for _, btn in pairs(ButtonsCredits) do
            DrawButton(btn)
        end
    end
end
---------------------------------------------------------
-- END
---------------------------------------------------------