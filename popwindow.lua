

local PopWindow = {}

PopWindow.active = false
PopWindow.title = ""
PopWindow.text = ""
PopWindow.buttons = {} -- internal button tables compatible with AddHoverDefaults / DrawButton
-- optional input fields (meta-driven)
PopWindow.inputFields = nil
PopWindow.activeField = nil
PopWindow.caretTimer = 0
PopWindow.caretVisible = true

-- modal geometry
PopWindow.width = 560
PopWindow.height = 300

function PopWindow.Open(title, text, btnSpecs, meta)
    PopWindow.title = title or ""
    PopWindow.text = text or ""
    PopWindow.buttons = {}
    PopWindow.meta = meta or nil
    PopWindow.width = math.min(560, WINDOW_WIDTH - 64)
    PopWindow.height = 220

    local btns = btnSpecs or {{ text = "Close", onClick = function() PopWindow.Close() end }}

    -- Adjust modal height so buttons and input fields fit.
    local btnCount = #btns
    local btnW, btnH, gap = 220, 36, 16
    local availW = math.max(1, PopWindow.width - 40) -- for padding
    local totalW = btnCount * btnW + math.max(0, (btnCount - 1)) * gap
    local rows = math.max(1, math.ceil(totalW / availW))
    local colsPerRow = math.ceil(btnCount / rows)

    local inputCount = (meta and meta.inputFields) and #meta.inputFields or 0
    local inputH = 40
    local inputArea = inputCount * (inputH + 12)

    local baseMin = PopWindow.height
    local needed = baseMin + inputArea + rows * (btnH + 12) + 20 -- extra padding
    if PopWindow.height < needed then PopWindow.height = needed end

    -- Buttons: layout into rows so they wrap nicely
    local buttonsStartY = WINDOW_HEIGHT/2 + PopWindow.height/2 - 56 - ((rows - 1) * (btnH + 12) / 2)
    for i, b in ipairs(btns) do
        local row = math.floor((i - 1) / colsPerRow) + 1
        local col = ((i - 1) % colsPerRow) + 1
        local rowCount = (row == rows) and (btnCount - colsPerRow * (rows - 1)) or colsPerRow
        local totalWRow = rowCount * btnW + (rowCount - 1) * gap
        local startXRow = (WINDOW_WIDTH - totalWRow) / 2
        local x = startXRow + (col - 1) * (btnW + gap)
        local y = buttonsStartY + (row - 1) * (btnH + 12)
        local tb = { x = b.x or x, y = b.y or y, width = b.width or btnW, height = b.height or btnH, text = b.text or "Btn", onClick = b.onClick, lineWidth = b.lineWidth or 3 }
        table.insert(PopWindow.buttons, tb)
    end

    -- apply hover defaults to our generated buttons so they animate like other buttons
    AddHoverDefaults(PopWindow.buttons)

    -- start opening animation
    PopWindow.anim = { t = 0, duration = 0.18, state = "opening" }
    PopWindow.active = true

    -- internal scroll for long text (reset on open)
    PopWindow.textScroll = 0

    -- input fields (copy from meta if provided)
    PopWindow.inputFields = nil
    PopWindow.activeField = nil
    PopWindow.caretTimer = 0
    PopWindow.caretVisible = true
    if PopWindow.meta and PopWindow.meta.inputFields then
        PopWindow.inputFields = {}
        for i, f in ipairs(PopWindow.meta.inputFields) do
            local copy = { label = f.label or "", value = f.value or "", masked = f.masked or false, maxLength = f.maxLength or 128 }
            table.insert(PopWindow.inputFields, copy)
        end
        -- focus field from meta if provided, otherwise first input by default
        if #PopWindow.inputFields > 0 then
            local focus = (PopWindow.meta and PopWindow.meta.focusField) or 1
            if type(focus) ~= "number" or focus < 1 or focus > #PopWindow.inputFields then
                focus = 1
            end
            PopWindow.activeField = focus
        end
    end
end

function PopWindow.Close()
    -- start closing animation if open
    if PopWindow.active and PopWindow.anim and PopWindow.anim.state == "opening" then
        PopWindow.anim.state = "closing"
        PopWindow.anim.t = 0
    else
        PopWindow.active = false
        PopWindow.title = ""
        PopWindow.text = ""
        PopWindow.buttons = {}
        PopWindow.anim = nil
        PopWindow.meta = nil
        PopWindow.textScroll = nil
        PopWindow.inputFields = nil
        PopWindow.activeField = nil
        PopWindow.caretTimer = 0
        PopWindow.caretVisible = true
    end
end

function PopWindow.Show(title, text, buttons, meta)
    PopWindow.Open(title, text, buttons, meta)
end

function PopWindow.ShowMessage(title, text)
    PopWindow.Show(title, text, {{ text = "OK", onClick = function() PopWindow.Close() end }})
end

-- Show a daily reward popup that details the streak and rewards and allows claiming
function PopWindow.ShowDailyRewardPopup(streak, coinReward, diamondReward)
    local text = ("Streak: Day %d\n\nCoins: +%d\nDiamonds: +%d\n\nWould you like to claim your daily reward?"):format(streak, coinReward, diamondReward)
    local buttons = {
        { text = "Claim", onClick = function() ClaimDailyDiamonds() end },
        { text = "Close", onClick = function() PopWindow.Close() end }
    }
    PopWindow.Show("Daily Reward", text, buttons)
end

-- Check daily reward and show popup if claimable
function PopWindow.CheckDailyReward()
    local canClaim, streak, message = CheckDailyReward()
    if canClaim then
        PopWindow.ShowDailyRewardPopup(streak, 50 + (streak * 10), 1 + math.floor(streak / 3))
    end
end

-- Confirmation helper popup
function PopWindow.ShowConfirm(title, text, onConfirm)
    local buttons = {
        { text = "Confirm", onClick = function() pcall(onConfirm) PopWindow.Close() end },
        { text = "Cancel", onClick = function() PopWindow.Close() end }
    }
    PopWindow.Show(title, text, buttons)
end

function PopWindow.IsOpen()
    return PopWindow.active
end

function PopWindow.Update(dt)
    if not PopWindow.active and not (PopWindow.anim and PopWindow.anim.state == "closing") then return end

    -- update animation
    if PopWindow.anim then
        PopWindow.anim.t = PopWindow.anim.t + dt
        local p = math.min(1, PopWindow.anim.t / (PopWindow.anim.duration or 0.18))
        if PopWindow.anim.state == "closing" and p >= 1 then
            -- finish close
            PopWindow.active = false
            PopWindow.title = ""
            PopWindow.text = ""
            PopWindow.buttons = {}
            PopWindow.anim = nil
            return
        end
    end

    for _, btn in ipairs(PopWindow.buttons) do
        UpdateButton(btn, dt)
    end

    -- caret blink timer for input fields
    if PopWindow.inputFields and #PopWindow.inputFields > 0 then
        PopWindow.caretTimer = (PopWindow.caretTimer or 0) + dt
        if PopWindow.caretTimer >= 0.5 then
            PopWindow.caretTimer = 0
            PopWindow.caretVisible = not PopWindow.caretVisible
        end
    end
end

function PopWindow.Draw()
    -- if closed and not animating, nothing to draw
    if not PopWindow.active and not (PopWindow.anim and PopWindow.anim.state == "closing") then return end

    local progress = 1
    if PopWindow.anim then
        progress = math.min(1, PopWindow.anim.t / (PopWindow.anim.duration or 0.18))
        if PopWindow.anim.state == "closing" then progress = 1 - progress end
    end

    -- backdrop (fade in/out)
    DrawPanel(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, { color = {0,0,0,0.7 * progress}, rounding = 0 })

    -- modal box scaling (pop effect)
    local mw, mh = PopWindow.width, PopWindow.height
    local baseX = WINDOW_WIDTH/2
    local baseY = WINDOW_HEIGHT/2
    local scale = 0.9 + 0.1 * progress
    local mw2, mh2 = mw * scale, mh * scale
    local mx = baseX - mw2/2
    local my = baseY - mh2/2

    love.graphics.push()
    love.graphics.translate(baseX, baseY)
    love.graphics.scale(scale, scale)
    love.graphics.translate(-baseX, -baseY)

    DrawPanel(mx, my, mw2, mh2, { color = {0.12, 0.12, 0.12, 1}, outlineColor = nil, rounding = 8 })

    love.graphics.setColor(1,1,1)
    love.graphics.setFont(love.graphics.getFont())
    love.graphics.printf(PopWindow.title or "", mx + 20, my + 18, mw2 - 40, "left")

    -- text area with internal scroll
    local textX = mx + 20
    local textY = my + 56 + (PopWindow.textScroll or 0)
    local textW = mw2 - 40
    love.graphics.printf(PopWindow.text or "", textX, textY, textW, "left")

    -- input fields (if present in meta)
    if PopWindow.inputFields and #PopWindow.inputFields > 0 then
        local inputX = mx + 24
        local inputY = my + 56 + 100
        local inputW = mw2 - 48
        local inputH = 36
        for i, f in ipairs(PopWindow.inputFields) do
            local iy = inputY + (i - 1) * (inputH + 12)
            -- label
            love.graphics.setColor(1,1,1)
            love.graphics.print(f.label or "", inputX, iy - 18)
            -- box
            DrawPanel(inputX, iy, inputW, inputH, { color = {0.08, 0.08, 0.08, 1}, rounding = 6 })
            love.graphics.setColor(1,1,1)
            -- display value (mask if requested; always masked now)
            local raw = f.value or ""
            local disp = raw
            if f.masked then disp = string.rep("*", #raw) end
            love.graphics.print(disp, inputX + 8, iy + 8)
            -- No show/hide toggle: keep masked fields always masked
            f._toggleRect = nil
            -- caret for active field
            if PopWindow.activeField == i and PopWindow.caretVisible then
                local cx = inputX + 8 + love.graphics.getFont():getWidth(disp)
                love.graphics.rectangle("fill", cx, iy + 8, 2, 18)
            end
        end
    end

    -- preview (if provided via meta)
    if PopWindow.meta and PopWindow.meta.previewSkin then
        local sid = PopWindow.meta.previewSkin
        local skin = Skins and Skins[sid]
        if skin then
            local px = mx + mw2 - 110
            local py = my + 20
            local pw = 80
            local ph = 80
            DrawSwatch(px, py, pw, ph, skin.color)
            -- draw tinted player inside preview box if sprite is available
            if Sprites.player then
                love.graphics.setColor(skin.color)
                love.graphics.draw(Sprites.player, px + pw/2, py + ph/2, 0, (pw-8)/Sprites.player:getWidth(), (ph-8)/Sprites.player:getHeight(), Sprites.player:getWidth()/2, Sprites.player:getHeight()/2)
                love.graphics.setColor(1,1,1)
            end
        end
    end

    -- Buttons (draw normally — their positions were precomputed for default window size)
    for _, btn in ipairs(PopWindow.buttons) do
        DrawButton(btn)
    end

    love.graphics.pop()
end

function PopWindow.MousePressed(x, y, button)
    if not PopWindow.active and not (PopWindow.anim and PopWindow.anim.state == "closing") then return false end
    -- if click outside modal, close by default
    local mw, mh = PopWindow.width, PopWindow.height
    local mx = WINDOW_WIDTH/2 - mw/2
    local my = WINDOW_HEIGHT/2 - mh/2

    -- if clicked inside modal, check buttons first
    for _, btn in ipairs(PopWindow.buttons) do
        if PointInButton(btn, x, y) then
            if btn.onClick then pcall(btn.onClick) end
            return true
        end
    end

    -- if clicked inside the text area, consume but don't close
    if x >= mx + 16 and x <= mx + mw - 16 and y >= my + 48 and y <= my + mh - 64 then
        -- also check input fields for focus or toggle clicks
        if PopWindow.inputFields and #PopWindow.inputFields > 0 then
            local inputX = mx + 24
            local inputY = my + 56 + 100
            local inputW = mw - 48
            local inputH = 36
            for i, f in ipairs(PopWindow.inputFields) do
                local iy = inputY + (i - 1) * (inputH + 12)

                if x >= inputX and x <= inputX + inputW and y >= iy and y <= iy + inputH then
                    PopWindow.activeField = i
                    PopWindow.caretTimer = 0
                    PopWindow.caretVisible = true
                    return true
                end
            end
        end
        return true
    end

    -- if click outside the modal box, close by default
    if x < mx or x > mx + mw or y < my or y > my + mh then
        PopWindow.Close()
        return true
    end
    return true
end

-- Basic wheel / touch scrolling for pop window text
function PopWindow.WheelMoved(dx, dy)
    if not PopWindow.active and not (PopWindow.anim and PopWindow.anim.state == "closing") then return false end
    -- simple approximation: change textScroll by dy * 20
    local s = (PopWindow.textScroll or 0) + dy * 20
    -- basic clamping to prevent runaway scroll
    if s > 0 then s = 0 end
    if s < -1000 then s = -1000 end
    PopWindow.textScroll = s
    return true
end

function PopWindow.TextInput(text)
    if not PopWindow.active and not (PopWindow.anim and PopWindow.anim.state == "closing") then return false end
    if not PopWindow.inputFields or not PopWindow.activeField then return false end
    local f = PopWindow.inputFields[PopWindow.activeField]
    if not f then return false end
    f.value = f.value or ""
    if #f.value >= (f.maxLength or 128) then return true end
    f.value = f.value .. text
    return true
end

function PopWindow.KeyPressed(key)
    if not PopWindow.active and not (PopWindow.anim and PopWindow.anim.state == "closing") then return false end
    -- handle input-related keys
    if PopWindow.inputFields and PopWindow.activeField then
        local f = PopWindow.inputFields[PopWindow.activeField]
        if key == "backspace" then
            local len = #f.value
            if len > 0 then f.value = string.sub(f.value, 1, len - 1) end
            return true
        elseif key == "tab" then
            local n = #PopWindow.inputFields
            if n == 0 then return false end
            PopWindow.activeField = (PopWindow.activeField % n) + 1
            PopWindow.caretTimer = 0
            PopWindow.caretVisible = true
            return true
        elseif key == "up" then
            -- move focus up (wrap)
            local n = #PopWindow.inputFields
            if n == 0 then return false end
            PopWindow.activeField = ((PopWindow.activeField - 2) % n) + 1
            PopWindow.caretTimer = 0
            PopWindow.caretVisible = true
            return true
        elseif key == "down" then
            -- move focus down (wrap)
            local n = #PopWindow.inputFields
            if n == 0 then return false end
            PopWindow.activeField = (PopWindow.activeField % n) + 1
            PopWindow.caretTimer = 0
            PopWindow.caretVisible = true
            return true
        elseif key == "return" or key == "kpenter" then
            -- try submit via meta handler (preferred)
            if PopWindow.meta and PopWindow.meta.onSubmit then
                local ok, msg = pcall(PopWindow.meta.onSubmit, PopWindow.inputFields)
                -- handle success/feedback externally inside onSubmit
                return true
            else
                -- fallback: trigger first button if exists
                if PopWindow.buttons and PopWindow.buttons[1] and PopWindow.buttons[1].onClick then
                    pcall(PopWindow.buttons[1].onClick)
                    return true
                end
            end
        end
    end
    return false
end

function PopWindow.TouchMoved(id, x, y, dx, dy, pressure)
    if not PopWindow.active and not (PopWindow.anim and PopWindow.anim.state == "closing") then return false end
    -- use dy in pixel space (world coords handled by caller)
    local s = (PopWindow.textScroll or 0) + dy / (Scale or 1)
    if s > 0 then s = 0 end
    if s < -1000 then s = -1000 end
    PopWindow.textScroll = s
    return true
end

function PopWindow.TouchReleased(id, x, y, dx, dy, pressure)
    -- nothing special required yet
    return true
end

return PopWindow
