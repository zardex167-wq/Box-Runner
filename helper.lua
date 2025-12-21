local helper = {}

---------------------------------------------------------
-- Add hover defaults to a button table
---------------------------------------------------------
function AddHoverDefaults(buttonTable)
    local bs5 = ButtonsSettings.ThemeOption
    for _, btn in pairs(buttonTable) do
        if bs5.text == "White" then
            btn.color = Color.white
            btn.hoverColor = Color.yellow
            btn.scale = 1
            btn.lineWidth = Linewidth.white
        elseif bs5.text == "Black" then
            btn.color = Color.black
            btn.hoverColor = Color.gray
            btn.scale = 2
            btn.lineWidth = Linewidth.black
        end
        btn.offset = 0
        btn.hover = false
        btn.textColor = Color.white
    end
end

function ApplyThemeToAllButtons()
    -- Apply to all button groups
    AddHoverDefaults(Buttons)
    AddHoverDefaults(ButtonsPause)
    AddHoverDefaults(ButtonsGameover)
    AddHoverDefaults(LevelCompleteButtons)
    AddHoverDefaults(ButtonsSettings)
    AddHoverDefaults(ButtonsShop)
    AddHoverDefaults(ButtonsAchievements)
    AddHoverDefaults(ButtonsChangelog)
    AddHoverDefaults(ButtonsCredits)
    AddHoverDefaults(ButtonsLevelSelect)
    AddHoverDefaults(LevelButtons)
    AddHoverDefaults({ButtonPause})
    AddHoverDefaults(ButtonsShop)
    AddHoverDefaults(ButtonsAccount)
    -- Mobile buttons
    AddHoverDefaults(ButtonsMobile)
    -- currency and inventory widgets
    AddHoverDefaults(ButtonsCurrency)
    AddHoverDefaults(ButtonsInventory)
end

---------------------------------------------------------
-- Coordinate helpers (convert from screen pixels to game world)
---------------------------------------------------------
function ScreenToWorld(x, y)
    local s = Scale or 1
    local ox = OffsetX or 0
    local oy = OffsetY or 0
    return (x - ox) / s, (y - oy) / s
end

---------------------------------------------------------
-- Update button hover + animation
---------------------------------------------------------
function UpdateButton(btn, dt, scrollY)
    scrollY = scrollY or 0

    -- Ensure sane defaults so missing theme application doesn't break hover math
    btn.scale = btn.scale or 1
    btn.offset = btn.offset or 0
    btn.hover = btn.hover or false
    btn.lineWidth = btn.lineWidth or 3

    -- Mobile: no hover via mouse; prefer subtle default scaling for touch targets
    if IsMobile then
        -- gently normalize scale to a touch-friendly size
        local speed = 10
        local targetScale = 1.03
        btn.hover = false
        btn.scale = btn.scale + (targetScale - btn.scale) * speed * dt
        btn.offset = btn.offset + (0 - btn.offset) * speed * dt
        return
    end

    local mx, my = love.mouse.getPosition()
    mx, my = ScreenToWorld(mx, my)
    -- check hover (use scaled box to match visual scale & offsets)
    local w = btn.width * btn.scale
    local h = btn.height * btn.scale
    local bx = btn.x - (w - btn.width) / 2
    local by = btn.y - (h - btn.height) / 2 + btn.offset + scrollY
    if mx >= bx and mx <= bx + w and my >= by and my <= by + h then
        btn.hover = true
    else
        btn.hover = false
    end

    local speed = 10

    if btn.hover then
        btn.scale = btn.scale + (1.1 - btn.scale) * speed * dt
        btn.offset = btn.offset + (-4 - btn.offset) * speed * dt
    else
        btn.scale = btn.scale + (1 - btn.scale) * speed * dt
        btn.offset = btn.offset + (0 - btn.offset) * speed * dt
    end
end

---------------------------------------------------------
-- Check if a point intersects the scaled button area
---------------------------------------------------------
function PointInButton(btn, px, py, scrollY)
    scrollY = scrollY or 0
    px, py = ScreenToWorld(px, py)
    local scale = btn.scale or 1
    local offset = btn.offset or 0
    local w = btn.width * scale
    local h = btn.height * scale
    local bx = btn.x - (w - btn.width) / 2
    local by = btn.y - (h - btn.height) / 2 + offset + scrollY

    -- Increase hit area slightly on mobile to ease tapping
    if IsMobile then
        local pad = math.max(12, math.floor(btn.width * 0.12))
        bx = bx - pad
        by = by - pad
        w = w + pad * 2
        h = h + pad * 2
    end

    return px >= bx and px <= bx + w and py >= by and py <= by + h
end

---------------------------------------------------------
-- Draw the button with scaling + hover effect
---------------------------------------------------------
function DrawButton(btn, scrollY)
    scrollY = scrollY or 0
    -- Apply scaling
    local scale = btn.scale or 1
    local offset = btn.offset or 0
    local w = btn.width * scale
    local h = btn.height * scale
    local x = btn.x - (w - btn.width) / 2
    local y = btn.y - (h - btn.height) / 2 + offset + scrollY

    -- Color (use defaults if missing)
    local col = (btn.hover and btn.hoverColor) or btn.color or Color.white
    if type(col) == "table" then
        love.graphics.setColor(col[1] or 1, col[2] or 1, col[3] or 1, col[4] or 1)
    else
        love.graphics.setColor(1,1,1)
    end

    -- Outline
    love.graphics.setLineWidth(btn.lineWidth or 3)
    love.graphics.rectangle("line", x, y, w, h, 10, 10)

    -- Text (use configured textColor or default)
    local tcol = btn.textColor or {1,1,1}
    if type(tcol) == "table" then
        love.graphics.setColor(tcol[1] or 1, tcol[2] or 1, tcol[3] or 1, tcol[4] or 1)
    else
        love.graphics.setColor(1,1,1)
    end
    love.graphics.setFont(Font2)
    love.graphics.printf(btn.text or "", x, y + h/2 - 12, w, "center")
end

-- Handle jump input based on user settings
function HandleJumpInput(inputType, inputValue)
    if not Player.isOnGround then return end
    
    local bs4 = ButtonsSettings.ControlOption
    local shouldJump = false
    
    if bs4.text == "Click" then
        -- desktop mouse click
        if (inputType == "mouse" and inputValue == 1) or (inputType == "touch") then
            shouldJump = true
        end
    elseif bs4.text == "Touch" then
        -- mobile touch or click while testing
        if inputType == "touch" or (inputType == "mouse" and inputValue == 1) then
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

---------------------------------------------------------
-- Simple themed panels / swatches / scrollbars for consistent UI
---------------------------------------------------------
function DrawPanel(x, y, w, h, opts)
    opts = opts or {}
    local col = opts.color or {0.12, 0.12, 0.12, 1}
    local outline = opts.outlineColor or nil
    local rounding = opts.rounding or 6
    -- fill
    if type(col) == "table" then
        love.graphics.setColor(col[1] or 1, col[2] or 1, col[3] or 1, col[4] or 1)
    else
        love.graphics.setColor(1,1,1,1)
    end
    love.graphics.rectangle("fill", x, y, w, h, rounding, rounding)
    -- outline
    if outline then
        local ol = outline
        if type(ol) == "table" then
            love.graphics.setColor(ol[1] or 1, ol[2] or 1, ol[3] or 1, ol[4] or 1)
        else
            love.graphics.setColor(1,1,1,1)
        end
        love.graphics.setLineWidth(opts.outlineWidth or 3)
        love.graphics.rectangle("line", x, y, w, h, rounding, rounding)
    end
end

function DrawSwatch(x, y, w, h, color)
    color = color or {1,1,1}
    DrawPanel(x, y, w, h, { color = color, outlineColor = nil, rounding = 6 })
end

function DrawScrollbar(barX, barY, barW, barH, thumbY, thumbH, opts)
    opts = opts or {}
    local trackColor = opts.trackColor or {0.18, 0.18, 0.18, 0.75}
    local thumbColor = opts.thumbColor or {0.84, 0.84, 0.84, 0.95}
    love.graphics.setColor(trackColor)
    love.graphics.rectangle("fill", barX, barY, barW, barH)
    love.graphics.setColor(thumbColor)
    love.graphics.rectangle("fill", barX, thumbY, barW, thumbH, 4, 4)
    love.graphics.setColor(1,1,1)
end

function Drawblock()

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
        DrawTileSprite(nil, f.x, f.y, f.width, f.height, 0.2,0.2,0.2)
    end
end

return helper