local helper = {}

---------------------------------------------------------
-- Add hover defaults to a button table
---------------------------------------------------------
function AddHoverDefaults(buttonTable)
    for _, btn in pairs(buttonTable) do
        btn.color = {1, 1, 1}
        btn.hoverColor = {1, 0.8, 0}
        btn.hover = false
        btn.scale = 1
        btn.offset = 0
    end
end

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

-- Add hover defaults to level buttons
for _, btn in ipairs(LevelButtons) do
    btn.color = {1, 1, 1}
    btn.hoverColor = {1, 0.8, 0}
    btn.hover = false
    btn.scale = 1
    btn.offset = 0
end

-- Add to pause button
ButtonPause.color = {1, 1, 1}
ButtonPause.hoverColor = {1, 0.8, 0}
ButtonPause.hover = false
ButtonPause.scale = 1
ButtonPause.offset = 0

---------------------------------------------------------
-- Update button hover + animation
---------------------------------------------------------
function UpdateButton(btn, dt)
    local mx, my = love.mouse.getPosition()
    -- check hover (use scaled box to match visual scale & offsets)
    local w = btn.width * btn.scale
    local h = btn.height * btn.scale
    local bx = btn.x - (w - btn.width) / 2
    local by = btn.y - (h - btn.height) / 2 + btn.offset
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
function PointInButton(btn, px, py)
    local w = btn.width * btn.scale
    local h = btn.height * btn.scale
    local bx = btn.x - (w - btn.width) / 2
    local by = btn.y - (h - btn.height) / 2 + btn.offset
    return px >= bx and px <= bx + w and py >= by and py <= by + h
end

---------------------------------------------------------
-- Draw the button with scaling + hover effect
---------------------------------------------------------
function DrawButton(btn)
    -- Apply scaling
    local w = btn.width * btn.scale
    local h = btn.height * btn.scale
    local x = btn.x - (w - btn.width) / 2
    local y = btn.y - (h - btn.height) / 2 + btn.offset

    -- Color
    if btn.hover then
        love.graphics.setColor(btn.hoverColor)
    else
        love.graphics.setColor(btn.color)
    end

    -- Outline
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", x, y, w, h, 10, 10)

    -- Text
    love.graphics.setColor(1,1,1)
    love.graphics.setFont(Font2)
    love.graphics.printf(btn.text, x, y + h/2 - 12, w, "center")
end


-- Handle jump input based on user settings
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

--Drawblock
function Drawblock()
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
        DrawTileSprite(nil, f.x, f.y, f.width, f.height, 0.2,0.2,0.2)
    end
end

return helper