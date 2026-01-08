-- main.lua - Geometry Dash Enhanced
require("level")
require("conf")
require("helper")
Bg = require("backgroundstate")
Music = require("music")
PopWindow = require("popwindow")

----------------------------------------------------------------
-- GLOBAL VARIABLES
----------------------------------------------------------------
Scale = 1
OffsetX = 0
OffsetY = 0
BaseWidth = WINDOW_WIDTH
BaseHeight = WINDOW_HEIGHT
UpdateScalingFunc = nil

----------------------------------------------------------------
-- SAVE SYSTEM ENHANCEMENTS
----------------------------------------------------------------
function SaveGame()
    local saveString = string.format("%d;%d;", SaveData.coins or 0, SaveData.diamonds or 0)
    
    -- Encode owned skins
    local ownedSkins = {}
    if SaveData.ownedSkins then
        for skinId, owned in pairs(SaveData.ownedSkins) do
            if owned then
                table.insert(ownedSkins, tostring(skinId))
            end
        end
    end
    saveString = saveString .. table.concat(ownedSkins, ",") .. ";"
    
    -- Add equipped skin, last claim, and streak
    saveString = saveString .. string.format("%d;%s;%d;%d;%d;", 
        SaveData.equippedSkin or 1,
        SaveData.lastClaim or "",
        SaveData.achievements or 0,
        SaveData.streakCount or 0,
        SaveData.levelsCompleted or 0)
    
    -- Add unlocked levels
    local unlockedLevels = {}
    if SaveData.unlockedLevels then
        for levelId, unlocked in pairs(SaveData.unlockedLevels) do
            if unlocked then
                table.insert(unlockedLevels, tostring(levelId))
            end
        end
    end
    saveString = saveString .. table.concat(unlockedLevels, ",") .. ";"
    
    -- Add settings
    saveString = saveString .. string.format("%s;%s;%s;%s;%s;%s",
        SaveData.settings.musicEnabled and "1" or "0",
        tostring(SaveData.settings.scrollSpeed or 1),
        SaveData.settings.controls or "Click",
        SaveData.settings.theme or "White",
        SaveData.settings.particles and "1" or "0",
        SaveData.settings.showStats and "1" or "0")
    
    pcall(function() 
        love.filesystem.write("save.dat", saveString) 
        ShowSaveIndicator()
    end)
end

function LoadGame()
    if not love.filesystem.getInfo("save.dat") then return end
    
    local success, content = pcall(function() 
        return love.filesystem.read("save.dat") 
    end)
    
    if not success or not content then return end
    
    -- Parse save data
    local parts = {}
    for part in string.gmatch(content, "([^;]+)") do
        table.insert(parts, part)
    end
    
    if #parts >= 6 then
        SaveData.coins = tonumber(parts[1]) or 0
        SaveData.diamonds = tonumber(parts[2]) or 0
        
        -- Parse owned skins
        SaveData.ownedSkins = {}
        local skinIds = parts[3]
        if skinIds and skinIds ~= "" then
            for skinId in string.gmatch(skinIds, "([^,]+)") do
                SaveData.ownedSkins[tonumber(skinId)] = true
            end
        end
        
        SaveData.equippedSkin = tonumber(parts[4]) or 1
        SaveData.lastClaim = parts[5] or ""
        SaveData.achievements = tonumber(parts[6]) or 0
        SaveData.streakCount = tonumber(parts[7]) or 0
        SaveData.levelsCompleted = tonumber(parts[8]) or 0
        
        -- Parse unlocked levels
        if #parts >= 9 then
            SaveData.unlockedLevels = {}
            local levelIds = parts[9]
            if levelIds and levelIds ~= "" then
                for levelId in string.gmatch(levelIds, "([^,]+)") do
                    SaveData.unlockedLevels[tonumber(levelId)] = true
                end
            end
        end
        
        -- Parse settings
        if #parts >= 17 then
            SaveData.settings = SaveData.settings or {}
            SaveData.settings.musicEnabled = parts[10] == "1"
            SaveData.settings.scrollSpeed = tonumber(parts[12]) or 1
            SaveData.settings.controls = parts[13] or "Click"
            SaveData.settings.theme = parts[14] or "White"
            SaveData.settings.particles = parts[16] == "1"
            SaveData.settings.showStats = parts[17] == "1"
            
            -- Apply settings
            if ButtonsSettings then
                ButtonsSettings.MusicOption.text = SaveData.settings.musicEnabled and "Y" or "N"
                ButtonsSettings.SpeedOption.text = tostring(SaveData.settings.scrollSpeed)
                ButtonsSettings.ControlOption.text = SaveData.settings.controls
                ButtonsSettings.ThemeOption.text = SaveData.settings.theme
            end
        end
    end
end

----------------------------------------------------------------
-- GAME INITIALIZATION
----------------------------------------------------------------
function love.load()
    love.window.setTitle(GAME_TITLE)
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    
    -- Load fonts
    if love.filesystem.getInfo("Fonts/PressStart2P-Regular.ttf") then
        Font1 = love.graphics.newFont("Fonts/PressStart2P-Regular.ttf", 28)
        Font2 = love.graphics.newFont("Fonts/PressStart2P-Regular.ttf", 18)
        Font3 = love.graphics.newFont("Fonts/PressStart2P-Regular.ttf", 72)
        Font4 = love.graphics.newFont("Fonts/PressStart2P-Regular.ttf", 10)
    else
        -- Fallback to default fonts
        Font1 = love.graphics.newFont(28)
        Font2 = love.graphics.newFont(18)
        Font3 = love.graphics.newFont(72)
        Font4 = love.graphics.newFont(10)
    end
    
    -- Load game assets
    LoadSprites()
    Music.Init()
    
    -- Initialize helper systems
    if InitializeHelper then InitializeHelper() end
    
    -- Load saved data
    LoadGame()
    
    -- Apply theme to buttons
    ApplyThemeToAllButtons()
    
    -- Initialize background
    Bg.Load()
    Bg.SetTheme("default")

    -- Setup scaling
    function UpdateScaling()
        local screenWidth, screenHeight = love.graphics.getDimensions()
        local scaleX = screenWidth / BaseWidth
        local scaleY = screenHeight / BaseHeight
        Scale = math.min(scaleX, scaleY)
        OffsetX = (screenWidth - BaseWidth * Scale) / 2
        OffsetY = (screenHeight - BaseHeight * Scale) / 2
    end
    
    UpdateScaling()
    UpdateScalingFunc = UpdateScaling
    
    -- Start music if enabled
    PlayMusic()  
    -- Check for daily reward on startup
    if PopWindow and PopWindow.CheckDailyReward then
        PopWindow.CheckDailyReward()
    end
end

----------------------------------------------------------------
-- ENHANCED PLAYER PHYSICS AND COLLISION
----------------------------------------------------------------
function UpdatePlayer(deltaTime)
    if not CurrentLevel then return end
    
    local previousY = Player.y
    
    -- Rotation logic
    if not Player.isOnGround then
        Player.rotation = Player.rotation + Player.rotationSpeed * deltaTime
    else
        -- Snap to nearest 90 degrees when grounded
        Player.rotation = math.floor(Player.rotation / (math.pi / 2) + 0.5) * (math.pi / 2)
    end
    
    -- Apply gravity
    Player.y = Player.y + Player.yVelocity * deltaTime
    Player.yVelocity = Player.yVelocity + GRAVITY * deltaTime
    
    -- Death condition with visual effects
    if Player.y > WINDOW_HEIGHT + 200 then
        GameState.ACTIVE = GameState.GAMEOVER
        PlayerStats.deaths = (PlayerStats.deaths or 0) + 1
        SaveData.deaths = (SaveData.deaths or 0) + 1

        PlaySound("death")
        CreateDeathParticles(Player.x + Player.width/2, Player.y + Player.height/2)
        
        -- Check death achievements
        AchievementsCounter()
        
        return
    end
    
    Player.isOnGround = false
    
    -- Ground and block collision
    local function CheckLandingCollision(objects)
        for _, object in ipairs(objects) do
            if Player.yVelocity > 0 then
                local previousBottom = previousY + Player.height
                local currentBottom = Player.y + Player.height
                
                if previousBottom <= object.y and currentBottom >= object.y then
                    if Player.x + Player.width > object.x and Player.x < object.x + object.width then
                        Player.y = object.y - Player.height
                        Player.yVelocity = 0
                        Player.isOnGround = true
                        
                        -- Create landing particles
                        if previousBottom <= object.y - 10 then -- Only if falling from height
                            CreateJumpParticles()
                        end
                        
                        -- Start rotation snap animation
                        local twoPi = math.pi * 2
                        local halfPi = math.pi / 2
                        
                        local function normalizeAngle(angle)
                            angle = angle % twoPi
                            if angle < 0 then angle = angle + twoPi end
                            return angle
                        end
                        
                        local startRotation = normalizeAngle(Player.rotation)
                        local targetRotation = math.floor(startRotation / halfPi + 0.5) * halfPi
                        
                        Player.landSnapTimer = 0
                        Player.landSnapDuration = 0.12
                        Player.landStartRotation = startRotation
                        Player.landTargetRotation = targetRotation
                        
                        return true
                    end
                end
            end
        end
        return false
    end
    
    -- Check collisions in order
    if CheckLandingCollision(BlockObjects) then return end
    if CheckLandingCollision(GroundObjects) then return end
    
    -- Platform collision (top only)
    for _, platform in ipairs(PlatformObjects) do
        if Player.yVelocity > 0 then
            local previousBottom = previousY + Player.height
            local currentBottom = Player.y + Player.height
            
            if previousBottom <= platform.y and currentBottom >= platform.y then
                if Player.x + Player.width > platform.x and Player.x < platform.x + platform.width then
                    Player.y = platform.y - Player.height
                    Player.yVelocity = 0
                    Player.isOnGround = true
                    
                    -- Create landing particles
                    if previousBottom <= platform.y - 10 then
                        CreateJumpParticles()
                    end
                    
                    -- Rotation snap for platforms too
                    local twoPi = math.pi * 2
                    local halfPi = math.pi / 2
                    
                    local function normalizeAngle(angle)
                        angle = angle % twoPi
                        if angle < 0 then angle = angle + twoPi end
                        return angle
                    end
                    
                    local startRotation = normalizeAngle(Player.rotation)
                    local targetRotation = math.floor(startRotation / halfPi + 0.5) * halfPi
                    
                    Player.landSnapTimer = 0
                    Player.landSnapDuration = 0.12
                    Player.landStartRotation = startRotation
                    Player.landTargetRotation = targetRotation
                    
                    return
                end
            end
        end
    end
    
    -- Head collision (ceiling)
    local function CheckHeadCollision(objects)
        for _, object in ipairs(objects) do
            if AABBRect(Player.x, Player.y, Player.width, Player.height,
                       object.x, object.y, object.width, object.height) then
                
                if previousY >= (object.y + object.height) then
                    Player.y = object.y + object.height
                    Player.yVelocity = 0
                    return true
                end
            end
        end
        return false
    end
    
    CheckHeadCollision(BlockObjects)
    CheckHeadCollision(GroundObjects)
    
    -- Handle landing rotation snap
    if Player.isOnGround and Player.landSnapTimer then
        Player.landSnapTimer = Player.landSnapTimer + deltaTime
        local progress = Player.landSnapTimer / Player.landSnapDuration
        
        if progress >= 1 then
            Player.rotation = Player.landTargetRotation % (math.pi * 2)
            Player.landSnapTimer = nil
            Player.landSnapDuration = nil
            Player.landStartRotation = nil
            Player.landTargetRotation = nil
        else
            -- Ease-out interpolation
            local twoPi = math.pi * 2
            
            local function shortestAngleDifference(start, target)
                local difference = (target - start) % twoPi
                if difference > math.pi then difference = difference - twoPi end
                return difference
            end
            
            local easedProgress = 1 - (1 - progress) * (1 - progress)  -- Ease-out quad
            local angleDifference = shortestAngleDifference(Player.landStartRotation, Player.landTargetRotation)
            Player.rotation = Player.landStartRotation + angleDifference * easedProgress
            Player.rotation = Player.rotation % (math.pi * 2)
        end
    end
end

----------------------------------------------------------------
-- ENHANCED GAME OBJECT UPDATES WITH VISUAL EFFECTS
----------------------------------------------------------------
function UpdateObjects(deltaTime)
    if not CurrentLevel then return end
    
    local scrollSpeed = CurrentLevel.scrollSpeed or BASE_SCROLL_SPEED
    
    -- Update coins
    for i = #CoinObjects, 1, -1 do
        local coin = CoinObjects[i]
        coin.x = coin.x - scrollSpeed * deltaTime
        
        if not coin.collected and 
           AABBRect(Player.x, Player.y, Player.width, Player.height,
                   coin.x, coin.y, coin.width, coin.height) then
            coin.collected = true
            TotalCoinsCollected = TotalCoinsCollected + 1
            
            -- Visual and sound effects
            PlaySound("coin")
            CreateCoinParticles(coin.x + coin.width/2, coin.y + coin.height/2)
            
            -- Update player stats
            SaveData.coins = (SaveData.coins or 0) + 1
            PlayerStats.coins = (PlayerStats.coins or 0) + 1
            
            -- Check coin achievements
            AchievementsCounter()
            
            -- Save progress
            SaveGame()
        end
        
        if coin.x + coin.width < -TILE_SIZE then
            table.remove(CoinObjects, i)
        end
    end
    
    -- Update spikes (all types) with death effects
    local function UpdateSpikeList(spikeList)
        for i = #spikeList, 1, -1 do
            local spike = spikeList[i]
            spike.x = spike.x - scrollSpeed * deltaTime
            
            if AABBRect(Player.x, Player.y, Player.width, Player.height,
                       spike.x, spike.y, spike.width, spike.height) then
                GameState.ACTIVE = GameState.GAMEOVER
                PlayerStats.deaths = (PlayerStats.deaths or 0) + 1
                SaveData.deaths = (SaveData.deaths or 0) + 1
                
                PlaySound("death")
                CreateDeathParticles(Player.x + Player.width/2, Player.y + Player.height/2)
                
                -- Check death achievements
                AchievementsCounter()
                return
            end
            
            if spike.x + spike.width < -TILE_SIZE then
                table.remove(spikeList, i)
            end
        end
    end
    
    UpdateSpikeList(SpikeObjects)
    UpdateSpikeList(MiniSpikeObjects)
    UpdateSpikeList(BigSpikeObjects)
    UpdateSpikeList(FlippedMiniSpikeObjects)
    
    -- Update other objects
    local function UpdateObjectList(objectList)
        for i = #objectList, 1, -1 do
            local object = objectList[i]
            object.x = object.x - scrollSpeed * deltaTime
            
            if object.x + object.width < -TILE_SIZE then
                table.remove(objectList, i)
            end
        end
    end
    
    UpdateObjectList(TransparentObjects)
    UpdateObjectList(PlatformObjects)
    UpdateObjectList(GroundObjects)
    UpdateObjectList(BlockObjects)
    
    -- Update finish line with celebration
    for i = #FinishObjects, 1, -1 do
        local finish = FinishObjects[i]
        finish.x = finish.x - scrollSpeed * deltaTime
        
        if AABBRect(Player.x, Player.y, Player.width, Player.height,
                   finish.x, finish.y, finish.width, finish.height) then
            GameState.ACTIVE = GameState.LEVELCOMPLETE
            
            -- Celebration effects
            PlaySound("complete")
            CreateLevelCompleteParticles()
            
            CompleteLevel(CurrentLevelID)
            return
        end
        
        if finish.x + finish.width < -TILE_SIZE then
            table.remove(FinishObjects, i)
        end
    end
end

----------------------------------------------------------------
-- ENHANCED INPUT HANDLING  SUPPORT
----------------------------------------------------------------
function love.mousepressed(x, y, button, istouch, presses)
    -- Convert screen to world coordinates
    local worldX, worldY = ScreenToWorld(x, y)
    
    -- Play click sound
    if button == 1 then
        PlaySound("click")
    end
    
    -- Let PopWindow handle clicks first (if open)
    if PopWindow and PopWindow.IsOpen and PopWindow.IsOpen() then
        if PopWindow.MousePressed and PopWindow.MousePressed(worldX, worldY, button) then
            return
        end
    end
    
    -- Handle clicks based on game state
    local handled = false
    
    if GameState.ACTIVE == GameState.MENU then
        handled = HandleMenuClicks(worldX, worldY)
        
    elseif GameState.ACTIVE == GameState.PLAY then
        handled = HandleGameplayClicks(worldX, worldY, button)
        
    elseif GameState.ACTIVE == GameState.LEVELSELECT then
        handled = HandleLevelSelectClicks(worldX, worldY)
        
    elseif GameState.ACTIVE == GameState.LEVELCOMPLETE then
        handled = HandleLevelCompleteClicks(worldX, worldY)
        
    elseif GameState.ACTIVE == GameState.PAUSE then
        handled = HandlePauseMenuClicks(worldX, worldY)
        
    elseif GameState.ACTIVE == GameState.GAMEOVER then
        handled = HandleGameOverClicks(worldX, worldY)
        
    elseif GameState.ACTIVE == GameState.SETTINGS then
        handled = HandleSettingsClicks(worldX, worldY)
        
    elseif GameState.ACTIVE == GameState.SHOP then
        handled = HandleShopClicks(worldX, worldY)
        
    elseif GameState.ACTIVE == GameState.ACHIEVEMENTS then
        handled = HandleAchievementsClicks(worldX, worldY)
        
    elseif GameState.ACTIVE == GameState.DAILY_REWARD then
        handled = HandleDailyRewardClicks(worldX, worldY)
    end
    
    -- If click wasn't handled, play a sound effect
    if not handled and button == 1 then
        PlaySound("hover")
    end
end

function love.keypressed(key)
    -- Close PopWindow with Escape
    if key == "escape" then
        if PopWindow and PopWindow.IsOpen and PopWindow.IsOpen() then
            PopWindow.Close()
            return
        else
            -- Toggle pause menu if in gameplay
            if GameState.ACTIVE == GameState.PLAY then
                GameState.ACTIVE = GameState.PAUSE
            elseif GameState.ACTIVE == GameState.PAUSE then
                GameState.ACTIVE = GameState.PLAY
            else
                love.event.quit()
            end
        end
    end

    -- Global debug keys
    if key == "f12" then
        PopWindow.ShowConfirm("Delete Save", "This will permanently delete your save file (save.dat). Are you sure?", function()
            DeleteSaveFile()
        end)
        return
    end
    
    -- Let PopWindow handle text input
    if PopWindow and PopWindow.IsOpen and PopWindow.IsOpen() and 
       PopWindow.KeyPressed and PopWindow.KeyPressed(key) then
        return
    end
    
    -- Gameplay controls
    if GameState.ACTIVE == GameState.PLAY then
        HandleJumpInput("key", key)
    elseif key == "return" then
        if GameState.ACTIVE == GameState.LEVELCOMPLETE then
            GameState.ACTIVE = GameState.MENU
        end
    end
end

function love.textinput(text)
    if PopWindow and PopWindow.IsOpen and PopWindow.IsOpen() and 
       PopWindow.TextInput and PopWindow.TextInput(text) then
        return
    end
end

function love.resize(width, height)
    WINDOW_WIDTH = width
    WINDOW_HEIGHT = height
    
    if UpdateScalingFunc then
        UpdateScalingFunc()
    end
    
    -- Update button positions
    if ButtonPause then
        ButtonPause.x = BaseWidth - 110
    end
    
    -- Update currency display positions
    if ButtonsCurrency then
        ButtonsCurrency.Coin.x = BaseWidth - 120
        ButtonsCurrency.Coin.y = 10
        ButtonsCurrency.Diamond.x = BaseWidth - 220
        ButtonsCurrency.Diamond.y = 10
    end
    
    if ButtonsInventory then
        ButtonsInventory.Inventory.x = BaseWidth - 320
        ButtonsInventory.Inventory.y = 10
    end
end

----------------------------------------------------------------
-- ENHANCED GAME UPDATE LOOP WITH ALL SYSTEMS
----------------------------------------------------------------
function love.update(deltaTime)
    -- Update all helper systems
    if UpdateAllSystems then
        UpdateAllSystems(deltaTime)
    end
    
    -- Update based on game state
    if GameState.ACTIVE == GameState.PLAY then
        UpdatePlayer(deltaTime)
        UpdateObjects(deltaTime)
        
        UpdateButton(ButtonPause, deltaTime)
        
    end
    
    -- Update background
    Bg.Update(deltaTime)
    
    -- Update PopWindow
    if PopWindow then
        PopWindow.Update(deltaTime)
    end
    
    -- Update UI buttons based on game state
    UpdateUIButtons(deltaTime)

    if SaveData.coins >= 9999 then 
        SaveData.coins = 9999
    end

    if SaveData.diamonds >= 9999 then 
        SaveData.diamonds = 9999
    end
end

----------------------------------------------------------------
-- ENHANCED GAME RENDERING WITH VISUAL EFFECTS
----------------------------------------------------------------
function love.draw()
    -- Apply scaling transformation
    love.graphics.push()
    love.graphics.translate(OffsetX, OffsetY)
    love.graphics.scale(Scale, Scale)
    
    -- Draw based on game state
    if GameState.ACTIVE == GameState.MENU then
        DrawMenu()
        
    elseif GameState.ACTIVE == GameState.LEVELSELECT then
        DrawLevelSelect()
    elseif GameState.ACTIVE == GameState.PLAY then
        DrawGameplay()
    elseif GameState.ACTIVE == GameState.LEVELCOMPLETE then
        DrawLevelComplete()
    elseif GameState.ACTIVE == GameState.GAMEOVER then
        DrawGameOver()
    elseif GameState.ACTIVE == GameState.PAUSE then
        DrawPauseMenu()
    elseif GameState.ACTIVE == GameState.SETTINGS then
        DrawSettings()
    elseif GameState.ACTIVE == GameState.SHOP then
        DrawShop()
    elseif GameState.ACTIVE == GameState.ACHIEVEMENTS then
        DrawAchievements()
    elseif GameState.ACTIVE == GameState.CREDITS then
        DrawCredits()
    elseif GameState.ACTIVE == GameState.DAILY_REWARD then
        DrawDailyReward()
    end
    
    -- Draw PopWindow on top
    if PopWindow and PopWindow.IsOpen and PopWindow.IsOpen() then
        PopWindow.Draw()
    end
    
    -- Draw visual effects (particles, etc.)
    if DrawAllVisualEffects then
        DrawAllVisualEffects()
    end
    
    love.graphics.pop()

end

----------------------------------------------------------------
-- ENHANCED DRAWING FUNCTIONS
----------------------------------------------------------------
function DrawMenu()
    love.graphics.setFont(Font1)
    Bg.Draw()
    
    -- Draw main menu buttons
    for _, button in pairs(Buttons) do
        DrawButton(button)
    end
    
    -- Draw currency display
    DrawCurrencyDisplay()
    
    -- Draw daily reward indicator
    DrawDailyRewardIndicator()
    
    love.graphics.setColor(1, 1, 1)
end

function DrawCurrencyDisplay()
    love.graphics.setFont(Font2)
    
    -- Draw inventory/skin button
    if ButtonsInventory.Inventory then
        DrawButton(ButtonsInventory.Inventory)
        
        -- Draw equipped skin swatch
        local equippedSkinId = SaveData.equippedSkin or 1
        if Skins and Skins[equippedSkinId] then
            local swatchSize = 24
            local swatchX = ButtonsInventory.Inventory.x + ButtonsInventory.Inventory.width - swatchSize - 8
            local swatchY = ButtonsInventory.Inventory.y + 3
            DrawSwatch(swatchX, swatchY, swatchSize, swatchSize, Skins[equippedSkinId].color)
        end
    end
    
    -- Draw diamonds button
    if ButtonsCurrency and ButtonsCurrency.Diamond then
        local button = ButtonsCurrency.Diamond
        button.text = "D " .. FormatNumber(SaveData.diamonds or 0)
        DrawButton(button)
    end
    
    -- Draw coins button
    if ButtonsCurrency and ButtonsCurrency.Coin then
        local button = ButtonsCurrency.Coin
        button.text = "C " .. FormatNumber(SaveData.coins or 0)
        DrawButton(button)
    end
    
    love.graphics.setColor(1, 1, 1)
end

function DrawDailyRewardIndicator()
    local today = os.date("%Y-%m-%d")
    local lastClaim = SaveData.lastClaim or ""
    local streak = SaveData.streakCount or 0
    
    if lastClaim == today then
        -- Already claimed today
        love.graphics.setColor(0.5, 0.5, 0.5, 0.8)
        love.graphics.circle("fill", 780, 570, 8)
        love.graphics.setColor(0, 1, 0)
        love.graphics.print("/", 775, 560)
    else
        -- Can claim
        love.graphics.setColor(1, 0.8, 0, 0.8)
        love.graphics.circle("fill", 780, 570, 8)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("!", 777, 560)
        
        -- Show streak count
        love.graphics.setFont(Font4)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Day " .. streak, 765, 580)
    end
    
    love.graphics.setColor(1, 1, 1)
end

function DrawGameplay()
    -- Draw level with theme colors
    DrawLevelObjects()
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
    
    -- Draw player with skin color
    local equippedSkin = SaveData.equippedSkin or 1
    local skin = Skins[equippedSkin]
    if skin and skin.color then
        love.graphics.setColor(skin.color)
    else
        love.graphics.setColor(1, 1, 1)
    end
    
    -- Draw player sprite with rotation
    if Sprites.player then
        love.graphics.draw(
            Sprites.player,
            Player.x + Player.width/2,
            Player.y + Player.height/2,
            Player.rotation,
            Player.width / Sprites.player:getWidth(),
            Player.height / Sprites.player:getHeight(),
            Sprites.player:getWidth()/2,
            Sprites.player:getHeight()/2
        )
    else
        -- Fallback rectangle if sprite not loaded
        love.graphics.rectangle("fill", Player.x, Player.y, Player.width, Player.height)
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
    
    -- Draw HUD (Heads-Up Display)
    DrawGameHUD()
    
    -- Draw pause button
    DrawButton(ButtonPause)
    
end

function DrawGameHUD()
    -- Coins
    love.graphics.setColor(1, 1, 0)
    love.graphics.print("Coins: " .. TotalCoinsCollected, 15, 35)
    
    -- Level name
    if CurrentLevel and CurrentLevel.name then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(CurrentLevel.name, 15, 10)
    end
    
    love.graphics.setColor(1, 1, 1)
end

function DrawLevelSelect()
    love.graphics.setFont(Font1)
    Bg.Draw()
    
    -- Draw level progress
    local completed = PlayerStats.levelsCompleted or 0
    local total = #LevelNames
    love.graphics.printf("Completed: " .. completed .. "/" .. total .. 
                        " (" .. math.floor((completed/total) * 100) .. "%)", 
                        0, 60, WINDOW_WIDTH, "center")
    
    -- Draw level buttons
    for _, levelButton in ipairs(LevelButtons) do
        -- Check if level is unlocked
        local isUnlocked = IsLevelUnlocked(levelButton.id)
        
        if isUnlocked then
            -- Draw unlocked level button
            DrawButton(levelButton)
            
            -- Add star rating for completed levels
            if SaveData.unlockedLevels and SaveData.unlockedLevels[levelButton.id] then
                -- Level is completed (unlocked next level means this one is completed)
                local nextLevelUnlocked = SaveData.unlockedLevels[levelButton.id + 1]
                if nextLevelUnlocked or levelButton.id == total then
                    -- Draw stars
                    love.graphics.setColor(1, 1, 0)
                    for star = 1, 3 do
                        local starX = levelButton.x + levelButton.width - 25 - (star * 20)
                        local starY = levelButton.y + 10
                        love.graphics.circle("fill", starX, starY, 8)
                        love.graphics.setColor(0, 0, 0)
                        love.graphics.print("Star", starX - 5, starY - 8)
                        love.graphics.setColor(1, 1, 0)
                    end
                end
            end
        else
            -- Draw locked level button
            love.graphics.setColor(0.3, 0.3, 0.3, 0.7)
            love.graphics.rectangle("fill", levelButton.x, levelButton.y, 
                                   levelButton.width, levelButton.height, 10, 10)
            
            love.graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.setLineWidth(3)
            love.graphics.rectangle("line", levelButton.x, levelButton.y, 
                                   levelButton.width, levelButton.height, 10, 10)
            
            love.graphics.setColor(0.7, 0.7, 0.7)
            love.graphics.printf("Level " .. levelButton.id, 
                               levelButton.x, levelButton.y + 20, 
                               levelButton.width, "center")
            
            love.graphics.printf("Locked", 
                               levelButton.x, levelButton.y + 40, 
                               levelButton.width, "center")
        end
        
        love.graphics.setColor(1, 1, 1)
    end
    
    -- Draw exit button
    for _, button in pairs(ButtonsLevelSelect) do
        DrawButton(button)
    end
    
    love.graphics.setColor(1, 1, 1)
end

function DrawLevelComplete()
    love.graphics.setFont(Font1)
    Bg.Draw()
    
    -- Draw level complete buttons
    for _, button in pairs(LevelCompleteButtons) do
        DrawButton(button)
    end
   
    if CurrentLevel and CurrentLevel.name then
        love.graphics.printf(CurrentLevel.name, 0, WINDOW_HEIGHT/2 - 90, WINDOW_WIDTH, "center")
    end
    
    -- Calculate and show rewards
    local coinReward, diamondReward = GetLevelReward(CurrentLevelID)
    if coinReward > 0 or diamondReward > 0 then
        love.graphics.setColor(0.2, 1, 0.2)
        love.graphics.printf("Rewards:", 0, WINDOW_HEIGHT/2, WINDOW_WIDTH, "center")
        
        if coinReward > 0 then
            love.graphics.setColor(1, 0.8, 0)
            love.graphics.printf("+" .. coinReward .. " coins", 
                                0, WINDOW_HEIGHT/2 + 20, WINDOW_WIDTH, "center")
        end
        
        if diamondReward > 0 then
            love.graphics.setColor(0.2, 0.6, 1)
            love.graphics.printf("+" .. diamondReward .. " diamonds", 
                                0, WINDOW_HEIGHT/2 + 40, WINDOW_WIDTH, "center")
        end
    end
    
    -- Draw next level availability
    local nextLevelExists = Levels[CurrentLevelID + 1] ~= nil
    if nextLevelExists then
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.printf("Next level unlocked!", 
                            0, WINDOW_HEIGHT/2 + 70, WINDOW_WIDTH, "center")
    else
        love.graphics.setColor(1, 0.5, 0)
        love.graphics.printf("All levels completed! Congratulations!", 
                            0, WINDOW_HEIGHT/2 + 70, WINDOW_WIDTH, "center")
    end
    
    love.graphics.setColor(1, 1, 1)
end

function DrawGameOver()
    love.graphics.setFont(Font1)
    Bg.Draw()
    
    -- Draw game over buttons
    for _, button in pairs(ButtonsGameover) do
        DrawButton(button)
    end

    love.graphics.setColor(1, 1, 1)
end

function DrawPauseMenu()
    love.graphics.setFont(Font1)
    Bg.Draw()

    -- Draw pause menu buttons
    for _, button in pairs(ButtonsPause) do
        DrawButton(button)
    end

    love.graphics.setColor(1, 1, 1)
end

function DrawSettings()
    love.graphics.setFont(Font1)
    Bg.Draw()
    
    -- Draw title
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("SETTINGS", 0, 30, WINDOW_WIDTH, "center")
    
    -- Draw all settings buttons
    for _, button in pairs(ButtonsSettings) do
        DrawButton(button)
    end
    
    love.graphics.setColor(1, 1, 1)
end

function DrawShop()
    love.graphics.setFont(Font1)
    Bg.Draw()
    
    -- Draw title
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("SHOP", 0, 30, WINDOW_WIDTH, "center")
    
    -- Draw claim daily button
    if ButtonsShop.Claim then
        DrawButton(ButtonsShop.Claim)
    end
    
    -- Draw convert currency button
    if ButtonsShop.Convert then
        DrawButton(ButtonsShop.Convert)
    end
    
    -- Draw skin buttons
    for i = 1, #Skins do
        local btnKey = 'skin' .. i
        local button = ButtonsShop[btnKey]
        if button then
            DrawButton(button)
            
            -- Draw skin color swatch
            local skin = Skins[i]
            local swatchSize = 20
            local swatchX = button.x + button.width - swatchSize - 10
            local swatchY = button.y + (button.height - swatchSize) / 2
            
            DrawSwatch(swatchX, swatchY, swatchSize, swatchSize, skin.color)
            
            -- Show owned status
            if SaveData.ownedSkins and SaveData.ownedSkins[skin.id] then
                love.graphics.setColor(0, 1, 0)
                love.graphics.setFont(Font4)
                love.graphics.print("OWNED", button.x + 10, button.y + button.height - 12)
            end
        end
    end
    
    -- Draw exit button
    if ButtonsShop.Exit then
        DrawButton(ButtonsShop.Exit)
    end
    
    love.graphics.setColor(1, 1, 1)
end

function DrawAchievements()
    love.graphics.setFont(Font1)
    Bg.Draw()

    -- Draw progress
    local unlocked = 0
    for _, achievement in ipairs(Achievements) do
        if achievement.achieved then
            unlocked = unlocked + 1
        end
    end
    local progress = unlocked / #Achievements
    
    love.graphics.printf("Progress: " .. unlocked .. "/" .. #Achievements .. 
                        " (" .. math.floor(progress * 100) .. "%)", 
                        0, 50, WINDOW_WIDTH, "center")
    
    -- Draw progress bar
    DrawProgressBar(WINDOW_WIDTH/2 - 150, 80, 300, 20, progress, {
        backgroundColor = {0.2, 0.2, 0.2, 1},
        fillColor = {0.2, 0.8, 0.2, 1},
        borderColor = {0.4, 0.4, 0.4, 1}
    })
    
    -- Draw achievement list
    local achievementsPerColumn = 10
    local leftX = 20
    local rightX = WINDOW_WIDTH/2 + 10
    local startY = 120
    local achievementHeight = 30
    
    for i, achievement in ipairs(Achievements) do
        local column = math.ceil(i / achievementsPerColumn)
        local row = ((i - 1) % achievementsPerColumn) + 1
        
        local x = (column == 1) and leftX or rightX
        local y = startY + (row - 1) * (achievementHeight + 5)
        
        -- Draw achievement box
        if achievement.achieved then
            love.graphics.setColor(0.2, 0.7, 0.2, 0.8)  -- Green for unlocked
        else
            love.graphics.setColor(0.3, 0.3, 0.3, 0.8)  -- Gray for locked
        end
        
        love.graphics.rectangle("fill", x, y, 350, achievementHeight, 5)
        
        -- Draw border
        if achievement.achieved then
            love.graphics.setColor(0, 1, 0)
        else
            love.graphics.setColor(0.5, 0.5, 0.5)
        end
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x, y, 350, achievementHeight, 5)
        
        -- Draw achievement info
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(Font2)
        
        -- Name
        if achievement.achieved then
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(0.7, 0.7, 0.7)
        end
        love.graphics.print(achievement.name, x + 10, y + 5)
        
        -- Progress indicator
        local currentValue = 0
        if achievement.type == "jumps" then
            currentValue = PlayerStats.jumps or 0
        elseif achievement.type == "coins" then
            currentValue = PlayerStats.coins or 0
        elseif achievement.type == "diamonds" then
            currentValue = PlayerStats.diamonds or 0
        elseif achievement.type == "levels" then
            currentValue = PlayerStats.levelsCompleted or 0
        elseif achievement.type == "skins" then
            currentValue = 0
            if SaveData.ownedSkins then
                for _, owned in pairs(SaveData.ownedSkins) do
                    if owned then currentValue = currentValue + 1 end
                end
            end
        elseif achievement.type == "days" then
            currentValue = PlayerStats.daysClaimed or 0
        elseif achievement.type == "achievements" then
            currentValue = PlayerStats.achievementsUnlocked or 0
        elseif achievement.type == "deaths" then
            currentValue = PlayerStats.deaths or 0
        end
        
        -- Progress text
        love.graphics.setFont(Font4)
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.print(currentValue .. "/" .. achievement.goal, x + 280, y + 10)
        
        -- Draw checkmark for completed achievements
        if achievement.achieved then
            love.graphics.setColor(0, 1, 0)
            love.graphics.setFont(Font2)
            love.graphics.print("✓", x + 331, y + 9)
        end
    end
    
    -- Draw exit button
    if ButtonsAchievements.Exit then
        DrawButton(ButtonsAchievements.Exit)
    end
    
    love.graphics.setColor(1, 1, 1)
end

function DrawCredits()
    love.graphics.setFont(Font1)
    Bg.Draw()
    
    -- Draw title
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("CREDITS", 0, 30, WINDOW_WIDTH, "center")
    
    -- Draw credit buttons
    for _, button in pairs(ButtonsCredits) do
        DrawButton(button)
    end
    
    love.graphics.setColor(1, 1, 1)
end

function DrawDailyReward()
    love.graphics.setFont(Font1)
    Bg.Draw()
    
    -- Draw title
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("DAILY REWARD", 0, 30, WINDOW_WIDTH, "center")
    
    -- Draw buttons
    for _, button in pairs(ButtonsDaily) do
        DrawButton(button)
    end
    
    love.graphics.setColor(1, 1, 1)
end

----------------------------------------------------------------
-- ENHANCED INPUT HANDLER FUNCTIONS
----------------------------------------------------------------
function HandleMenuClicks(x, y)
    -- Main menu buttons
    for buttonName, button in pairs(Buttons) do
        if PointInButton(button, x, y) then
            if buttonName == "start" then
                LoadLevel(1)
                GameState.ACTIVE = GameState.PLAY
                PlayMusic()
            elseif buttonName == "levelselect" then
                GameState.ACTIVE = GameState.LEVELSELECT
            elseif buttonName == "settings" then
                GameState.ACTIVE = GameState.SETTINGS
            elseif buttonName == "exit" then
                love.event.quit()
            elseif buttonName == "credits" then
                GameState.ACTIVE = GameState.CREDITS
            elseif buttonName == "achievements" then
                GameState.ACTIVE = GameState.ACHIEVEMENTS
            elseif buttonName == "shop" then
                GameState.ACTIVE = GameState.SHOP
            elseif buttonName == "daily" then
                -- Show daily reward screen
                local canClaim, streak, message = CheckDailyReward()
                if canClaim then
                    PopWindow.ShowDailyRewardPopup(streak, 50 + (streak * 10), 1 + math.floor(streak / 3))
                else
                    PopWindow.ShowMessage("Daily Reward", 
                        "You've already claimed your reward today.\n\n" ..
                        "Current streak: Day " .. streak .. "\n" ..
                        "Come back tomorrow!")
                end
            end
            return true
        end
    end
    
    -- Inventory button
    if ButtonsInventory.Inventory and PointInButton(ButtonsInventory.Inventory, x, y) then
        ShowInventoryModal()
        return true
    end
    
    -- Diamond currency button
    if ButtonsCurrency.Diamond and PointInButton(ButtonsCurrency.Diamond, x, y) then
        ShowCurrencyConversionModal("diamond")
        return true
    end
    
    -- Coin currency button
    if ButtonsCurrency.Coin and PointInButton(ButtonsCurrency.Coin, x, y) then
        ShowCurrencyConversionModal("coin")
        return true
    end
    
    return false
end

function ShowInventoryModal()
    local buttons = {}
    
    -- Add equip buttons for owned skins
    for _, skin in ipairs(Skins) do
        if SaveData.ownedSkins and SaveData.ownedSkins[skin.id] then
            table.insert(buttons, {
                text = "Equip: " .. skin.name,
                onClick = function()
                    SaveData.equippedSkin = skin.id
                    PopWindow.Close()
                    PopWindow.ShowMessage("Equipped", skin.name .. " is now equipped.") 
                end
            })
        end
    end
    
    -- Add close button
    table.insert(buttons, {
        text = "Close",
        onClick = function() PopWindow.Close() end
    })
    
    PopWindow.Show("Inventory", "Choose a skin to equip:", buttons)
end

function ShowCurrencyConversionModal(currencyType)
    local buttons = {}
    
    if currencyType == "diamond" then
        buttons = {
            {
                text = "Convert 1 Diamond",
                onClick = function()            
                    if (SaveData.diamonds or 0) >= 1 then
                        SaveData.diamonds = SaveData.diamonds - 1
                        SaveData.coins = (SaveData.coins or 0) + 100
                        PopWindow.Close()
                        PopWindow.ShowMessage("Converted", "Converted 1 diamond into 100 coins.")
                    else
                        PopWindow.ShowMessage("Insufficient Diamonds", "You don't have enough diamonds.")
                    end
                end
            },
            {
                text = "Convert All Diamonds",
                onClick = function()
                    local diamonds = SaveData.diamonds or 0
                    if diamonds <= 0 then
                        PopWindow.ShowMessage("No Diamonds", "You don't have any diamonds to convert.")
                    else
                        SaveData.coins = (SaveData.coins or 0) + diamonds * 100
                        SaveData.diamonds = 0
                        PopWindow.Close()
                        PopWindow.ShowMessage("Converted", "Converted " .. diamonds .. " diamonds into " .. (diamonds * 100) .. " coins.")
                    end
                end
            },
            {
                text = "Close",
                onClick = function() PopWindow.Close() end
            }
        }
        PopWindow.Show("Convert Diamonds", "Exchange diamonds for coins (1 diamond = 100 coins):", buttons)
    else
        buttons = {
            {
                text = "Buy 1 Diamond (100 coins)",
                onClick = function()
                    if (SaveData.coins or 0) >= 100 then
                        SaveData.coins = SaveData.coins - 100
                        SaveData.diamonds = (SaveData.diamonds or 0) + 1
                        PopWindow.Close()
                        PopWindow.ShowMessage("Purchased", "Bought 1 diamond for 100 coins.")
                    else
                        PopWindow.ShowMessage("Insufficient Coins", "You need 100 coins to buy 1 diamond.")
                    end
                end
            },
            {
                text = "Close",
                onClick = function() PopWindow.Close() end
            }
        }
        PopWindow.Show("Buy Diamonds", "Purchase diamonds with coins (100 coins = 1 diamond):", buttons)
    end
end

function HandleGameplayClicks(x, y, button)
    -- Check pause button first
    if PointInButton(ButtonPause, x, y) then
        GameState.ACTIVE = GameState.PAUSE
        return true
    end
    
    -- Handle regular jump input
    if button == 1 then  -- Left mouse button
        HandleJumpInput("mouse", button)
        return true
    end
    
    return false
end

function HandleLevelSelectClicks(x, y)
    -- Exit button
    if ButtonsLevelSelect.Exit and PointInButton(ButtonsLevelSelect.Exit, x, y) then
        GameState.ACTIVE = GameState.MENU
        return true
    end
    
    -- Level buttons
    for _, levelButton in ipairs(LevelButtons) do
        if PointInButton(levelButton, x, y) then
            -- Check if level is unlocked
            if IsLevelUnlocked(levelButton.id) then
                LoadLevel(levelButton.id)
                GameState.ACTIVE = GameState.PLAY
                PlayMusic()
            else
                -- Show locked message
                local requiredLevel = levelButton.id - 1
                PopWindow.ShowMessage("Level Locked", 
                    "You need to complete Level " .. requiredLevel .. 
                    " to unlock this level.\n\n" ..
                    "Complete previous levels to unlock new challenges!")
            end
            return true
        end
    end
    
    return false
end

function HandleLevelCompleteClicks(x, y)
    -- Next level button
    if PointInButton(LevelCompleteButtons.next, x, y) then
        local nextLevelID = CurrentLevelID + 1
        
        if Levels[nextLevelID] then
            LoadLevel(nextLevelID)
            GameState.ACTIVE = GameState.PLAY
            PlayMusic()
        else
            -- No more levels
            PopWindow.ShowMessage("Congratulations!", 
                "You have completed all levels!\n\n" ..
                "Thank you for playing Geometry Dash.\n" ..
                "New levels will be added in future updates.")
            GameState.ACTIVE = GameState.MENU
        end
        return true
    
    -- Menu button
    elseif PointInButton(LevelCompleteButtons.menu, x, y) then
        GameState.ACTIVE = GameState.MENU
        PlayMusic()
        return true
        
    -- Replay button
    elseif PointInButton(LevelCompleteButtons.replay, x, y) then
        LoadLevel(CurrentLevelID)
        GameState.ACTIVE = GameState.PLAY
        PlayMusic()
        return true
    end
    
    return false
end

function HandlePauseMenuClicks(x, y)
    -- Resume button
    if PointInButton(ButtonsPause.Resume, x, y) then
        GameState.ACTIVE = GameState.PLAY
        return true

    -- Exit to menu button
    elseif PointInButton(ButtonsPause.Exit, x, y) then
        GameState.ACTIVE = GameState.MENU
        PlayMusic()
        return true
    
    -- Settings button
    elseif PointInButton(ButtonsPause.Settings, x, y) then
        GameState.ACTIVE = GameState.SETTINGS
        return true
    end
    
    return false
end

function HandleGameOverClicks(x, y)
    -- Retry button
    if PointInButton(ButtonsGameover.Retry, x, y) then
        LoadLevel(CurrentLevelID)
        GameState.ACTIVE = GameState.PLAY
        PlayMusic()
        return true
    
    -- Exit to menu button
    elseif PointInButton(ButtonsGameover.Exit, x, y) then
        GameState.ACTIVE = GameState.MENU
        PlayMusic()
        return true
    end
    
    return false
end

function HandleSettingsClicks(x, y)
    -- Exit button
    if PointInButton(ButtonsSettings.Exit, x, y) then
        GameState.ACTIVE = GameState.MENU
        SaveSettings()
        return true
    
    -- Music toggle
    elseif PointInButton(ButtonsSettings.MusicOption, x, y) then
        ButtonsSettings.MusicOption.text = ButtonsSettings.MusicOption.text == "Y" and "N" or "Y"
        
        -- Apply music setting
        if ButtonsSettings.MusicOption.text == "Y" then
            PlayMusic()
        else
            StopMusic()
        end
        
        SaveSettings()
        return true
    -- Speed setting
    elseif PointInButton(ButtonsSettings.SpeedOption, x, y) then
        local currentSpeed = ButtonsSettings.SpeedOption.text
        local speedValues = {"1", "1.5", "2", "2.5", "3"}
        local currentIndex = 1
        
        -- Find current index
        for i, value in ipairs(speedValues) do
            if value == currentSpeed then
                currentIndex = i
                break
            end
        end
        
        -- Get next speed
        local nextIndex = (currentIndex % #speedValues) + 1
        ButtonsSettings.SpeedOption.text = speedValues[nextIndex]
        
        -- Apply speed setting
        BASE_SCROLL_SPEED = TILE_SIZE * (6 + (nextIndex * 2))  -- Scales from 8 to 16
        
        SaveSettings()
        return true
    
    -- Controls setting
    elseif PointInButton(ButtonsSettings.ControlOption, x, y) then
        local controlModes = {"Click", "Space", "Arrow"}
        local currentMode = ButtonsSettings.ControlOption.text
        local currentIndex = 1
        
        -- Find current index
        for i, mode in ipairs(controlModes) do
            if mode == currentMode then
                currentIndex = i
                break
            end
        end
        
        -- Get next mode
        local nextIndex = (currentIndex % #controlModes) + 1
        ButtonsSettings.ControlOption.text = controlModes[nextIndex]
        
        SaveSettings()
        return true
    
    -- Theme setting
    elseif PointInButton(ButtonsSettings.ThemeOption, x, y) then
        ButtonsSettings.ThemeOption.text = ButtonsSettings.ThemeOption.text == "White" and "Black" or "White"
        ApplyThemeToAllButtons()
        SaveSettings()
        return true
    end
    return false
end

function SaveSettings()
    if not SaveData.settings then
        SaveData.settings = {}
    end
    
    SaveData.settings.musicEnabled = ButtonsSettings.MusicOption.text == "Y"
    SaveData.settings.scrollSpeed = tonumber(ButtonsSettings.SpeedOption.text) or 1
    SaveData.settings.controls = ButtonsSettings.ControlOption.text
    SaveData.settings.theme = ButtonsSettings.ThemeOption.text
    if SaveGame then
        SaveGame()
    end
end

function HandleShopClicks(x, y)
    -- Exit button
    if ButtonsShop.Exit and PointInButton(ButtonsShop.Exit, x, y) then
        GameState.ACTIVE = GameState.MENU
        return true
    
    -- Claim daily diamonds button
    elseif ButtonsShop.Claim and PointInButton(ButtonsShop.Claim, x, y) then
        ClaimDailyDiamonds()
        return true
        
    -- Convert currency button
    elseif ButtonsShop.Convert and PointInButton(ButtonsShop.Convert, x, y) then
        ShowCurrencyConversionModal("diamond")
        return true
    end
    
    -- Skin purchase buttons
    for i = 1, #Skins do
        local btnKey = 'skin' .. i
        local button = ButtonsShop[btnKey]
        if button and PointInButton(button, x, y) then
            ShowSkinPurchaseModal(i)
            return true
        end
    end
    
    return false
end

function ShowSkinPurchaseModal(skinIndex)
    local skin = Skins[skinIndex]
    if not skin then return end
    
    local buttons = {}
    local owned = SaveData.ownedSkins and SaveData.ownedSkins[skin.id] or false
    
    if owned then
        -- Already owned - equip option
        table.insert(buttons, {
            text = "Equip Skin",
            onClick = function()        
                SaveData.equippedSkin = skin.id
                PopWindow.Close()
                PopWindow.ShowMessage("Equipped", skin.name .. " is now equipped.")
            end
        })
    else
        -- Not owned - purchase option
        table.insert(buttons, {
            text = "Purchase (" .. skin.price .. " coins)",
            onClick = function()
                if (SaveData.coins or 0) >= skin.price then
                    SaveData.coins = SaveData.coins - skin.price
                    SaveData.ownedSkins[skin.id] = true
                    PopWindow.Close()
                    PopWindow.ShowMessage("Purchased!", "You bought the " .. skin.name .. " skin!\n\n" ..
                        "Coins remaining: " .. SaveData.coins)
                        
                    -- Play purchase sound
                    PlaySound("buy")
                    
                    -- Check for skin achievement
                    AchievementsCounter()
                else
                    local needed = skin.price - (SaveData.coins or 0)
                    PopWindow.ShowMessage("Not Enough Coins", 
                        "You need " .. needed .. " more coins to purchase this skin.\n\n" ..
                        "Your coins: " .. (SaveData.coins or 0) .. "\n" ..
                        "Skin price: " .. skin.price)
                end
            end
        })
    end
    
    table.insert(buttons, {
        text = "Close",
        onClick = function() PopWindow.Close() end
    })
    
    PopWindow.Open(skin.name, 
        "Price: " .. skin.price .. " coins\n" ..
        "Status: " .. (owned and "OWNED" or "NOT OWNED") .. "\n\n" ..
        "A unique skin color for your player character.",
        buttons, { previewSkin = skin.id })
end

function HandleAchievementsClicks(x, y)
    -- Exit button
    if ButtonsAchievements.Exit and PointInButton(ButtonsAchievements.Exit, x, y) then
        GameState.ACTIVE = GameState.MENU
        return true
    end
    
    -- Achievement buttons
    for i = 1, #Achievements do
        local btnKey = "achievement" .. i
        local button = ButtonsAchievements[btnKey]
        if button and PointInButton(button, x, y) then
            local achievement = Achievements[i]
            
            -- Get current progress
            local currentValue = 0
            if achievement.type == "jumps" then
                currentValue = PlayerStats.jumps or 0
            elseif achievement.type == "coins" then
                currentValue = PlayerStats.coins or 0
            elseif achievement.type == "diamonds" then
                currentValue = PlayerStats.diamonds or 0
            elseif achievement.type == "levels" then
                currentValue = PlayerStats.levelsCompleted or 0
            elseif achievement.type == "skins" then
                currentValue = 0
                if SaveData.ownedSkins then
                    for _, owned in pairs(SaveData.ownedSkins) do
                        if owned then currentValue = currentValue + 1 end
                    end
                end
            elseif achievement.type == "days" then
                currentValue = PlayerStats.daysClaimed or 0
            elseif achievement.type == "achievements" then
                currentValue = PlayerStats.achievementsUnlocked or 0
            elseif achievement.type == "deaths" then
                currentValue = PlayerStats.deaths or 0
            end
            
            local progress = math.min(100, math.floor((currentValue / achievement.goal) * 100))
            
            PopWindow.Show(
                achievement.name .. (achievement.achieved and " ✓" or ""),
                achievement.description .. "\n\n" ..
                "Progress: " .. currentValue .. "/" .. achievement.goal .. 
                " (" .. progress .. "%)\n" ..
                "Status: " .. (achievement.achieved and "UNLOCKED" or "LOCKED") .. "\n\n" ..
                "Reward: " .. achievement.rewardCoins .. " coins, " .. achievement.rewardDiamonds .. " diamonds",
                {
                    { text = "Close", onClick = function() PopWindow.Close() end }
                }
            )
            return true
        end
    end
    
    return false
end

function HandleDailyRewardClicks(x, y)
    -- Claim button
    if ButtonsDaily.claim and PointInButton(ButtonsDaily.claim, x, y) then
        ClaimDailyDiamonds()
        return true
    
    -- Close button
    elseif ButtonsDaily.close and PointInButton(ButtonsDaily.close, x, y) then
        GameState.ACTIVE = GameState.MENU
        return true
    end
    
    return false
end

----------------------------------------------------------------
-- BUTTON UPDATE FUNCTION
----------------------------------------------------------------
function UpdateUIButtons(deltaTime)
    if GameState.ACTIVE == GameState.MENU then
        for _, button in pairs(Buttons) do
            UpdateButton(button, deltaTime)
        end
        
        if ButtonsCurrency then
            for _, button in pairs(ButtonsCurrency) do
                UpdateButton(button, deltaTime)
            end
        end
        
        if ButtonsInventory then
            for _, button in pairs(ButtonsInventory) do
                UpdateButton(button, deltaTime)
            end
        end
        
    elseif GameState.ACTIVE == GameState.PAUSE then
        for _, button in pairs(ButtonsPause) do
            UpdateButton(button, deltaTime)
        end
    elseif GameState.ACTIVE == GameState.ACHIEVEMENTS then
        for _, button in pairs(ButtonsAchievements) do
            UpdateButton(button, deltaTime)
        end
    elseif GameState.ACTIVE == GameState.CREDITS then
        for _, button in pairs(ButtonsCredits) do
            UpdateButton(button, deltaTime)
        end
    elseif GameState.ACTIVE == GameState.GAMEOVER then
        for _, button in pairs(ButtonsGameover) do
            UpdateButton(button, deltaTime)
        end
    elseif GameState.ACTIVE == GameState.SETTINGS then
        for _, button in pairs(ButtonsSettings) do
            UpdateButton(button, deltaTime)
        end
    elseif GameState.ACTIVE == GameState.LEVELSELECT then
        for _, button in pairs(ButtonsLevelSelect) do
            UpdateButton(button, deltaTime)
        end
        for _, button in ipairs(LevelButtons) do
            UpdateButton(button, deltaTime)
        end
    elseif GameState.ACTIVE == GameState.SHOP then
        for _, button in pairs(ButtonsShop) do
            UpdateButton(button, deltaTime)
        end
    elseif GameState.ACTIVE == GameState.DAILY_REWARD then
        for _, button in pairs(ButtonsDaily) do
            UpdateButton(button, deltaTime)
        end
    end
end