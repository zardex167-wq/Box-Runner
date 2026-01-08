local helper = {}

require("conf")

----------------------------------------------------------------
-- ENHANCED THEME APPLICATION SYSTEM
----------------------------------------------------------------
function AddHoverDefaults(buttonTable)
    local themeOption = ButtonsSettings.ThemeOption
    for _, button in pairs(buttonTable) do
        if themeOption.text == "White" then
            button.color = COLORS.WHITE
            button.hoverColor = COLORS.YELLOW
            button.scale = 1
            button.lineWidth = LINE_WIDTHS.WHITE
            button.textColor = COLORS.WHITE
        elseif themeOption.text == "Black" then
            button.color = COLORS.BLACK
            button.hoverColor = COLORS.GRAY
            button.scale = 2
            button.lineWidth = LINE_WIDTHS.BLACK
            button.textColor = COLORS.WHITE
        end
        button.offset = 0
        button.hover = false
    end
end

function ApplyThemeToAllButtons()
    AddHoverDefaults(Buttons)
    AddHoverDefaults(ButtonsPause)
    AddHoverDefaults(ButtonsGameover)
    AddHoverDefaults(LevelCompleteButtons)
    AddHoverDefaults(ButtonsSettings)
    AddHoverDefaults(ButtonsShop)
    AddHoverDefaults(ButtonsAchievements)
    AddHoverDefaults(ButtonsCredits)
    AddHoverDefaults(ButtonsLevelSelect)
    AddHoverDefaults(LevelButtons)
    AddHoverDefaults({ButtonPause})
    AddHoverDefaults(ButtonsCurrency)
    AddHoverDefaults(ButtonsInventory)
end

----------------------------------------------------------------
-- ENHANCED COORDINATE TRANSFORMATION
----------------------------------------------------------------


function ScreenToWorld(x, y)
    local scale = Scale or 1
    local offsetX = OffsetX or 0
    local offsetY = OffsetY or 0
    
    return (x - offsetX) / scale, (y - offsetY) / scale
end

function WorldToScreen(x, y)
    local scale = Scale or 1
    local offsetX = OffsetX or 0
    local offsetY = OffsetY or 0
    
    return x * scale + offsetX, y * scale + offsetY
end

----------------------------------------------------------------
-- ENHANCED BUTTON SYSTEM  OPTIMIZATION
----------------------------------------------------------------
function UpdateButton(button, deltaTime, scrollY)
    scrollY = scrollY or 0
    
    -- Initialize defaults
    button.scale = button.scale or 1
    button.offset = button.offset or 0
    button.hover = button.hover or false
    button.lineWidth = button.lineWidth or 3
    
    -- Desktop hover detection
    local mouseX, mouseY = love.mouse.getPosition()
    mouseX, mouseY = ScreenToWorld(mouseX, mouseY)
    
    local scaledWidth = button.width * button.scale
    local scaledHeight = button.height * button.scale
    local buttonX = button.x - (scaledWidth - button.width) / 2
    local buttonY = button.y - (scaledHeight - button.height) / 2 + button.offset + scrollY
    
    button.hover = (mouseX >= buttonX and mouseX <= buttonX + scaledWidth and
                   mouseY >= buttonY and mouseY <= buttonY + scaledHeight)
    
    -- Animate hover with sound effect
    local animationSpeed = 12
    if button.hover then
        local oldScale = button.scale
        button.scale = button.scale + (1.15 - button.scale) * animationSpeed * deltaTime
        button.offset = button.offset + (-6 - button.offset) * animationSpeed * deltaTime
        
        -- Play hover sound on scale change
        if oldScale < 1.1 and button.scale >= 1.1 then
            PlaySound("hover")
        end
    else
        button.scale = button.scale + (1 - button.scale) * animationSpeed * deltaTime
        button.offset = button.offset + (0 - button.offset) * animationSpeed * deltaTime
    end
end

function PointInButton(button, pointX, pointY, scrollY)
    scrollY = scrollY or 0
    pointX, pointY = ScreenToWorld(pointX, pointY)
    
    local scale = button.scale or 1
    local offset = button.offset or 0
    local scaledWidth = button.width * scale
    local scaledHeight = button.height * scale
    local buttonX = button.x - (scaledWidth - button.width) / 2
    local buttonY = button.y - (scaledHeight - button.height) / 2 + offset + scrollY
    
    return pointX >= buttonX and pointX <= buttonX + scaledWidth and
           pointY >= buttonY and pointY <= buttonY + scaledHeight
end

function DrawButton(button, scrollY)
    scrollY = scrollY or 0
    
    -- Calculate scaled position
    local scale = button.scale or 1
    local offset = button.offset or 0
    local scaledWidth = button.width * scale
    local scaledHeight = button.height * scale
    local x = button.x - (scaledWidth - button.width) / 2
    local y = button.y - (scaledHeight - button.height) / 2 + offset + scrollY
    
    -- Set button color
    local color = (button.hover and button.hoverColor) or button.color or COLORS.WHITE
    if type(color) == "table" then
        love.graphics.setColor(color[1] or 1, color[2] or 1, color[3] or 1, color[4] or 1)
    else
        love.graphics.setColor(1, 1, 1)
    end
    
    -- Draw button outline
    love.graphics.setLineWidth(button.lineWidth or 3)
    love.graphics.rectangle("line", x, y, scaledWidth, scaledHeight, 10, 10)
    
    -- Draw button text
    local textColor = button.textColor or COLORS.WHITE
    if type(textColor) == "table" then
        love.graphics.setColor(textColor[1] or 1, textColor[2] or 1, textColor[3] or 1, textColor[4] or 1)
    else
        love.graphics.setColor(1, 1, 1)
    end
    
    local font = Font2 or love.graphics.getFont()
    love.graphics.setFont(font)
    love.graphics.printf(button.text or "", x, y + scaledHeight/2 - 12, scaledWidth, "center")
end

----------------------------------------------------------------
-- ENHANCED INPUT HANDLING WITH SOUND EFFECTS
----------------------------------------------------------------
function HandleJumpInput(inputType, inputValue)
    if not Player.isOnGround then return end
    
    local controlSetting = ButtonsSettings.ControlOption
    local shouldJump = false
    
    if controlSetting.text == "Click" then
        if (inputType == "mouse" and inputValue == 1) or inputType == "touch" then
            shouldJump = true
        end
    elseif controlSetting.text == "Touch" then
        if inputType == "touch" or (inputType == "mouse" and inputValue == 1) then
            shouldJump = true
        end
    elseif controlSetting.text == "Space" then
        if inputType == "key" and inputValue == "space" then
            shouldJump = true
        end
    elseif controlSetting.text == "Arrow" then
        if inputType == "key" and inputValue == "up" then
            shouldJump = true
        end
    end
    
    if shouldJump then
        Player.yVelocity = JUMP_VELOCITY
        Player.isOnGround = false
        PlayerStats.jumps = (PlayerStats.jumps or 0) + 1
        SaveData.jumps = (SaveData.jumps or 0) + 1
        
        -- Play jump sound
        PlaySound("jump")
        
        -- Create jump particles
        CreateJumpParticles()
        
        -- Save progress
        if SaveGame then SaveGame() end
    end
end

----------------------------------------------------------------
-- PARTICLE SYSTEM FOR VISUAL EFFECTS
----------------------------------------------------------------
local particles = {
    jump = {},
    coin = {},
    death = {},
    complete = {}
}

function CreateJumpParticles()
    -- Disabled: in-game particles removed per user request
    return
end

function CreateCoinParticles(x, y)
    -- Disabled: in-game particles removed per user request
    return
end

function CreateDeathParticles(x, y)
    -- Disabled: in-game particles removed per user request
    return
end

function CreateLevelCompleteParticles()
    -- Disabled: in-game particles removed per user request
    return
end

function UpdateParticles(deltaTime)
    -- Particles disabled for gameplay: clear any existing particle lists
    particles.jump = {}
    particles.coin = {}
    particles.death = {}
    particles.complete = {}
end

function DrawParticles()
    -- Particles drawing disabled for gameplay (menu particles handled by BackgroundSystem)
    return
end

----------------------------------------------------------------
-- SOUND EFFECT SYSTEM
----------------------------------------------------------------
local soundEffects = {
    jump = nil,
    coin = nil,
    death = nil,
    complete = nil,
    click = nil,
    hover = nil,
    achievement = nil,
    buy = nil
}

function LoadSoundEffects()
    -- Try to load sound effects if they exist
    -- Note: You need to create these sound files or use placeholders
    if love.filesystem.getInfo("Sounds/jump.wav") then
        soundEffects.jump = love.audio.newSource("Sounds/jump.wav", "static")
    end
    
    if love.filesystem.getInfo("Sounds/coin.wav") then
        soundEffects.coin = love.audio.newSource("Sounds/coin.wav", "static")
    end
    
    if love.filesystem.getInfo("Sounds/death.wav") then
        soundEffects.death = love.audio.newSource("Sounds/death.wav", "static")
    end
    
    if love.filesystem.getInfo("Sounds/complete.wav") then
        soundEffects.complete = love.audio.newSource("Sounds/complete.wav", "static")
    end
    
    if love.filesystem.getInfo("Sounds/click.wav") then
        soundEffects.click = love.audio.newSource("Sounds/click.wav", "static")
    end
    
    if love.filesystem.getInfo("Sounds/hover.wav") then
        soundEffects.hover = love.audio.newSource("Sounds/hover.wav", "static")
    end
    
    if love.filesystem.getInfo("Sounds/achievement.wav") then
        soundEffects.achievement = love.audio.newSource("Sounds/achievement.wav", "static")
    end
    
    if love.filesystem.getInfo("Sounds/buy.wav") then
        soundEffects.buy = love.audio.newSource("Sounds/buy.wav", "static")
    end
end

function PlaySound(soundName)
    if not SaveData.settings or SaveData.settings.soundEnabled == false then
        return
    end
    
    local sound = soundEffects[soundName]
    if sound then
        sound:stop()
        sound:play()
    end
end

function PlayMusic()
    if SaveData.settings and SaveData.settings.musicEnabled and Music and Music.Play then
        Music.Play()
    end
end

function StopMusic()
    if Music and Music.Stop then
        Music.Stop()
    end
end

----------------------------------------------------------------
-- ENHANCED UI COMPONENTS
----------------------------------------------------------------
function DrawPanel(x, y, width, height, options)
    options = options or {}
    local color = options.color or {0.12, 0.12, 0.12, 1}
    local outlineColor = options.outlineColor
    local rounding = options.rounding or 6
    
    -- Draw fill
    if type(color) == "table" then
        love.graphics.setColor(color[1], color[2], color[3], color[4] or 1)
    else
        love.graphics.setColor(1, 1, 1, 1)
    end
    love.graphics.rectangle("fill", x, y, width, height, rounding, rounding)
    
    -- Draw outline
    if outlineColor then
        if type(outlineColor) == "table" then
            love.graphics.setColor(outlineColor[1], outlineColor[2], outlineColor[3], outlineColor[4] or 1)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
        love.graphics.setLineWidth(options.outlineWidth or 3)
        love.graphics.rectangle("line", x, y, width, height, rounding, rounding)
    end
end

function DrawSwatch(x, y, width, height, color)
    color = color or {1, 1, 1}
    DrawPanel(x, y, width, height, { color = color, outlineColor = nil, rounding = 6 })
end

function DrawProgressBar(x, y, width, height, progress, options)
    options = options or {}
    local backgroundColor = options.backgroundColor or {0.2, 0.2, 0.2, 1}
    local fillColor = options.fillColor or {0.2, 0.8, 0.2, 1}
    local borderColor = options.borderColor or {0.4, 0.4, 0.4, 1}
    
    -- Draw background
    love.graphics.setColor(backgroundColor[1], backgroundColor[2], backgroundColor[3], backgroundColor[4] or 1)
    love.graphics.rectangle("fill", x, y, width, height, 3, 3)
    
    -- Draw fill
    local fillWidth = math.max(0, math.min(width, width * progress))
    if fillWidth > 0 then
        love.graphics.setColor(fillColor[1], fillColor[2], fillColor[3], fillColor[4] or 1)
        love.graphics.rectangle("fill", x, y, fillWidth, height, 3, 3)
    end
    
    -- Draw border
    love.graphics.setColor(borderColor[1], borderColor[2], borderColor[3], borderColor[4] or 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height, 3, 3)
end

----------------------------------------------------------------
-- ENHANCED ACHIEVEMENT SYSTEM WITH POPUP NOTIFICATIONS
----------------------------------------------------------------
function AchievementsCounter()
    if not Achievements or not PlayerStats then return end
    
    local newlyUnlocked = 0
    
    for _, achievement in ipairs(Achievements) do
        if not achievement.achieved then
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
                -- Count owned skins
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
            
            if currentValue >= achievement.goal then
                achievement.achieved = true
                newlyUnlocked = newlyUnlocked + 1
                PlayerStats.achievementsUnlocked = (PlayerStats.achievementsUnlocked or 0) + 1
                
                -- Show achievement unlocked popup
                if PopWindow and PopWindow.ShowAchievementUnlocked then
                    PopWindow.ShowAchievementUnlocked(achievement.name, achievement.description)
                else
                    -- Fallback to regular popup
                    PopWindow.ShowMessage(
                        "Achievement Unlocked!",
                        achievement.name .. "\n" .. achievement.description
                    )
                end
                
                -- Play achievement sound
                PlaySound("achievement")
                
                -- Grant achievement rewards
                if achievement.rewardCoins and achievement.rewardCoins > 0 then
                    SaveData.coins = (SaveData.coins or 0) + achievement.rewardCoins
                    PlayerStats.coins = (PlayerStats.coins or 0) + achievement.rewardCoins
                end
                
                if achievement.rewardDiamonds and achievement.rewardDiamonds > 0 then
                    SaveData.diamonds = (SaveData.diamonds or 0) + achievement.rewardDiamonds
                    PlayerStats.diamonds = (PlayerStats.diamonds or 0) + achievement.rewardDiamonds
                end
            end
        end
    end
end

----------------------------------------------------------------
-- ENHANCED LEVEL REWARD SYSTEM
----------------------------------------------------------------
function GetLevelReward(levelId)
    if not levelId then return 0, 0 end
    
    -- Enhanced reward scaling
    local baseCoins = 10
    local baseDiamonds = 1
    
    -- Level difficulty bonuses
    if levelId <= 4 then
        return baseCoins, baseDiamonds
    elseif levelId <= 8 then
        return baseCoins * 2, baseDiamonds * 2
    elseif levelId <= 12 then
        return baseCoins * 3, baseDiamonds * 3
    else
        -- Bonus levels beyond 12
        return baseCoins * 4, baseDiamonds * 4
    end
end

function CompleteLevel(levelId)
    if not levelId then return end
    
    -- Mark level as completed
    SaveData.unlockedLevels = SaveData.unlockedLevels or {}
    SaveData.unlockedLevels[levelId] = true
    
    -- Unlock next level
    local nextLevelId = levelId + 1
    SaveData.unlockedLevels[nextLevelId] = true
    
    -- Update completion stats
    PlayerStats.levelsCompleted = (PlayerStats.levelsCompleted or 0) + 1
    SaveData.levelsCompleted = (SaveData.levelsCompleted or 0) + 1
    
    -- Calculate and award rewards
    local coinReward, diamondReward = GetLevelReward(levelId)
    if coinReward > 0 then
        SaveData.coins = (SaveData.coins or 0) + coinReward
        PlayerStats.coins = (PlayerStats.coins or 0) + coinReward
    end
    
    if diamondReward > 0 then
        SaveData.diamonds = (SaveData.diamonds or 0) + diamondReward
        PlayerStats.diamonds = (PlayerStats.diamonds or 0) + diamondReward
    end
    
    -- Create celebration particles
    CreateLevelCompleteParticles()
    
    -- Play completion sound
    PlaySound("complete")
    
    -- Save progress
    if SaveGame then SaveGame() end
    
    AchievementsCounter()
end

----------------------------------------------------------------
-- DAILY REWARD SYSTEM
----------------------------------------------------------------
function CheckDailyReward()
    local today = os.date("%Y-%m-%d")
    local lastClaim = SaveData.lastClaim or ""
    
    if lastClaim == "" then
        -- First time claiming
        return true, 1, "First daily reward!"
    elseif lastClaim == today then
        -- Already claimed today
        return false, SaveData.streakCount or 0, "Already claimed today"
    else
        -- Check streak
        local streak = SaveData.streakCount or 0
        local yesterday = os.date("%Y-%m-%d", os.time() - 86400)
        
        if lastClaim == yesterday then
            -- Continuing streak
            local newStreak = math.min(streak + 1, 7)
            return true, newStreak, "Day " .. newStreak .. " streak!"
        else
            -- Broken streak, start over
            return true, 1, "New streak started!"
        end
    end
end

function ClaimDailyDiamonds()
    local canClaim, streak, message = CheckDailyReward()

    if not canClaim then
        PopWindow.ShowMessage("Already Claimed", "You have already claimed your daily reward today.\n\nCome back tomorrow!")
        return
    end

    -- Calculate rewards
    local baseCoins = 50
    local baseDiamonds = 1

    -- Streak bonus
    local coinBonus = (streak - 1) * 10
    local diamondBonus = math.floor(streak / 3)  -- Bonus diamond every 3 days

    -- Weekly bonus
    if streak >= 7 then
        coinBonus = coinBonus + 500
        diamondBonus = diamondBonus + 5
    end

    local totalCoins = baseCoins + coinBonus
    local totalDiamonds = baseDiamonds + diamondBonus

    -- Apply rewards
    SaveData.coins = (SaveData.coins or 0) + totalCoins
    SaveData.diamonds = (SaveData.diamonds or 0) + totalDiamonds
    PlayerStats.coins = (PlayerStats.coins or 0) + totalCoins
    PlayerStats.diamonds = (PlayerStats.diamonds or 0) + totalDiamonds
    PlayerStats.daysClaimed = (PlayerStats.daysClaimed or 0) + 1

    -- Update claim/streak info
    SaveData.lastClaim = os.date("%Y-%m-%d")
    SaveData.streakCount = streak

    -- Save and notify
    if SaveGame then SaveGame() end
    PopWindow.ShowMessage("Daily Reward Claimed", "You received " .. totalCoins .. " coins and " .. totalDiamonds .. " diamonds!\n\nCurrent streak: Day " .. streak)

    -- Update achievements/progress
    AchievementsCounter()
end

----------------------------------------------------------------
-- COLLISION DETECTION FUNCTIONS
----------------------------------------------------------------
function AABBRect(ax, ay, awidth, aheight, bx, by, bwidth, bheight)
    return ax < bx + bwidth and
           ax + awidth > bx and
           ay < by + bheight and
           ay + aheight > by
end

function IsLevelUnlocked(levelId)
    if not levelId or levelId < 1 then return false end
    if levelId == 1 then return true end
    return SaveData.unlockedLevels and SaveData.unlockedLevels[levelId] or false
end

----------------------------------------------------------------
-- UTILITY FUNCTIONS
----------------------------------------------------------------
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

function DrawCenteredText(text, y, color)
    color = color or {1, 1, 1}
    local font = Font1 or love.graphics.getFont()
    local textWidth = font:getWidth(text)
    love.graphics.setColor(color)
    love.graphics.print(text, (WINDOW_WIDTH - textWidth) / 2, y)
    love.graphics.setColor(1, 1, 1)
end

function ShowSaveIndicator()
    -- Save indicator disabled for release (silent)
end

-- Deep copy helper
function DeepCopy(orig)
    local orig_type = type(orig)
    if orig_type ~= 'table' then return orig end
    local copy = {}
    for k, v in pairs(orig) do
        copy[DeepCopy(k)] = DeepCopy(v)
    end
    return copy
end

-- Reset in-memory SaveData to defaults and update UI
function ResetSaveData()
    if DefaultSaveData then
        SaveData = DeepCopy(DefaultSaveData)
    else
        SaveData = {}
    end

    -- reset PlayerStats to safe defaults
    PlayerStats = PlayerStats or {}

    -- Update settings UI elements if present
    if ButtonsSettings then
        if ButtonsSettings.MusicOption then ButtonsSettings.MusicOption.text = SaveData.settings.musicEnabled and "Y" or "N" end
        if ButtonsSettings.SpeedOption then ButtonsSettings.SpeedOption.text = tostring(SaveData.settings.scrollSpeed or 1) end
        if ButtonsSettings.ControlOption then ButtonsSettings.ControlOption.text = SaveData.settings.controls end
        if ButtonsSettings.ThemeOption then ButtonsSettings.ThemeOption.text = SaveData.settings.theme end
        if ButtonsSettings.ParticlesOption then ButtonsSettings.ParticlesOption.text = SaveData.settings.particles and "Y" or "N" end
    end

    if SaveGame then SaveGame() end
end

-- Delete save.dat and reset in-memory data
function DeleteSaveFile()
    pcall(function() love.filesystem.remove("save.dat") end)
    ResetSaveData()
    ShowSaveIndicator()
end

----------------------------------------------------------------
-- INITIALIZATION FUNCTION
----------------------------------------------------------------
function InitializeHelper()
    -- Load sound effects
    LoadSoundEffects()
    
end

----------------------------------------------------------------
-- UPDATE ALL SYSTEMS
----------------------------------------------------------------
function UpdateAllSystems(deltaTime)
    -- Cap delta time
    deltaTime = math.min(deltaTime, 1/30)
    
    -- Update particles
    UpdateParticles(deltaTime)
    
    -- Update achievements
    AchievementsCounter()
    
end

----------------------------------------------------------------
-- DRAW ALL VISUAL EFFECTS
----------------------------------------------------------------
function DrawAllVisualEffects()
    -- Draw particles (on top of everything else)
    DrawParticles()
end

----------------------------------------------------------------
-- EXPORT FUNCTIONS
----------------------------------------------------------------
helper.AddHoverDefaults = AddHoverDefaults
helper.ApplyThemeToAllButtons = ApplyThemeToAllButtons
helper.ScreenToWorld = ScreenToWorld
helper.WorldToScreen = WorldToScreen
helper.UpdateButton = UpdateButton
helper.PointInButton = PointInButton
helper.DrawButton = DrawButton
helper.HandleJumpInput = HandleJumpInput
helper.CreateJumpParticles = CreateJumpParticles
helper.CreateCoinParticles = CreateCoinParticles
helper.CreateDeathParticles = CreateDeathParticles
helper.CreateLevelCompleteParticles = CreateLevelCompleteParticles
helper.UpdateParticles = UpdateParticles
helper.DrawParticles = DrawParticles
helper.LoadSoundEffects = LoadSoundEffects
helper.PlaySound = PlaySound
helper.PlayMusic = PlayMusic
helper.StopMusic = StopMusic
helper.DrawPanel = DrawPanel
helper.DrawSwatch = DrawSwatch
helper.DrawProgressBar = DrawProgressBar
helper.AchievementsCounter = AchievementsCounter
helper.GetLevelReward = GetLevelReward
helper.CompleteLevel = CompleteLevel
helper.CheckDailyReward = CheckDailyReward
helper.ClaimDailyDiamonds = ClaimDailyDiamonds
helper.AABBRect = AABBRect
helper.IsLevelUnlocked = IsLevelUnlocked
helper.FormatNumber = FormatNumber
helper.DrawCenteredText = DrawCenteredText
helper.ShowSaveIndicator = ShowSaveIndicator
helper.InitializeHelper = InitializeHelper
helper.UpdateAllSystems = UpdateAllSystems
helper.DrawAllVisualEffects = DrawAllVisualEffects

return helper