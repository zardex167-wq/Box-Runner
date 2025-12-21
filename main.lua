-- main.lua (FIXED VERSION)
-- Geo Dash (with new block types: Transparent, Platform, Mini Spike, Big Spike)
-- Tile size = 32px
require ("level")
require ("conf")
require ("helper")
Bg = require ("backgroundstate")
Music = require("music")
PopWindow = require("popwindow")
-- Persistent save/load helpers (very small ad-hoc serializer)
function SaveGame()
    local s = tostring(SaveData.coins or 0) .. ";" .. tostring(SaveData.diamonds or 0) .. ";"
    local owned = {}
    for k, v in pairs(SaveData.ownedSkins or {}) do if v then table.insert(owned, tostring(k)) end end
    s = s .. table.concat(owned, ",") .. ";" .. tostring(SaveData.equippedSkin or 1)
    s = s .. ";" .. (SaveData.lastClaim or "")
    pcall(function() love.filesystem.write("save.dat", s) end)
end

-- Scroll state / drag state for lists
ChangelogScrollbarDrag = nil
ShopScrollbarDrag = nil
ShopScroll = ShopScroll or 0
ShopTouch = nil
ChangelogTouch = ChangelogTouch or nil

function LoadGame()
    if not love.filesystem.getInfo("save.dat") then return end
    local ok, contents = pcall(function() return love.filesystem.read("save.dat") end)
    if not ok or not contents then return end
    -- Format: coins;diamonds;owned1,owned2,...;equipped;lastClaim
    local coins, diamonds, ownedStr, equipped, lastClaim = contents:match("^(%d+);(%d+);([^;]*);(%d+);?([^;]*)")
    if coins then
        SaveData.coins = tonumber(coins) or 0
        SaveData.diamonds = tonumber(diamonds) or 0
        SaveData.ownedSkins = {}
        if ownedStr and ownedStr ~= "" then
            for id in string.gmatch(ownedStr, "([^,]+)") do
                SaveData.ownedSkins[tonumber(id)] = true
            end
        end
        SaveData.equippedSkin = tonumber(equipped) or 1
        SaveData.lastClaim = lastClaim or ""
    end
end

-- Simple accounts system (per-account save data)
Accounts = {}
CurrentAccount = nil

local function encodeOwned(owned)
    local t = {}
    for k, v in pairs(owned or {}) do if v then table.insert(t, tostring(k)) end end
    return table.concat(t, ",")
end

local function decodeOwned(s)
    local out = {}
    if not s or s == "" then return out end
    for id in string.gmatch(s, "([^,]+)") do out[tonumber(id)] = true end
    return out
end

function SaveAccounts()
    local lines = {}
    for user, acc in pairs(Accounts) do
        local owned = encodeOwned(acc.ownedSkins)
        local line = string.format("%s;%s;%d;%d;%s;%d;%s", user, acc.password or "", acc.coins or 0, acc.diamonds or 0, owned, acc.equippedSkin or 1, acc.lastClaim or "")
        table.insert(lines, line)
    end
    local s = "current=" .. (CurrentAccount or "") .. "\n" .. table.concat(lines, "\n")
    pcall(function() love.filesystem.write("accounts.dat", s) end)
end

function LoadAccounts()
    Accounts = {}
    CurrentAccount = nil
    if not love.filesystem.getInfo("accounts.dat") then return end
    local ok, contents = pcall(function() return love.filesystem.read("accounts.dat") end)
    if not ok or not contents then return end
    local cur, rest = contents:match("^current=([^\n]*)\n?(.*)")
    if cur and cur ~= "" then CurrentAccount = cur end
    for line in string.gmatch(rest, "([^\n]+)") do
        local user,password,coins,diamonds,ownedStr,equipped,lastClaim = line:match("^([^;]+);([^;]*);(%d+);(%d+);([^;]*);(%d+);?(.*)")
        if user then
            local acc = {}
            acc.password = password or ""
            acc.coins = tonumber(coins) or 0
            acc.diamonds = tonumber(diamonds) or 0
            acc.ownedSkins = decodeOwned(ownedStr)
            acc.equippedSkin = tonumber(equipped) or 1
            acc.lastClaim = lastClaim or ""
            Accounts[user] = acc
        end
    end
    if CurrentAccount and Accounts[CurrentAccount] then
        local a = Accounts[CurrentAccount]
        SaveData.coins = a.coins
        SaveData.diamonds = a.diamonds
        SaveData.ownedSkins = a.ownedSkins or {}
        SaveData.equippedSkin = a.equippedSkin or 1
        SaveData.lastClaim = a.lastClaim
    else 
        SaveData.coins = 0
        SaveData.diamonds = 0
        SaveData.ownedSkins = {}
        SaveData.equippedSkin = 1
        SaveData.lastClaim = ""
    end
end

function SaveCurrentAccount()
    if not CurrentAccount then return end
    local a = Accounts[CurrentAccount] or {}
    a.coins = SaveData.coins or 0
    a.diamonds = SaveData.diamonds or 0
    a.ownedSkins = SaveData.ownedSkins or {}
    a.equippedSkin = SaveData.equippedSkin or 1
    a.lastClaim = SaveData.lastClaim or ""
    Accounts[CurrentAccount] = a
    SaveAccounts()
end


function AccountSignIn(username, password)
    if not username or username == "" then return false, "Invalid username" end
    local acc = Accounts[username]
    if acc then
        if acc.password == (password or "") then
            CurrentAccount = username
            -- load account
            SaveData.coins = acc.coins
            SaveData.diamonds = acc.diamonds
            SaveData.ownedSkins = acc.ownedSkins or {}
            SaveData.equippedSkin = acc.equippedSkin or 1
            SaveData.lastClaim = acc.lastClaim
            return true, "Signed in"
        else
            return false, "Incorrect password"
        end
    else
        -- create new account from current SaveData (or defaults)
        local newacc = { password = password or "", coins = SaveData.coins or 0, diamonds = SaveData.diamonds or 0, ownedSkins = SaveData.ownedSkins or {}, equippedSkin = SaveData.equippedSkin or 1, lastClaim = SaveData.lastClaim }
        Accounts[username] = newacc
        CurrentAccount = username
        SaveAccounts()
        return true, "Account created and signed in"
    end
end

function AccountSignOut()
    if CurrentAccount then
        SaveCurrentAccount()
        CurrentAccount = nil
        SaveAccounts()
        -- reset to default local SaveData
        SaveData.coins = 0
        SaveData.diamonds = 0
        SaveData.ownedSkins = {}
        SaveData.equippedSkin = 1
        SaveData.lastClaim = ""
    end
end

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

    -- Load persistent save data (coins/diamonds/skins)
    if LoadGame then LoadGame() end
    -- Load accounts (if any)
    if LoadAccounts then LoadAccounts() end
    -- ensure buttons receive themed defaults after loading save
    ApplyThemeToAllButtons()
    if GameState.active == GameState.menu then
        Bg.Load()
        -- Ensure theme is applied for the default menu level
        if Bg and Bg.SetTheme then Bg.SetTheme("default") end
        -- Detect mobile and set default touch control for testing
        local os = love.system.getOS and love.system.getOS() or ""
        IsMobile = (os == "Android" or os == "iOS")
        if IsMobile then
            if ButtonsSettings and ButtonsSettings.ControlOption then
                ButtonsSettings.ControlOption.text = "Touch"
            end
        else
            IsMobile = false
        end

        -- Setup scaling / virtual resolution
        BaseWidth = WindowWidth
        BaseHeight = WindowHeight
        Scale = 1
        OffsetX = 0
        OffsetY = 0
        local function UpdateScaling()
            local w, h = love.graphics.getWidth(), love.graphics.getHeight()
            local sx = w / BaseWidth
            local sy = h / BaseHeight
            Scale = math.min(sx, sy)
            OffsetX = (w - BaseWidth * Scale) / 2
            OffsetY = (h - BaseHeight * Scale) / 2
        end
        -- expose for resize handler
        UpdateScaling()
        UpdateScalingFunc = UpdateScaling

        -- position mobile jump button relative to virtual window
        if ButtonsMobile and ButtonsMobile.Jump then
            ButtonsMobile.Jump.x = BaseWidth - 110
            ButtonsMobile.Jump.y = BaseHeight - 110
        end

        -- Initialize button theme/colors and defaults
        ApplyThemeToAllButtons()
    end
end
---------------------------------------------------------
-- UPDATE PLAYER (Geometry Dash style) - improved
---------------------------------------------------------
function UpdatePlayer(dt)
    if not CurrentLevel then return end
    -- store previous Y before applying physics!
    local prevY = Player.y
    
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
            -- increment persistent coins and save (simple immediate save)
            SaveData.coins = (SaveData.coins or 0) + 1
            pcall(SaveGame)
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
    -- convert screen -> world coords
    x, y = ScreenToWorld(x, y)
    -- if a pop-up is open, let it handle clicks first
    if PopWindow and PopWindow.IsOpen and PopWindow.IsOpen() then
        if PopWindow.MousePressed and PopWindow.MousePressed(x, y, button) then return end
    end
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

        -- inventory / currency quick interactions (top-right)
        if ButtonsInventory and ButtonsInventory.Inventory and PointInButton(ButtonsInventory.Inventory, x, y) then
            local invButtons = {}
            for _, s in ipairs(Skins) do
                if SaveData.ownedSkins and SaveData.ownedSkins[s.id] then
                    table.insert(invButtons, { text = "Equip: "..s.name, onClick = function()
                        if CurrentAccount then
                            SaveData.equippedSkin = s.id
                            SaveCurrentAccount()
                            PopWindow.ShowMessage("Equipped", s.name .. " equipped.")
                        else
                            PopWindow.ShowMessage("Not signed in", "Sign in or create an account to equip skins and save progress.")
                        end
                    end })
                end
            end
            table.insert(invButtons, { text = "Close", onClick = function() PopWindow.Close() end })
            PopWindow.Show("Inventory", "Choose a skin to equip:", invButtons)
            return
        end

        -- Account button
        if ButtonsAccount and ButtonsAccount.Account and PointInButton(ButtonsAccount.Account, x, y) then
            -- show account modal
            local function ShowAccountModal()
                local fields = {
                    { label = "Username", value = (CurrentAccount or ""), masked = false, maxLength = 20 },
                    { label = "Password", value = "", masked = false, maxLength = 64 }
                }
                local function submit(flds)
                    local username = (flds[1] and flds[1].value) or ""
                    local password = (flds[2] and flds[2].value) or ""
                    local ok, msg = AccountSignIn(username, password)
                    if ok then
                        -- persist current account selection
                        SaveAccounts()
                        SaveCurrentAccount()
                        PopWindow.Close()
                        PopWindow.ShowMessage("Success", msg)
                    else
                        -- show error inline and focus appropriate field instead of closing the modal
                        PopWindow.text = "Error: " .. tostring(msg)
                        if msg == "Invalid username" then PopWindow.activeField = 1 end
                        if msg == "Incorrect password" then PopWindow.activeField = 2 end
                        PopWindow.caretTimer = 0
                        PopWindow.caretVisible = true
                    end
                end
                -- buttons vary depending on signed-in state
                local btns = {}
                table.insert(btns, { text = "Sign/Create", onClick = function() if PopWindow.meta and PopWindow.meta.onSubmit then PopWindow.meta.onSubmit(PopWindow.inputFields) end end })
                if CurrentAccount then
                    table.insert(btns, { text = "Sign Out", onClick = function()
                        -- confirm sign out
                        PopWindow.Show("Confirm Sign Out", "Are you sure you want to sign out?", { { text = "Yes", onClick = function() AccountSignOut(); PopWindow.Close(); PopWindow.ShowMessage("Signed Out", "You have been signed out.") end }, { text = "No", onClick = function() PopWindow.Close() end } })
                    end })
                    table.insert(btns, { text = "Delete Account", onClick = function()
                        PopWindow.Show("Confirm Delete", "Delete account and all associated data? This cannot be undone.", {
                            { text = "Delete", onClick = function()
                                if CurrentAccount and Accounts[CurrentAccount] then
                                    Accounts[CurrentAccount] = nil
                                    CurrentAccount = nil
                                    SaveAccounts()
                                    -- reset local save data
                                    SaveData.coins = 0
                                    SaveData.diamonds = 0
                                    SaveData.ownedSkins = {}
                                    SaveData.equippedSkin = 1
                                    SaveData.lastClaim = ""
                                    PopWindow.Close()
                                    PopWindow.ShowMessage("Deleted", "Account deleted and data reset.")
                                else
                                    PopWindow.ShowMessage("Error", "No account to delete.")
                                end
                            end
                            },
                            { text = "Cancel", onClick = function() PopWindow.Close() end }
                        })
                    end })
                end
                table.insert(btns, { text = "Close", onClick = function() PopWindow.Close() end })
                PopWindow.Open("Account", "Sign in or create an account (your progress is stored per-account)", btns, { inputFields = fields, onSubmit = submit, focusField = (CurrentAccount and 2 or 1) })
            end
            ShowAccountModal()
            return
        end

        if ButtonsCurrency and ButtonsCurrency.Coin and PointInButton(ButtonsCurrency.Coin, x, y) then
            GameState.active = GameState.shop
            return
        end

        if ButtonsCurrency and ButtonsCurrency.Diamond and PointInButton(ButtonsCurrency.Diamond, x, y) then
            local buttons = {
                { text = "Convert 1", onClick = function()
                    if CurrentAccount then
                        if (SaveData.diamonds or 0) >= 1 then
                            SaveData.diamonds = SaveData.diamonds - 1
                            SaveData.coins = (SaveData.coins or 0) + 100
                            SaveCurrentAccount()
                            PopWindow.ShowMessage("Converted", "Converted 1 diamond into 100 coins.")
                        else
                            PopWindow.ShowMessage("Insufficient diamonds", "You don't have enough diamonds.")
                        end
                    else
                        PopWindow.ShowMessage("Not signed in", "Sign in or create an account to convert diamonds and save progress.")
                    end
                end },
                { text = "Convert All", onClick = function()
                    local d = SaveData.diamonds or 0
                    if d <= 0 then
                        PopWindow.ShowMessage("No diamonds", "You don't have any diamonds.")
                    else
                        if CurrentAccount then
                            SaveData.coins = (SaveData.coins or 0) + d * 100
                            SaveData.diamonds = 0
                            SaveCurrentAccount()
                            PopWindow.ShowMessage("Converted", "Converted "..d.." diamonds into "..(d*100) .." coins.")
                        else
                            PopWindow.ShowMessage("Not signed in", "Sign in or create an account to convert diamonds and save progress.")
                        end
                    end
                end },
                { text = "Close", onClick = function() PopWindow.Close() end }
            }
            PopWindow.Show("Convert Diamonds", "Exchange diamonds for coins (1 diamond = 100 coins)", buttons)
            return
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
        local bs5 = ButtonsSettings.ThemeOption
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
            -- Cycle Speed Options
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
                bs4.text = "Arrow"            elseif bs4.text == "Arrow" then
                bs4.text = "Touch"            else
                bs4.text = "Click"
            end
        elseif PointInButton(bs5, x, y) then
            -- Theme switch (toggle)
            if bs5.text == "White" then
                bs5.text = "Black"
            else
                bs5.text = "White"
            end
            ApplyThemeToAllButtons()
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
            return
        end

        -- skin entry clicks: show buy/equip in popup
        for i, s in ipairs(Skins) do
            local k = 'skin' .. i
            local btn = ButtonsShop[k]
            if btn and PointInButton(btn, x, y) then
                -- owned? equip : buy
                local buttons = {}
                if SaveData.ownedSkins and SaveData.ownedSkins[s.id] then
                    table.insert(buttons, { text = "Equip", onClick = function()
                        if CurrentAccount then
                            SaveData.equippedSkin = s.id
                            SaveCurrentAccount()
                            PopWindow.ShowMessage("Equipped", s.name .. " is now equipped.")
                        else
                            PopWindow.ShowMessage("Not signed in", "Sign in or create an account to equip skins and save progress.")
                        end
                    end })
                else
                    table.insert(buttons, { text = "Buy", onClick = function()
                        if not CurrentAccount then
                            PopWindow.ShowMessage("Not signed in", "Sign in or create an account to purchase skins.")
                        else
                            if (SaveData.coins or 0) >= s.price then
                                SaveData.coins = SaveData.coins - s.price
                                SaveData.ownedSkins[s.id] = true
                                SaveCurrentAccount()
                                PopWindow.ShowMessage("Purchased", "You bought " .. s.name)
                            else
                                PopWindow.ShowMessage("Not enough coins", "You need " .. (s.price - (SaveData.coins or 0)) .. " more coins.")
                            end
                        end
                    end })
                end
                table.insert(buttons, { text = "Close", onClick = function() PopWindow.Close() end })
                PopWindow.Show(s.name, "Price: " .. tostring(s.price) .. " coins", buttons)
                return
            end
        end
    elseif GameState.active == GameState.changelog then
        -- allow popwindow to handle clicks first
        if PopWindow and PopWindow.IsOpen and PopWindow.IsOpen() then
            if PopWindow.MousePressed and PopWindow.MousePressed(x, y, button) then return end
        end

        local exitBtn = ButtonsChangelog.Exit
        if exitBtn then
            exitBtn.y = WindowHeight - SB - (exitBtn.height / 2)
        end
        if PointInButton(exitBtn, x, y) then
            GameState.active = GameState.menu
            return
        end

        -- detect scrollbar thumb click for dragging
        do
            local startY = SB
            local itemHeight = SB / 2
            local gap = 12
            local contentTop = startY
            local contentBottom = startY + (#ChangelogEntries) * (itemHeight + gap)
            local viewTop = SB
            local viewBottom = WindowHeight - SB
            local viewHeight = viewBottom - viewTop
            local contentHeight = contentBottom - contentTop
            if contentHeight > viewHeight then
                local barX = SB + (SB * 6) + 8
                local barY = viewTop
                local barW = 8
                local barH = viewHeight
                local thumbH = math.max(24, (viewHeight / contentHeight) * barH)
                local scrollRatio = -ChangelogScroll / (contentHeight - viewHeight)
                local thumbY = barY + scrollRatio * (barH - thumbH)
                if x >= barX and x <= barX + barW and y >= thumbY and y <= thumbY + thumbH then
                    ChangelogScrollbarDrag = { startMouseY = y, startThumbY = thumbY, startScroll = ChangelogScroll, barY = barY, barH = barH, thumbH = thumbH, barX = barX, barW = barW }
                    return
                end
                -- clicking the track jumps the thumb to that position
                if x >= barX and x <= barX + barW and y >= barY and y <= barY + barH then
                    local t = (y - barY) / (barH - thumbH)
                    t = math.max(0, math.min(1, t))
                    ChangelogScroll = -t * (contentHeight - viewHeight)
                    return
                end
            end
        end

        -- check list entries and open modal via PopWindow
        for i = 1, #ChangelogEntries do
            local k = "changelog" .. tostring(i)
            local btn = ButtonsChangelog[k]
            if btn and PointInButton(btn, x, y, ChangelogScroll) then
                -- show entry details in pop window
                local e = ChangelogEntries[i]
                PopWindow.Show(e.title, e.details, {{ text = "Close", onClick = function() PopWindow.Close() end }})
                return
            end
        end

    elseif GameState.active == GameState.shop then
        local exitBtn = ButtonsShop.Exit
        if PointInButton(exitBtn, x, y) then
            GameState.active = GameState.menu
            return
        end

        -- Claim Daily (top button)
        if ButtonsShop.Claim and PointInButton(ButtonsShop.Claim, x, y) then
            local today = os.date("%Y-%m-%d")
            if (SaveData.lastClaim or "") ~= today then
                if CurrentAccount then
                    SaveData.diamonds = (SaveData.diamonds or 0) + 1
                    SaveData.lastClaim = today
                    SaveCurrentAccount()
                    PopWindow.ShowMessage("Claimed", "You received 1 diamond!")
                else
                    PopWindow.ShowMessage("Not signed in", "Sign in or create an account to claim daily diamonds.")
                end
            else
                PopWindow.ShowMessage("Already claimed", "Daily diamond already claimed today.")
            end
            return
        end

        -- detect shop scrollbar thumb click
        do
            local startY = SB
            local itemHeight = SB / 2
            local gap = 12
            local contentTop = startY
            local contentBottom = startY + (#Skins) * (itemHeight + gap)
            local viewTop = SB
            local viewBottom = WindowHeight - SB
            local viewHeight = viewBottom - viewTop
            local contentHeight = contentBottom - contentTop
            if contentHeight > viewHeight then
                local barX = SB + (SB * 6) + 8
                local barY = viewTop
                local barW = 8
                local barH = viewHeight
                local thumbH = math.max(24, (viewHeight / contentHeight) * barH)
                local scrollRatio = -ShopScroll / (contentHeight - viewHeight)
                local thumbY = barY + scrollRatio * (barH - thumbH)
                if x >= barX and x <= barX + barW and y >= thumbY and y <= thumbY + thumbH then
                    ShopScrollbarDrag = { startMouseY = y, startThumbY = thumbY, startScroll = ShopScroll, barY = barY, barH = barH, thumbH = thumbH, barX = barX, barW = barW }
                    return
                end
                -- also detect touching the scrollbar track to jump the thumb
                if x >= barX and x <= barX + barW and y >= barY and y <= barY + barH then
                    local t = (y - barY) / (barH - thumbH)
                    t = math.max(0, math.min(1, t))
                    ShopScroll = -t * (contentHeight - viewHeight)
                    return
                end
            end
        end

        -- skin entry clicks: show buy/equip in popup
        for i, s in ipairs(Skins) do
            local k = 'skin' .. i
            local btn = ButtonsShop[k]
            if btn and PointInButton(btn, x, y, ShopScroll) then
                -- owned? equip : buy
                local buttons = {}
                if SaveData.ownedSkins and SaveData.ownedSkins[s.id] then
                    table.insert(buttons, { text = "Equip", onClick = function()
                        if CurrentAccount then
                            SaveData.equippedSkin = s.id
                            SaveCurrentAccount()
                            PopWindow.ShowMessage("Equipped", s.name .. " is now equipped.")
                        else
                            PopWindow.ShowMessage("Not signed in", "Sign in or create an account to equip skins and save progress.")
                        end
                    end })
                else
                    table.insert(buttons, { text = "Buy", onClick = function()
                        if not CurrentAccount then
                            PopWindow.ShowMessage("Not signed in", "Sign in or create an account to purchase skins.")
                        else
                            if (SaveData.coins or 0) >= s.price then
                                SaveData.coins = SaveData.coins - s.price
                                SaveData.ownedSkins[s.id] = true
                                SaveCurrentAccount()
                                PopWindow.ShowMessage("Purchased", "You bought " .. s.name)
                            else
                                PopWindow.ShowMessage("Not enough coins", "You need " .. (s.price - (SaveData.coins or 0)) .. " more coins.")
                            end
                        end
                    end })
                end
                table.insert(buttons, { text = "Close", onClick = function() PopWindow.Close() end })
                -- set preview meta then show pop window (pass old 3-arg API)
                PopWindow.Open(s.name, "Price: " .. tostring(s.price) .. " coins", buttons, { previewSkin = s.id })
                return
            end
        end
        -- clicking on the scrollbar track for changelog/shop is handled above (jumping), dragging handled in mousemoved/touchmoved
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

function love.mousemoved(x, y, dx, dy, istouch)
    -- Handle dragging of scrollbar thumbs with mouse (desktop)
    if ChangelogScrollbarDrag then
        local dd = y - ChangelogScrollbarDrag.startMouseY
        local newThumb = ChangelogScrollbarDrag.startThumbY + dd
        local barY = ChangelogScrollbarDrag.barY
        local barH = ChangelogScrollbarDrag.barH
        local thumbH = ChangelogScrollbarDrag.thumbH
        if newThumb < barY then newThumb = barY end
        if newThumb > barY + barH - thumbH then newThumb = barY + barH - thumbH end
        local contentTop = SB
        local itemHeight = SB / 2
        local gap = 12
        local contentHeight = (#ChangelogEntries) * (itemHeight + gap)
        local viewTop = SB
        local viewBottom = WindowHeight - SB
        local viewHeight = viewBottom - viewTop
        local ratio = (newThumb - barY) / (barH - thumbH)
        ChangelogScroll = -ratio * (contentHeight - viewHeight)
        return
    end
    if ShopScrollbarDrag then
        local dd = y - ShopScrollbarDrag.startMouseY
        local newThumb = ShopScrollbarDrag.startThumbY + dd
        local barY = ShopScrollbarDrag.barY
        local barH = ShopScrollbarDrag.barH
        local thumbH = ShopScrollbarDrag.thumbH
        if newThumb < barY then newThumb = barY end
        if newThumb > barY + barH - thumbH then newThumb = barY + barH - thumbH end
        local contentTop = SB
        local itemHeight = SB / 2
        local gap = 12
        local contentHeight = (#Skins) * (itemHeight + gap)
        local viewTop = SB
        local viewBottom = WindowHeight - SB
        local viewHeight = viewBottom - viewTop
        local ratio = (newThumb - barY) / (barH - thumbH)
        ShopScroll = -ratio * (contentHeight - viewHeight)
        return
    end
end

function love.mousereleased(x, y, button)
    ChangelogScrollbarDrag = nil
    ShopScrollbarDrag = nil
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    -- Convert to game/world coordinates
    local wx, wy = ScreenToWorld(x, y)

    -- Let popwindow handle touches first (if open)
    if PopWindow and PopWindow.IsOpen and PopWindow.IsOpen() then
        if PopWindow.MousePressed and PopWindow.MousePressed(wx, wy, 1) then return end
    end

    -- Changelog: start drag for list scrolling if touch starts in view area
    if GameState.active == GameState.changelog then
        local viewTop = SB
        local viewBottom = WindowHeight - SB
        local viewLeft = SB
        local viewRight = SB + (SB * 6) + 24
        if x >= viewLeft and x <= viewRight and y >= viewTop and y <= viewBottom then
            ChangelogTouch = { id = id, startY = wy, startScroll = ChangelogScroll }
            return
        end
    end

    -- Shop: start drag for list scrolling or detect touch on scroll track
    if GameState.active == GameState.shop then
        local viewTop = SB
        local viewBottom = WindowHeight - SB
        local viewLeft = SB
        local viewRight = SB + (SB * 6) + 24
        if x >= viewLeft and x <= viewRight and y >= viewTop and y <= viewBottom then
            ShopTouch = { id = id, startY = wy, startScroll = ShopScroll }
            return
        end
    end

    -- In play mode, support touch-to-jump if controls are set to Touch
    if GameState.active == GameState.play then
        local bs4 = ButtonsSettings.ControlOption
        if bs4 and bs4.text == "Touch" then
            HandleJumpInput("touch")
            return
        end
    end

    -- Default: fallback to mouse click handler so buttons remain consistent
    if love.mousepressed then love.mousepressed(x, y, 1) end
end

function love.keypressed(key)
    if key == "escape" then
        if PopWindow and PopWindow.IsOpen and PopWindow.IsOpen() then
            PopWindow.Close()
            return
        else
            love.event.quit()
        end
    end

    -- let popwindow handle keypress first (enter/backspace/tab for inputs)
    if PopWindow and PopWindow.IsOpen and PopWindow.IsOpen() and PopWindow.KeyPressed and PopWindow.KeyPressed(key) then
        return
    end

    if key == "return" then
        GameState.active = GameState.menu
    end
    if GameState.active == GameState.play then
        HandleJumpInput("key", key)
    end
end

-- forward text input to popwindow when active (for typing into fields)
function love.textinput(t)
    if PopWindow and PopWindow.IsOpen and PopWindow.IsOpen() and PopWindow.TextInput then
        if PopWindow.TextInput(t) then return end
    end
end

function love.wheelmoved(x, y)
    -- if a pop-up is open and it handles wheel events, forward to it first
    if PopWindow and PopWindow.IsOpen and PopWindow.IsOpen() and PopWindow.WheelMoved then
        PopWindow.WheelMoved(x, y)
        return
    end

    -- clear drags on mouse move if needed
    if ChangelogScrollbarDrag or ShopScrollbarDrag then
        -- handled in mousemoved
    end

    if GameState.active == GameState.changelog then
        -- compute content and view sizes
        local startY = SB
        local itemHeight = SB / 2
        local gap = 12
        local contentHeight = (#ChangelogEntries) * (itemHeight + gap)
        local viewTop = SB
        local viewBottom = WindowHeight - SB
        local viewHeight = viewBottom - viewTop
        local minScroll = math.min(0, viewHeight - contentHeight)
        local scrollAmount = 30
        ChangelogScroll = math.max(minScroll, math.min(0, ChangelogScroll + y * scrollAmount))
        return
    end

    if GameState.active == GameState.shop then
        local startY = SB
        local itemHeight = SB / 2
        local gap = 12
        local contentHeight = (#Skins) * (itemHeight + gap)
        local viewTop = SB
        local viewBottom = WindowHeight - SB
        local viewHeight = viewBottom - viewTop
        local minScroll = math.min(0, viewHeight - contentHeight)
        local scrollAmount = 30
        ShopScroll = math.max(minScroll, math.min(0, ShopScroll + y * scrollAmount))
        return
    end
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    -- handle changelog drag scrolling
    if GameState.active == GameState.changelog and ChangelogTouch and ChangelogTouch.id == id then
        local _, wy = ScreenToWorld(x, y)
        local dy = wy - ChangelogTouch.startY
        local itemHeight = SB / 2
        local gap = 12
        local contentHeight = (#ChangelogEntries) * (itemHeight + gap)
        local viewTop = SB
        local viewBottom = WindowHeight - SB
        local viewHeight = viewBottom - viewTop
        local minScroll = math.min(0, viewHeight - contentHeight)
        ChangelogScroll = math.max(minScroll, math.min(0, ChangelogTouch.startScroll + dy))
        return
    end

    -- handle shop drag scrolling
    if GameState.active == GameState.shop and ShopTouch and ShopTouch.id == id then
        local _, wy = ScreenToWorld(x, y)
        local dy = wy - ShopTouch.startY
        local itemHeight = SB / 2
        local gap = 12
        local contentHeight = (#Skins) * (itemHeight + gap)
        local viewTop = SB
        local viewBottom = WindowHeight - SB
        local viewHeight = viewBottom - viewTop
        local minScroll = math.min(0, viewHeight - contentHeight)
        ShopScroll = math.max(minScroll, math.min(0, ShopTouch.startScroll + dy))
        return
    end

    -- forward to popup touch moved if available
    if PopWindow and PopWindow.IsOpen and PopWindow.IsOpen() and PopWindow.TouchMoved then
        PopWindow.TouchMoved(id, x, y, dx, dy, pressure)
        return
    end

    -- if user is dragging a scrollbar via touch, adjust that too
    if ChangelogScrollbarDrag then
        local _, wy = ScreenToWorld(x, y)
        local dd = wy - ChangelogScrollbarDrag.startMouseY
        local newThumb = ChangelogScrollbarDrag.startThumbY + dd
        local barY = ChangelogScrollbarDrag.barY
        local barH = ChangelogScrollbarDrag.barH
        local thumbH = ChangelogScrollbarDrag.thumbH
        if newThumb < barY then newThumb = barY end
        if newThumb > barY + barH - thumbH then newThumb = barY + barH - thumbH end
        local contentTop = SB
        local itemHeight = SB / 2
        local gap = 12
        local contentHeight = (#ChangelogEntries) * (itemHeight + gap)
        local viewTop = SB
        local viewBottom = WindowHeight - SB
        local viewHeight = viewBottom - viewTop
        local ratio = (newThumb - barY) / (barH - thumbH)
        ChangelogScroll = -ratio * (contentHeight - viewHeight)
        return
    end

    if ShopScrollbarDrag then
        local _, wy = ScreenToWorld(x, y)
        local dd = wy - ShopScrollbarDrag.startMouseY
        local newThumb = ShopScrollbarDrag.startThumbY + dd
        local barY = ShopScrollbarDrag.barY
        local barH = ShopScrollbarDrag.barH
        local thumbH = ShopScrollbarDrag.thumbH
        if newThumb < barY then newThumb = barY end
        if newThumb > barY + barH - thumbH then newThumb = barY + barH - thumbH end
        local contentTop = SB
        local itemHeight = SB / 2
        local gap = 12
        local contentHeight = (#Skins) * (itemHeight + gap)
        local viewTop = SB
        local viewBottom = WindowHeight - SB
        local viewHeight = viewBottom - viewTop
        local ratio = (newThumb - barY) / (barH - thumbH)
        ShopScroll = -ratio * (contentHeight - viewHeight)
        return
    end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    if ChangelogTouch and ChangelogTouch.id == id then
        ChangelogTouch = nil
        return
    end
    if ShopTouch and ShopTouch.id == id then
        ShopTouch = nil
        return
    end

    -- stop scrollbar drags on touch release
    ChangelogScrollbarDrag = nil
    ShopScrollbarDrag = nil

    if PopWindow and PopWindow.IsOpen and PopWindow.IsOpen() and PopWindow.TouchReleased then
        PopWindow.TouchReleased(id, x, y, dx, dy, pressure)
    end
end

function love.resize(w, h)
    -- keep global window constants in sync and reposition mobile UI
    WindowWidth = w
    WindowHeight = h
    -- update scaling to keep virtual resolution fit
    if UpdateScalingFunc then UpdateScalingFunc() end
    if ButtonPause then ButtonPause.x = BaseWidth - 110 end
    if ButtonsMobile and ButtonsMobile.Jump then
        ButtonsMobile.Jump.x = BaseWidth - 110
        ButtonsMobile.Jump.y = BaseHeight - 110
    end    -- keep currency/inventory anchored to the top-right
    if ButtonsCurrency and ButtonsCurrency.Coin then
        ButtonsCurrency.Coin.x = BaseWidth - 120
        ButtonsCurrency.Coin.y = 10
    end
    if ButtonsCurrency and ButtonsCurrency.Diamond then
        ButtonsCurrency.Diamond.x = BaseWidth - 240
        ButtonsCurrency.Diamond.y = 10
    end
    if ButtonsInventory and ButtonsInventory.Inventory then
        ButtonsInventory.Inventory.x = BaseWidth - 320
        ButtonsInventory.Inventory.y = 10
    end
    if ButtonsAccount and ButtonsAccount.Account then
        ButtonsAccount.Account.x = BaseWidth - 420
        ButtonsAccount.Account.y = 10
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
        -- Update mobile jump button when on mobile
        if IsMobile and ButtonsMobile and ButtonsMobile.Jump then
            UpdateButton(ButtonsMobile.Jump, dt)
        end
    end
    Bg.Update(dt)
    love.graphics.setColor(1, 1, 1)

    -- Update popwindow first (so it can animate even if not on changelog)
    if PopWindow then PopWindow.Update(dt) end
    
    -- Update button hover states for all relevant states
    if GameState.active == GameState.menu then
        for _, btn in pairs(Buttons) do
            UpdateButton(btn, dt)
        end
        -- currency / inventory widgets
        if ButtonsCurrency then
            for _, btn in pairs(ButtonsCurrency) do
                UpdateButton(btn, dt)
            end
        end
        if ButtonsInventory then
            for _, btn in pairs(ButtonsInventory) do
                UpdateButton(btn, dt)
            end
        end
        -- account button
        if ButtonsAccount and ButtonsAccount.Account then
            UpdateButton(ButtonsAccount.Account, dt)
        end
    elseif GameState.active == GameState.shop then
        -- ensure static claim button + exit update
        if ButtonsShop.Claim then UpdateButton(ButtonsShop.Claim, dt) end
        if ButtonsShop.Exit then UpdateButton(ButtonsShop.Exit, dt) end
        -- update scrollable shop region
        for i, s in ipairs(Skins) do
            local btn = ButtonsShop['skin' .. i]
            if btn then UpdateButton(btn, dt, ShopScroll) end
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
        -- claim button is static
        if ButtonsShop.Claim then UpdateButton(ButtonsShop.Claim, dt) end
        -- Update scrollable shop buttons (pass ShopScroll for hit/hover)
        for i, s in ipairs(Skins) do
            local btn = ButtonsShop['skin' .. i]
            if btn then UpdateButton(btn, dt, ShopScroll) end
        end
        if ButtonsShop.Exit then UpdateButton(ButtonsShop.Exit, dt) end
        -- reflect dynamic state (owned/equipped) in labels
        for i, s in ipairs(Skins) do
            local btn = ButtonsShop['skin' .. i]
            if btn then
                local label = s.name
                if SaveData.ownedSkins and SaveData.ownedSkins[s.id] then
                    if SaveData.equippedSkin == s.id then label = label .. " (Equipped)" else label = label .. " (Owned)" end
                else
                    label = label .. " - " .. tostring(s.price) .. "c"
                end
                btn.text = label
            end
        end
        -- update claim button label
        if ButtonsShop.Claim then
            local today = os.date("%Y-%m-%d")
            if (SaveData.lastClaim or "") == today then
                ButtonsShop.Claim.text = "Claimed Today"
            else
                ButtonsShop.Claim.text = "Claim Daily"
            end
        end    elseif GameState.active == GameState.changelog then
        -- update list entries with scroll offset; Exit button remains static
        for i = 1, #ChangelogEntries do
            local k = "changelog" .. tostring(i)
            local btn = ButtonsChangelog[k]
            if btn then UpdateButton(btn, dt, ChangelogScroll) end
        end
        if ButtonsChangelog.Exit then UpdateButton(ButtonsChangelog.Exit, dt) end
        -- update pop window if active
        if PopWindow then PopWindow.Update(dt) end
        -- update any scrollbar drags state (no-op here but kept for symmetry)
        if ChangelogScrollbarDrag then
            -- no-op; handled in mousemoved/touchmoved
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
    -- apply virtual resolution scaling and center
    love.graphics.push()
    love.graphics.translate(OffsetX, OffsetY)
    love.graphics.scale(Scale, Scale)

    if GameState.active == GameState.menu then
        love.graphics.setFont(Font1)
        Bg.Draw()
        for _, btn in pairs(Buttons) do
            DrawButton(btn)
        end

        -- Currency & inventory display (top-right)
        love.graphics.setFont(Font2)
        if ButtonsInventory.Inventory then
            DrawButton(ButtonsInventory.Inventory)
            -- small swatch showing equipped skin
            local eq = SaveData.equippedSkin or 1
            if Skins and Skins[eq] then
                local sw = 24
                local bx = ButtonsInventory.Inventory.x + ButtonsInventory.Inventory.width - sw - 8
                local by = ButtonsInventory.Inventory.y + 3
                DrawSwatch(bx, by, sw, sw, Skins[eq].color)
            end
        end

        if ButtonsCurrency and ButtonsCurrency.Diamond then
            local b = ButtonsCurrency.Diamond
            b.text = "D = " .. tostring(SaveData.diamonds or 0)
            DrawButton(b)
        end
        -- Coins (right)
        if ButtonsCurrency and ButtonsCurrency.Coin then
            local b = ButtonsCurrency.Coin
            b.text = "C = " .. tostring(SaveData.coins or 0)
            DrawButton(b)
        end
        -- Account button (top-left of the currency widgets)
        if ButtonsAccount and ButtonsAccount.Account then
            DrawButton(ButtonsAccount.Account)
            -- (Signed-in display removed by request)
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
        -- player (apply equipped skin color if available)
        local skin = Skins[(SaveData and SaveData.equippedSkin) or 1]
        if skin and skin.color then love.graphics.setColor(skin.color) end
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
        love.graphics.setColor(1,1,1)
        -- UI
        DrawButton(ButtonPause)
        -- mobile jump button
        if IsMobile and ButtonsMobile and ButtonsMobile.Jump then
            DrawButton(ButtonsMobile.Jump)
        end
        love.graphics.setColor(0,1,0)
        love.graphics.print("Coins: " .. TotalCoinsCollected, 10, 10)
        love.graphics.print("Level: " .. (CurrentLevelID or "?"), 10, 30)
        love.graphics.print("Theme: " .. (CurrentLevel and CurrentLevel.theme or "default"), 10, 50)
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
        -- Claim button (fixed)
        if ButtonsShop.Claim then UpdateButton(ButtonsShop.Claim, 0) DrawButton(ButtonsShop.Claim) end
        -- draw list entries with scissor clipping (ShopScroll)
        do
            local viewTop = SB
            local viewBottom = WindowHeight - SB
            local viewHeight = viewBottom - viewTop
            local scissorX = SB
            local scissorY = viewTop
            local scissorW = (SB * 6) + 24
            local scissorH = viewHeight
            love.graphics.setScissor(scissorX, scissorY, scissorW, scissorH)
            for i, s in ipairs(Skins) do
                local btn = ButtonsShop['skin' .. i]
                if btn then
                    -- swatch
                    local sw = 36
                    DrawSwatch(btn.x + 8, btn.y + 8 + btn.offset + ShopScroll, sw, btn.height - 16, s.color)
                    DrawButton(btn, ShopScroll)
                end
            end
            love.graphics.setScissor()
        end
        if ButtonsShop.Exit then DrawButton(ButtonsShop.Exit) end

        -- draw shop scrollbar if needed
        do
            local startY = SB
            local itemHeight = SB / 2
            local gap = 12
            local contentTop = startY
            local contentBottom = startY + (#Skins) * (itemHeight + gap)
            local viewTop = SB
            local viewBottom = WindowHeight - SB
            local viewHeight = viewBottom - viewTop
            local contentHeight = contentBottom - contentTop
            if contentHeight > viewHeight then
                local barX = SB + (SB * 6) + 8
                local barY = viewTop
                local barW = 8
                local barH = viewHeight
                local thumbH = math.max(24, (viewHeight / contentHeight) * barH)
                local scrollRatio = -ShopScroll / (contentHeight - viewHeight)
                local thumbY = barY + scrollRatio * (barH - thumbH)
                DrawScrollbar(barX, barY, barW, barH, thumbY, thumbH)
            end
        end
    elseif GameState.active == GameState.changelog then
        love.graphics.setFont(Font1)
        Bg.Draw()
        -- draw list entries (with scroll offset)
        do
            local viewTop = SB/2
            local viewBottom = WindowHeight - SB/2
            local viewHeight = viewBottom - viewTop
            local scissorX = 0
            local scissorY = viewTop 
            local scissorW = (SB * 10) + 24
            local scissorH = viewHeight
            love.graphics.setScissor(scissorX, scissorY, scissorW, scissorH)
            for i = 1, #ChangelogEntries do
                local k = "changelog" .. tostring(i)
                local btn = ButtonsChangelog[k]
                if btn then DrawButton(btn, ChangelogScroll) end
            end
            love.graphics.setScissor()
        end

        if ButtonsChangelog.Exit then
            -- Keep exit button fixed at bottom of the view
            ButtonsChangelog.Exit.y = WindowHeight - SB - (ButtonsChangelog.Exit.height / 2)
            DrawButton(ButtonsChangelog.Exit)
        end

        -- draw scrollbar if needed
        do
            local startY = SB
            local itemHeight = SB / 2
            local gap = 12
            local contentTop = startY
            local contentBottom = startY + (#ChangelogEntries) * (itemHeight + gap)
            local viewTop = SB
            local viewBottom = WindowHeight - SB
            local viewHeight = viewBottom - viewTop
            local contentHeight = contentBottom - contentTop
            if contentHeight > viewHeight then
                local barX = SB + (SB * 6) + 8
                local barY = viewTop
                local barW = 8
                local barH = viewHeight
                local thumbH = math.max(24, (viewHeight / contentHeight) * barH)
                local scrollRatio = -ChangelogScroll / (contentHeight - viewHeight)
                local thumbY = barY + scrollRatio * (barH - thumbH)
                DrawScrollbar(barX, barY, barW, barH, thumbY, thumbH)
            end
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
    -- draw popwindow overlay on top of everything if open
    if PopWindow and PopWindow.IsOpen and PopWindow.IsOpen() then PopWindow.Draw() end
    love.graphics.pop()
end
---------------------------------------------------------
-- END
---------------------------------------------------------