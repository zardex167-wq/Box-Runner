local BackgroundSystem = {}

----------------------------------------------------------------
-- CONFIGURATION
----------------------------------------------------------------
BackgroundSystem.CONFIG = {
    window = { 
        width = WINDOW_WIDTH, 
        height = WINDOW_HEIGHT 
    },
    
    colors = {
        cycleSpeed = 10,
        backgroundDarkness = 0.2,
        glowIntensity = 0.6
    },
    
    particles = {
        count = 60,
        minSize = 20,
        maxSize = 55,
        minSpeed = 20,
        maxSpeed = 80,
        rotSpeed = 100
    },
    
    grid = {
        size = 60,
        speed = 30,
        alpha = 0.15
    },
    
    ground = {
        height = 120,
        speed = 140,
        lineSpacing = 60
    }
}

----------------------------------------------------------------
-- STATE MANAGEMENT
----------------------------------------------------------------
local state = {
    hueTimer = 0,
    bgScroll = 0,
    groundScroll = 0,
    logoBounce = 0,
    particles = {},
    fontBig = nil,
    fontSmall = nil,
    currentTheme = "default"
}

----------------------------------------------------------------
-- THEME DEFINITIONS (12 unique level themes)
----------------------------------------------------------------
BackgroundSystem.Themes = {
    default = {
        name = "Classic",
        colors = { cycleSpeed = 8, backgroundDarkness = 0.15, glowIntensity = 0.7 },
        particles = { count = 50, minSize = 15, maxSize = 40, minSpeed = 15, maxSpeed = 60 },
        grid = { size = 50, speed = 25, alpha = 0.2 },
        ground = { height = 100, speed = 120, lineSpacing = 50 }
    },
    
    neon = {
        name = "Neon City",
        colors = { cycleSpeed = 15, backgroundDarkness = 0.1, glowIntensity = 0.9 },
        particles = { count = 80, minSize = 10, maxSize = 30, minSpeed = 30, maxSpeed = 90 },
        grid = { size = 40, speed = 40, alpha = 0.25 },
        ground = { height = 90, speed = 150, lineSpacing = 40 }
    },
    
    cyber = {
        name = "Cyberpunk",
        colors = { cycleSpeed = 12, backgroundDarkness = 0.08, glowIntensity = 0.85 },
        particles = { count = 70, minSize = 8, maxSize = 25, minSpeed = 25, maxSpeed = 75 },
        grid = { size = 35, speed = 35, alpha = 0.3 },
        ground = { height = 110, speed = 130, lineSpacing = 45 }
    },
    
    sunset = {
        name = "Sunset Glow",
        colors = { cycleSpeed = 6, backgroundDarkness = 0.25, glowIntensity = 0.6 },
        particles = { count = 40, minSize = 25, maxSize = 60, minSpeed = 10, maxSpeed = 40 },
        grid = { size = 70, speed = 20, alpha = 0.15 },
        ground = { height = 130, speed = 100, lineSpacing = 60 }
    },
    
    lava = {
        name = "Molten Lava",
        colors = { cycleSpeed = 20, backgroundDarkness = 0.05, glowIntensity = 1.0 },
        particles = { count = 90, minSize = 5, maxSize = 20, minSpeed = 40, maxSpeed = 120 },
        grid = { size = 30, speed = 50, alpha = 0.35 },
        ground = { height = 80, speed = 180, lineSpacing = 35 }
    },
    
    ice = {
        name = "Frozen Tundra",
        colors = { cycleSpeed = 4, backgroundDarkness = 0.3, glowIntensity = 0.4 },
        particles = { count = 30, minSize = 30, maxSize = 70, minSpeed = 5, maxSpeed = 25 },
        grid = { size = 80, speed = 15, alpha = 0.1 },
        ground = { height = 140, speed = 80, lineSpacing = 70 }
    },
    
    forest = {
        name = "Enchanted Forest",
        colors = { cycleSpeed = 7, backgroundDarkness = 0.2, glowIntensity = 0.5 },
        particles = { count = 60, minSize = 20, maxSize = 50, minSpeed = 15, maxSpeed = 50 },
        grid = { size = 55, speed = 28, alpha = 0.18 },
        ground = { height = 120, speed = 110, lineSpacing = 55 }
    },
    
    prism = {
        name = "Prism Spectrum",
        colors = { cycleSpeed = 25, backgroundDarkness = 0.12, glowIntensity = 0.95 },
        particles = { count = 100, minSize = 3, maxSize = 15, minSpeed = 50, maxSpeed = 150 },
        grid = { size = 25, speed = 60, alpha = 0.4 },
        ground = { height = 70, speed = 200, lineSpacing = 30 }
    },
    
    space = {
        name = "Deep Space",
        colors = { cycleSpeed = 3, backgroundDarkness = 0.02, glowIntensity = 0.8 },
        particles = { count = 120, minSize = 2, maxSize = 10, minSpeed = 2, maxSpeed = 15 },
        grid = { size = 100, speed = 10, alpha = 0.05 },
        ground = { height = 150, speed = 60, lineSpacing = 80 }
    },
    
    quantum = {
        name = "Quantum Realm",
        colors = { cycleSpeed = 30, backgroundDarkness = 0.18, glowIntensity = 0.75 },
        particles = { count = 80, minSize = 12, maxSize = 35, minSpeed = 35, maxSpeed = 105 },
        grid = { size = 45, speed = 45, alpha = 0.22 },
        ground = { height = 95, speed = 160, lineSpacing = 42 }
    },
    
    retro = {
        name = "Retro Arcade",
        colors = { cycleSpeed = 18, backgroundDarkness = 0.22, glowIntensity = 0.65 },
        particles = { count = 45, minSize = 18, maxSize = 45, minSpeed = 22, maxSpeed = 66 },
        grid = { size = 65, speed = 32, alpha = 0.12 },
        ground = { height = 105, speed = 140, lineSpacing = 65 }
    },
    
    mystic = {
        name = "Mystic Realm",
        colors = { cycleSpeed = 9, backgroundDarkness = 0.28, glowIntensity = 0.55 },
        particles = { count = 55, minSize = 22, maxSize = 55, minSpeed = 18, maxSpeed = 54 },
        grid = { size = 75, speed = 22, alpha = 0.08 },
        ground = { height = 125, speed = 95, lineSpacing = 75 }
    }
}

----------------------------------------------------------------
-- HELPER FUNCTIONS
----------------------------------------------------------------
local function HSVtoRGB(hue, saturation, value)
    if saturation <= 0 then
        return value, value, value
    end
    
    hue = hue * 6
    local chroma = value * saturation
    local x = (1 - math.abs((hue % 2) - 1)) * chroma
    local min = value - chroma
    local r, g, b = min, min, min
    
    if hue < 1 then
        r, g, b = r + chroma, g + x, b
    elseif hue < 2 then
        r, g, b = r + x, g + chroma, b
    elseif hue < 3 then
        r, g, b = r, g + chroma, b + x
    elseif hue < 4 then
        r, g, b = r, g + x, b + chroma
    elseif hue < 5 then
        r, g, b = r + x, g, b + chroma
    else
        r, g, b = r + chroma, g, b + x
    end
    
    return r, g, b
end

local function createParticle(theme)
    local config = theme and theme.particles or BackgroundSystem.CONFIG.particles
    
    return {
        x = math.random(0, BackgroundSystem.CONFIG.window.width),
        y = math.random(-50, BackgroundSystem.CONFIG.window.height - 100),
        size = math.random(config.minSize, config.maxSize),
        speed = math.random(config.minSpeed, config.maxSpeed),
        rotation = math.random(0, 360),
        rotDir = math.random() > 0.5 and 1 or -1,
        hueOffset = math.random(),
        alpha = math.random(2, 8) / 10
    }
end

----------------------------------------------------------------
-- PUBLIC API
----------------------------------------------------------------
function BackgroundSystem.Load()
    love.window.setTitle(GAME_TITLE)
    love.window.setMode(BackgroundSystem.CONFIG.window.width, 
                       BackgroundSystem.CONFIG.window.height)
    
    -- Load fonts
    state.fontBig = Font3 or Font1 or love.graphics.getFont()
    state.fontSmall = Font1 or Font2 or love.graphics.getFont()
    
    -- Initialize particles for default theme
    state.particles = {}
    for i = 1, BackgroundSystem.CONFIG.particles.count do
        table.insert(state.particles, createParticle())
    end
    
    state.currentTheme = "default"
end

function BackgroundSystem.SetTheme(themeName)
    if not themeName or not BackgroundSystem.Themes[themeName] then
        themeName = "default"
    end
    
    local theme = BackgroundSystem.Themes[themeName]
    state.currentTheme = themeName
    
    -- Apply theme configuration
    if theme.colors then
        for key, value in pairs(theme.colors) do
            BackgroundSystem.CONFIG.colors[key] = value
        end
    end
    
    if theme.particles then
        for key, value in pairs(theme.particles) do
            BackgroundSystem.CONFIG.particles[key] = value
        end
    end
    
    if theme.grid then
        for key, value in pairs(theme.grid) do
            BackgroundSystem.CONFIG.grid[key] = value
        end
    end
    
    if theme.ground then
        for key, value in pairs(theme.ground) do
            BackgroundSystem.CONFIG.ground[key] = value
        end
    end
    
    -- Recreate particles with new theme
    state.particles = {}
    for i = 1, BackgroundSystem.CONFIG.particles.count do
        table.insert(state.particles, createParticle(theme))
    end
    
    -- Reset animation states
    state.bgScroll = 0
    state.groundScroll = 0
end

function BackgroundSystem.Update(deltaTime)
    local theme = BackgroundSystem.Themes[state.currentTheme] or {}
    local colors = theme.colors or BackgroundSystem.CONFIG.colors
    local grid = theme.grid or BackgroundSystem.CONFIG.grid
    local ground = theme.ground or BackgroundSystem.CONFIG.ground
    
    -- Update timers
    state.hueTimer = (state.hueTimer + deltaTime * (colors.cycleSpeed / 100)) % 1
    state.logoBounce = state.logoBounce + deltaTime * 3
    
    -- Update scrolling
    state.bgScroll = (state.bgScroll + grid.speed * deltaTime) % grid.size
    state.groundScroll = (state.groundScroll + ground.speed * deltaTime) % ground.lineSpacing
    
    -- Update particles
    for _, particle in ipairs(state.particles) do
        particle.y = particle.y + particle.speed * deltaTime
        particle.rotation = particle.rotation + BackgroundSystem.CONFIG.particles.rotSpeed * 
                           particle.rotDir * deltaTime
        
        -- Reset particles that go off screen
        if particle.y > BackgroundSystem.CONFIG.window.height - ground.height + particle.size then
            particle.y = -particle.size * 2
            particle.x = math.random(0, BackgroundSystem.CONFIG.window.width)
            particle.size = math.random(BackgroundSystem.CONFIG.particles.minSize, 
                                       BackgroundSystem.CONFIG.particles.maxSize)
            particle.hueOffset = math.random()
        end
    end
end

function BackgroundSystem.Draw()
    local theme = BackgroundSystem.Themes[state.currentTheme] or {}
    local colors = theme.colors or BackgroundSystem.CONFIG.colors
    local grid = theme.grid or BackgroundSystem.CONFIG.grid
    local ground = theme.ground or BackgroundSystem.CONFIG.ground
    
    -- Calculate current color
    local r, g, b = HSVtoRGB(state.hueTimer, 0.8, 1)
    
    -- Draw background gradient
    local bgR = r * colors.backgroundDarkness
    local bgG = g * colors.backgroundDarkness
    local bgB = b * colors.backgroundDarkness
    
    local vertices = {
        {0, 0, 0, 0, bgR * 0.5, bgG * 0.5, bgB * 0.5, 1},
        {BackgroundSystem.CONFIG.window.width, 0, 1, 0, bgR * 0.5, bgG * 0.5, bgB * 0.5, 1},
        {BackgroundSystem.CONFIG.window.width, BackgroundSystem.CONFIG.window.height, 
         1, 1, bgR, bgG, bgB, 1},
        {0, BackgroundSystem.CONFIG.window.height, 0, 1, bgR, bgG, bgB, 1}
    }
    
    local mesh = love.graphics.newMesh(vertices, "fan")
    love.graphics.draw(mesh, 0, 0)
    
    -- Draw grid
    love.graphics.setColor(1, 1, 1, grid.alpha)
    love.graphics.setLineWidth(1)
    
    -- Vertical lines
    for x = -grid.size, BackgroundSystem.CONFIG.window.width, grid.size do
        local drawX = x - (state.bgScroll * 0.5)
        love.graphics.line(drawX, 0, drawX, 
                          BackgroundSystem.CONFIG.window.height - ground.height)
    end
    
    -- Horizontal lines
    for y = -grid.size, BackgroundSystem.CONFIG.window.height - ground.height, grid.size do
        local drawY = y + (state.bgScroll * 0.5)
        if drawY < BackgroundSystem.CONFIG.window.height - ground.height then
            love.graphics.line(0, drawY, BackgroundSystem.CONFIG.window.width, drawY)
        end
    end
    
    -- Draw particles with additive blending
    love.graphics.setBlendMode("add")
    
    for _, particle in ipairs(state.particles) do
        love.graphics.push()
        love.graphics.translate(particle.x, particle.y)
        love.graphics.rotate(math.rad(particle.rotation))
        
        -- Calculate particle color
        local particleHue = (state.hueTimer + particle.hueOffset) % 1
        local pr, pg, pb = HSVtoRGB(particleHue, 0.7, 1)
        
        -- Draw particle glow
        love.graphics.setColor(pr, pg, pb, particle.alpha * colors.glowIntensity)
        love.graphics.rectangle("fill", -particle.size/2 - 5, -particle.size/2 - 5, 
                              particle.size + 10, particle.size + 10)
        
        -- Draw particle core
        love.graphics.setColor(pr, pg, pb, particle.alpha)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", -particle.size/2, -particle.size/2, 
                              particle.size, particle.size)
        
        -- Draw particle fill
        love.graphics.setColor(pr, pg, pb, particle.alpha * 0.3)
        love.graphics.rectangle("fill", -particle.size/2, -particle.size/2, 
                              particle.size, particle.size)
        
        love.graphics.pop()
    end
    
    love.graphics.setBlendMode("alpha")
    
    -- Draw ground
    local groundY = BackgroundSystem.CONFIG.window.height - ground.height
    
    -- Ground background
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, groundY, 
                           BackgroundSystem.CONFIG.window.width, ground.height)
    
    -- Ground line
    love.graphics.setColor(r, g, b, 1)
    love.graphics.setLineWidth(4)
    love.graphics.line(0, groundY, BackgroundSystem.CONFIG.window.width, groundY)
    
    -- Ground patterns
    love.graphics.setColor(r, g, b, 0.3)
    for i = -1, math.ceil(BackgroundSystem.CONFIG.window.width / ground.lineSpacing) do
        local lineX = (i * ground.lineSpacing) - state.groundScroll
        love.graphics.line(lineX, groundY, lineX - 30, BackgroundSystem.CONFIG.window.height)
    end
    
    -- Draw UI text based on game state
    local logoY = 150 + math.sin(state.logoBounce) * 10
    
    if GameState.ACTIVE == GameState.MENU then
        -- Draw title with shadow effect
        love.graphics.setFont(state.fontBig)
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.printf("GEO DASH", 4, logoY, 
                           BackgroundSystem.CONFIG.window.width, "center")
        love.graphics.setColor(r, g, b, 1)
        love.graphics.printf("GEO DASH", 0, logoY, 
                           BackgroundSystem.CONFIG.window.width, "center")
        
    elseif GameState.ACTIVE == GameState.LEVELCOMPLETE then
        love.graphics.setFont(state.fontSmall)
        love.graphics.setColor(r, g, b, 1)
        love.graphics.printf("LEVEL COMPLETE!", 0, logoY - 128, 
                           BackgroundSystem.CONFIG.window.width, "center")
        
    elseif GameState.ACTIVE == GameState.GAMEOVER then
        love.graphics.setFont(state.fontSmall)
        love.graphics.setColor(r, g, b, 1)
        love.graphics.printf("GAME OVER", 0, logoY - 128, 
                           BackgroundSystem.CONFIG.window.width, "center")
        
    elseif GameState.ACTIVE == GameState.PAUSE then
        love.graphics.setFont(state.fontSmall)
        love.graphics.setColor(r, g, b, 1)
        love.graphics.printf("GAME PAUSED", 0, logoY - 128, 
                           BackgroundSystem.CONFIG.window.width, "center")
        
    elseif GameState.ACTIVE == GameState.SETTINGS then
        love.graphics.setFont(state.fontSmall)
        love.graphics.setColor(r, g, b, 1)
        love.graphics.printf("SETTINGS", 0, logoY - 128, 
                           BackgroundSystem.CONFIG.window.width, "center")
        
    elseif GameState.ACTIVE == GameState.SHOP then
        love.graphics.setFont(state.fontSmall)
        love.graphics.setColor(r, g, b, 1)
        love.graphics.printf("SHOP", 0, logoY - 128, 
                           BackgroundSystem.CONFIG.window.width, "center")
        
    elseif GameState.ACTIVE == GameState.ACHIEVEMENTS then
        love.graphics.setFont(state.fontSmall)
        love.graphics.setColor(r, g, b, 1)
        love.graphics.printf("ACHIEVEMENTS", 0, logoY - 128, 
                           BackgroundSystem.CONFIG.window.width, "center")
        
    elseif GameState.ACTIVE == GameState.CREDITS then
        love.graphics.setFont(state.fontSmall)
        love.graphics.setColor(r, g, b, 1)
        love.graphics.printf("CREDITS", 0, logoY - 128, 
                           BackgroundSystem.CONFIG.window.width, "center")
        
    elseif GameState.ACTIVE == GameState.LEVELSELECT then
        love.graphics.setFont(state.fontSmall)
        love.graphics.setColor(r, g, b, 1)
        love.graphics.printf("LEVEL SELECT", 0, logoY - 128, 
                           BackgroundSystem.CONFIG.window.width, "center")
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function BackgroundSystem.GetCurrentTheme()
    return state.currentTheme
end

function BackgroundSystem.GetThemeName()
    local theme = BackgroundSystem.Themes[state.currentTheme]
    return theme and theme.name or "Default"
end

return BackgroundSystem