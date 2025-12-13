-- =============================================================================
--  MODULE: GD_Background_Config
--  This file contains configuration data, state management, and the necessary
--  helper functions (HSV, Load, Update, Draw) encapsulated in a single module.
-- =============================================================================

local M = {} -- The module table we will return

-- 1. CONFIGURATION
-- Change values here to tweak the experience easily!
M.CONFIG = {
    window = { width = WindowWidth, height = WindowHeight},
    
    colors = {
        cycleSpeed = 10,       -- How fast the rainbow effect cycles
        backgroundDarkness = 0.2, -- Multiplier for BG brightness (lower is darker)
        glowIntensity = 0.6    -- How strong the particle glow is
    },

    particles = {
        count = 60,
        minSize = 20, maxSize = 55,
        minSpeed = 20, maxSpeed = 80,
        rotSpeed = 100
    },

    grid = {
        size = 60,             -- Size of background grid squares
        speed = 30,            -- Speed of background parallax
        alpha = 0.15           -- Opacity of the grid lines
    },

    ground = {
        height = 120,
        speed = 140,           -- Speed the floor moves
        lineSpacing = 60       -- Space between lines on the floor
    }
}

-- 2. STATE VARIABLES (Kept local, but accessible via module functions)
local state = {
    hueTimer = 0,             -- Controls the global color cycle
    bgScroll = 0,             -- Parallax background position
    groundScroll = 0,         -- Ground scroll position
    logoBounce = 0,           -- Timer for logo animation
    particles = {},
    fontBig = nil,
    fontSmall = nil
}

-- 3. HELPER FUNCTIONS (Kept local/private)

-- Standard HSV to RGB conversion for the rainbow effect
local function HSV(h, s, v)
    if s <= 0 then return v,v,v end
    h = h*6
    local c = v*s
    local x = (1-math.abs((h%2)-1))*c
    local m,r,g,b = (v-c), 0, 0, 0
    if h < 1     then r,g,b = c,x,0
    elseif h < 2 then r,g,b = x,c,0
    elseif h < 3 then r,g,b = 0,c,x
    elseif h < 4 then r,g,b = 0,x,c
    elseif h < 5 then r,g,b = x,0,c
    else              r,g,b = c,0,x
    end
    return r+m, g+m, b+m
end

-- =============================================================================
--  MODULE FUNCTIONS (Exported as M.Load, M.Update, M.Draw)
-- =============================================================================

function M.Load()
    love.window.setMode(M.CONFIG.window.width, M.CONFIG.window.height)
    love.window.setTitle(Title)

    -- ensure fonts exist (safe fallbacks)
    state.fontBig = Font3 or Font1
    state.fontSmall = Font or Font1

    -- Initialize Particles
    for i = 1, M.CONFIG.particles.count do
        table.insert(state.particles, {
            x = math.random(0, M.CONFIG.window.width),
            y = math.random(-50, M.CONFIG.window.height),
            size = math.random(M.CONFIG.particles.minSize, M.CONFIG.particles.maxSize),
            speed = math.random(M.CONFIG.particles.minSpeed, M.CONFIG.particles.maxSpeed),
            rotation = math.random(0, 360),
            rotDir = math.random() > 0.5 and 1 or -1,
            hueOffset = math.random(), 
            alpha = math.random(2, 8) / 10
        })
    end
end

-- theme presets for per-level visuals
M.Themes = {
    default = {},
    neon = {
        colors = {cycleSpeed = 12, backgroundDarkness = 0.18, glowIntensity = 0.9},
        grid = {size = 48, speed = 36, alpha = 0.18},
        particles = {count = 80, minSize = 10, maxSize = 42, minSpeed = 30, maxSpeed = 90}
    },
    ice = {
        colors = {cycleSpeed = 6, backgroundDarkness = 0.12, glowIntensity = 0.35},
        particles = {count = 70, minSize = 12, maxSize = 48, minSpeed = 20, maxSpeed = 60},
        ground = {height = 140}
    },
    lava = {
        colors = {cycleSpeed = 14, backgroundDarkness = 0.16, glowIntensity = 1.0},
        particles = {count = 48, minSize = 14, maxSize = 60, minSpeed = 40, maxSpeed = 110},
        grid = {size = 72, speed = 20}
    },
    space = {
        colors = {cycleSpeed = 5, backgroundDarkness = 0.04, glowIntensity = 0.8},
        particles = {count = 120, minSize = 6, maxSize = 20, minSpeed = 10, maxSpeed = 40},
        grid = {alpha = 0.06}
    },
    cyber = {
        colors = {cycleSpeed = 18, backgroundDarkness = 0.18, glowIntensity = 1.0},
        grid = {size = 40, speed = 60, alpha = 0.26},
        particles = {count = 90, minSize = 8, maxSize = 32, minSpeed = 30, maxSpeed = 90}
    },
    frost = {
        colors = {cycleSpeed = 7, backgroundDarkness = 0.10, glowIntensity = 0.45},
        particles = {count = 70, minSize = 8, maxSize = 36, minSpeed = 15, maxSpeed = 60},
        ground = {height = 160}
    },
    sunset = {
        colors = {cycleSpeed = 8, backgroundDarkness = 0.22, glowIntensity = 0.6},
        grid = {size = 60, speed = 28}
    },
    forest = {
        colors = {cycleSpeed = 4, backgroundDarkness = 0.16, glowIntensity = 0.4},
        particles = {count = 56, minSize = 10, maxSize = 45},
    },
    prism = {
        colors = {cycleSpeed = 22, backgroundDarkness = 0.2, glowIntensity = 1.0},
        grid = {size = 30, alpha = 0.35},
        particles = {count = 100, minSize = 6, maxSize = 36}
    },
    quantum = {
        colors = {cycleSpeed = 26, backgroundDarkness = 0.06, glowIntensity = 1.0},
        particles = {count = 110, minSize = 4, maxSize = 40, minSpeed = 20, maxSpeed = 120}
    }
}

-- Apply a named theme or reset to default; does a shallow merge of CONFIG.
function M.SetTheme(themeName)
    local theme = M.Themes[themeName or "default"]
    if not theme then return end
    -- shallow merge tables for known sections
    for k, v in pairs(theme) do
        if type(v) == "table" and type(M.CONFIG[k]) == "table" then
            for kk, vv in pairs(v) do M.CONFIG[k][kk] = vv end
        else
            M.CONFIG[k] = v
        end
    end
    -- refresh some state depending on possible changes
    state.bgScroll = 0
    state.groundScroll = 0
end

function M.Update(dt)
    -- 1. Update Global Timers
    state.hueTimer = state.hueTimer + (dt * (M.CONFIG.colors.cycleSpeed / 100))
    if state.hueTimer > 1 then state.hueTimer = state.hueTimer - 1 end
    
    state.logoBounce = state.logoBounce + dt * 3

    -- 2. Update Scrolling
    state.bgScroll = (state.bgScroll + M.CONFIG.grid.speed * dt) % M.CONFIG.grid.size
    state.groundScroll = (state.groundScroll + M.CONFIG.ground.speed * dt) % M.CONFIG.ground.lineSpacing

    -- 3. Update Particles
    for _, p in ipairs(state.particles) do
        p.y = p.y + p.speed * dt
        p.rotation = p.rotation + (M.CONFIG.particles.rotSpeed * p.rotDir * dt)

        -- Reset if off screen
        if p.y > M.CONFIG.window.height - M.CONFIG.ground.height + p.size then
            p.y = -p.size * 2
            p.x = math.random(0, M.CONFIG.window.width)
            p.size = math.random(M.CONFIG.particles.minSize, M.CONFIG.particles.maxSize)
            p.hueOffset = math.random() -- New color when respawning
        end
    end
end

function M.Draw()
    -- Calculate current global color (Rainbow effect)
    local r, g, b = HSV(state.hueTimer, 0.8, 1)

    -- A. DRAW BACKGROUND GRADIENT
    local bgR, bgG, bgB = r * M.CONFIG.colors.backgroundDarkness, g * M.CONFIG.colors.backgroundDarkness, b * M.CONFIG.colors.backgroundDarkness
    
    -- Draw a top-to-bottom gradient
    local vertices = {
        {0, 0, 0, 0, bgR*0.5, bgG*0.5, bgB*0.5, 1}, -- Top Left (Darker)
        {M.CONFIG.window.width, 0, 1, 0, bgR*0.5, bgG*0.5, bgB*0.5, 1}, -- Top Right
        {M.CONFIG.window.width, M.CONFIG.window.height, 1, 1, bgR, bgG, bgB, 1}, -- Bottom Right (Brighter)
        {0, M.CONFIG.window.height, 0, 1, bgR, bgG, bgB, 1} -- Bottom Left
    }
    local mesh = love.graphics.newMesh(vertices, "fan")
    love.graphics.draw(mesh, 0, 0)

    -- B. DRAW MOVING BACKGROUND GRID (The "GD Look")
    love.graphics.setColor(1, 1, 1, M.CONFIG.grid.alpha)
    love.graphics.setLineWidth(1)
    
    -- Vertical Lines
    for x = -M.CONFIG.grid.size, M.CONFIG.window.width, M.CONFIG.grid.size do
        local drawX = x - (state.bgScroll * 0.5) -- Move slower for parallax
        love.graphics.line(drawX, 0, drawX, M.CONFIG.window.height - M.CONFIG.ground.height)
    end
    -- Horizontal Lines
    for y = -M.CONFIG.grid.size, M.CONFIG.window.height - M.CONFIG.ground.height, M.CONFIG.grid.size do
        local drawY = y + (state.bgScroll * 0.5)
        if drawY < M.CONFIG.window.height - M.CONFIG.ground.height then
            love.graphics.line(0, drawY, M.CONFIG.window.width, drawY)
        end
    end

    -- C. DRAW PARTICLES (With Additive Blend for Glow)
    love.graphics.setBlendMode("add") 
    
    for _, p in ipairs(state.particles) do
        love.graphics.push()
        love.graphics.translate(p.x, p.y)
        love.graphics.rotate(math.rad(p.rotation))

        -- Calculate particle specific color (Global Hue + Particle Offset)
        local ph = (state.hueTimer + p.hueOffset) % 1
        local pr, pg, pb = HSV(ph, 0.7, 1)

        -- Draw particle components
        love.graphics.setColor(pr, pg, pb, p.alpha * M.CONFIG.colors.glowIntensity)
        love.graphics.rectangle("fill", -p.size/2 - 5, -p.size/2 - 5, p.size + 10, p.size + 10) -- Glow
        love.graphics.setColor(pr, pg, pb, p.alpha)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", -p.size/2, -p.size/2, p.size, p.size) -- Core outline
        love.graphics.setColor(pr, pg, pb, p.alpha * 0.3)
        love.graphics.rectangle("fill", -p.size/2, -p.size/2, p.size, p.size) -- Inner fill

        love.graphics.pop()
    end
    
    love.graphics.setBlendMode("alpha") -- Reset blending

    -- D. DRAW GROUND
    local groundY = M.CONFIG.window.height - M.CONFIG.ground.height
    
    -- Floor background (Dark)
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, groundY, M.CONFIG.window.width, M.CONFIG.ground.height)
    
    -- Floor Line (Bright Rainbow)
    love.graphics.setColor(r, g, b, 1)
    love.graphics.setLineWidth(4)
    love.graphics.line(0, groundY, M.CONFIG.window.width, groundY)

    -- Moving floor patterns
    love.graphics.setColor(r, g, b, 0.3)
    for i = -1, math.ceil(M.CONFIG.window.width / M.CONFIG.ground.lineSpacing) do
        local lx = (i * M.CONFIG.ground.lineSpacing) - state.groundScroll
        love.graphics.line(lx, groundY, lx - 30, M.CONFIG.window.height)
    end

    -- E. DRAW LOGO / UI
    local logoY = 150 + math.sin(state.logoBounce) * 10 -- Bouncing effect
    
    if GameState.active == GameState.menu then
        love.graphics.setFont(state.fontBig)
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.printf("GEOMETRY DASH", 4, logoY, M.CONFIG.window.width, "center")
        love.graphics.setFont(state.fontBig)
        love.graphics.setColor(r, g, b, 1)
        love.graphics.printf("GEOMETRY DASH", 0, logoY, M.CONFIG.window.width, "center")
    elseif GameState.active == GameState.levelcomplete then
        love.graphics.setFont(Font1)
        love.graphics.setColor(r, g, b, 1)
        love.graphics.printf("LEVEL COMPLETE", 0, logoY - 128, M.CONFIG.window.width, "center")
    elseif GameState.active == GameState.gameover then
        love.graphics.setFont(Font1)
        love.graphics.setColor(r, g, b, 1)
        love.graphics.printf("GAME OVER", 0, logoY - 128, M.CONFIG.window.width, "center")
    elseif GameState.active == GameState.pause then
        love.graphics.setFont(Font1)
        love.graphics.setColor(r, g, b, 1)
        love.graphics.printf("GAME PAUSED", 0, logoY - 128, M.CONFIG.window.width, "center")
    elseif GameState.active == GameState.settings then
        love.graphics.setFont(Font1)
        love.graphics.setColor(r, g, b, 1)
        love.graphics.printf("SETTINGS", 0, logoY - 128, M.CONFIG.window.width, "center")
    elseif GameState.active == GameState.shop then
        love.graphics.setFont(Font1)
        love.graphics.setColor(r, g, b, 1)
        love.graphics.printf("SHOP", 0, logoY - 128, M.CONFIG.window.width, "center")
    elseif GameState.active == GameState.changelog then
        love.graphics.setFont(Font1)
        love.graphics.setColor(r, g, b, 1)
        love.graphics.printf("CHANGELOG", 0, logoY - 128, M.CONFIG.window.width, "center")
    elseif GameState.active == GameState.achievements then
        love.graphics.setFont(Font1)
        love.graphics.setColor(r, g, b, 1)
        love.graphics.printf("ACHIEVEMENTS", 0, logoY - 128, M.CONFIG.window.width, "center")
    elseif GameState.active == GameState.credits then
        love.graphics.setFont(Font1)
        love.graphics.setColor(r, g, b, 1)
        love.graphics.printf("CREDITS", 0, logoY - 128, M.CONFIG.window.width, "center")
    elseif GameState.active == GameState.levelselect then
        love.graphics.setFont(Font1)
        love.graphics.setColor(r, g, b, 1)
        love.graphics.printf("LEVEL SELECT", 0, logoY - 128, M.CONFIG.window.width, "center")
    end
end

return M