Music = {}

----------------------------------------------------------------
-- ENHANCED MUSIC SYSTEM WITH 12 UNIQUE TRACKS
----------------------------------------------------------------

-- Complete notes table with all octaves (FIXED missing notes bug)
local NOTES = {
    -- Octave 2
    C2 = 65.41, CS2 = 69.30, D2 = 73.42, DS2 = 77.78, E2 = 82.41, F2 = 87.31,
    FS2 = 92.50, G2 = 98.00, GS2 = 103.83, A2 = 110.00, AS2 = 116.54, B2 = 123.47,
    
    -- Octave 3
    C3 = 130.81, CS3 = 138.59, D3 = 146.83, DS3 = 155.56, E3 = 164.81, F3 = 174.61,
    FS3 = 185.00, G3 = 196.00, GS3 = 207.65, A3 = 220.00, AS3 = 233.08, B3 = 246.94,
    
    -- Octave 4 (Middle C)
    C4 = 261.63, CS4 = 277.18, D4 = 293.66, DS4 = 311.13, E4 = 329.63, F4 = 349.23,
    FS4 = 369.99, G4 = 392.00, GS4 = 415.30, A4 = 440.00, AS4 = 466.16, B4 = 493.88,
    
    -- Octave 5
    C5 = 523.25, CS5 = 554.37, D5 = 587.33, DS5 = 622.25, E5 = 659.25, F5 = 698.46,
    FS5 = 739.99, G5 = 783.99, GS5 = 830.61, A5 = 880.00, AS5 = 932.33, B5 = 987.77,
    
    -- Octave 6
    C6 = 1046.50, CS6 = 1108.73, D6 = 1174.66, DS6 = 1244.51, E6 = 1318.51, F6 = 1396.91,
    FS6 = 1479.98, G6 = 1567.98, GS6 = 1661.22, A6 = 1760.00, AS6 = 1864.66, B6 = 1975.53
}

-- Theme-to-track mapping (12 unique tracks for each level theme)
local THEME_TRACKS = {
    default = 1,   -- Classic
    neon = 2,      -- Neon City
    cyber = 3,     -- Cyberpunk
    sunset = 4,    -- Sunset Glow
    lava = 5,      -- Molten Lava
    ice = 6,       -- Frozen Tundra
    forest = 7,    -- Enchanted Forest
    prism = 8,     -- Prism Spectrum
    space = 9,     -- Deep Space
    quantum = 10,  -- Quantum Realm
    retro = 11,    -- Retro Arcade
    mystic = 12    -- Mystic Realm
}

-- Track definitions (12 unique procedural tracks)
local TRACKS = {
    -- Track 1: Classic (default theme)
    {
        name = "Classic Dash",
        melody = {
            {NOTES.C4, 0.4}, {NOTES.E4, 0.4}, {NOTES.G4, 0.4}, {NOTES.C5, 0.4},
            {NOTES.B4, 0.25}, {NOTES.A4, 0.25}, {NOTES.G4, 0.5},
            {NOTES.E4, 0.4}, {NOTES.G4, 0.4}, {NOTES.A4, 0.4}, {NOTES.C5, 0.4}
        },
        bassline = {
            {NOTES.C3, 0.8}, {NOTES.F3, 0.8}, {NOTES.G3, 0.8}, {NOTES.C3, 0.8}
        },
        tempo = 1.0,
        waveform = "square"
    },
    
    -- Track 2: Neon City
    {
        name = "Neon Pulse",
        melody = {
            {NOTES.D4, 0.3}, {NOTES.FS4, 0.3}, {NOTES.A4, 0.3}, {NOTES.D5, 0.3},
            {NOTES.CS5, 0.2}, {NOTES.B4, 0.2}, {NOTES.A4, 0.4},
            {NOTES.FS4, 0.3}, {NOTES.A4, 0.3}, {NOTES.B4, 0.3}, {NOTES.D5, 0.3}
        },
        bassline = {
            {NOTES.D3, 0.6}, {NOTES.G3, 0.6}, {NOTES.A3, 0.6}, {NOTES.D3, 0.6}
        },
        tempo = 1.2,
        waveform = "saw"
    },
    
    -- Track 3: Cyberpunk
    {
        name = "Cyber Rhythm",
        melody = {
            {NOTES.E4, 0.35}, {NOTES.GS4, 0.35}, {NOTES.B4, 0.35}, {NOTES.E5, 0.35},
            {NOTES.DS5, 0.25}, {NOTES.CS5, 0.25}, {NOTES.B4, 0.5},
            {NOTES.GS4, 0.35}, {NOTES.B4, 0.35}, {NOTES.CS5, 0.35}, {NOTES.E5, 0.35}
        },
        bassline = {
            {NOTES.E3, 0.7}, {NOTES.A3, 0.7}, {NOTES.B3, 0.7}, {NOTES.E3, 0.7}
        },
        tempo = 1.1,
        waveform = "pulse"
    },
    
    -- Track 4: Sunset Glow
    {
        name = "Sunset Melody",
        melody = {
            {NOTES.F4, 0.5}, {NOTES.A4, 0.5}, {NOTES.C5, 0.5}, {NOTES.F5, 0.5},
            {NOTES.E5, 0.35}, {NOTES.D5, 0.35}, {NOTES.C5, 0.7},
            {NOTES.A4, 0.5}, {NOTES.C5, 0.5}, {NOTES.D5, 0.5}, {NOTES.F5, 0.5}
        },
        bassline = {
            {NOTES.F3, 1.0}, {NOTES.AS3, 1.0}, {NOTES.C4, 1.0}, {NOTES.F3, 1.0}
        },
        tempo = 0.9,
        waveform = "sine"
    },
    
    -- Track 5: Molten Lava
    {
        name = "Lava Flow",
        melody = {
            {NOTES.G4, 0.25}, {NOTES.AS4, 0.25}, {NOTES.D5, 0.25}, {NOTES.G5, 0.25},
            {NOTES.F5, 0.15}, {NOTES.DS5, 0.15}, {NOTES.D5, 0.3},
            {NOTES.AS4, 0.25}, {NOTES.D5, 0.25}, {NOTES.DS5, 0.25}, {NOTES.G5, 0.25}
        },
        bassline = {
            {NOTES.G3, 0.5}, {NOTES.C4, 0.5}, {NOTES.D4, 0.5}, {NOTES.G3, 0.5}
        },
        tempo = 1.4,
        waveform = "square"
    },
    
    -- Track 6: Frozen Tundra
    {
        name = "Frozen Echo",
        melody = {
            {NOTES.A4, 0.6}, {NOTES.CS5, 0.6}, {NOTES.E5, 0.6}, {NOTES.A5, 0.6},
            {NOTES.GS5, 0.45}, {NOTES.FS5, 0.45}, {NOTES.E5, 0.9},
            {NOTES.CS5, 0.6}, {NOTES.E5, 0.6}, {NOTES.FS5, 0.6}, {NOTES.A5, 0.6}
        },
        bassline = {
            {NOTES.A3, 1.2}, {NOTES.D4, 1.2}, {NOTES.E4, 1.2}, {NOTES.A3, 1.2}
        },
        tempo = 0.8,
        waveform = "triangle"
    },
    
    -- Track 7: Enchanted Forest
    {
        name = "Forest Whisper",
        melody = {
            {NOTES.B4, 0.4}, {NOTES.D5, 0.4}, {NOTES.FS5, 0.4}, {NOTES.B5, 0.4},
            {NOTES.A5, 0.25}, {NOTES.G5, 0.25}, {NOTES.FS5, 0.5},
            {NOTES.D5, 0.4}, {NOTES.FS5, 0.4}, {NOTES.G5, 0.4}, {NOTES.B5, 0.4}
        },
        bassline = {
            {NOTES.B3, 0.8}, {NOTES.E4, 0.8}, {NOTES.FS4, 0.8}, {NOTES.B3, 0.8}
        },
        tempo = 1.0,
        waveform = "sine"
    },
    
    -- Track 8: Prism Spectrum
    {
        name = "Prism Dance",
        melody = {
            {NOTES.C5, 0.2}, {NOTES.E5, 0.2}, {NOTES.G5, 0.2}, {NOTES.C6, 0.2},
            {NOTES.B5, 0.15}, {NOTES.A5, 0.15}, {NOTES.G5, 0.3},
            {NOTES.E5, 0.2}, {NOTES.G5, 0.2}, {NOTES.A5, 0.2}, {NOTES.C6, 0.2}
        },
        bassline = {
            {NOTES.C4, 0.4}, {NOTES.F4, 0.4}, {NOTES.G4, 0.4}, {NOTES.C4, 0.4}
        },
        tempo = 1.6,
        waveform = "saw"
    },
    
    -- Track 9: Deep Space
    {
        name = "Cosmic Drift",
        melody = {
            {NOTES.D5, 0.7}, {NOTES.FS5, 0.7}, {NOTES.A5, 0.7}, {NOTES.D6, 0.7},
            {NOTES.CS6, 0.5}, {NOTES.B5, 0.5}, {NOTES.A5, 1.0},
            {NOTES.FS5, 0.7}, {NOTES.A5, 0.7}, {NOTES.B5, 0.7}, {NOTES.D6, 0.7}
        },
        bassline = {
            {NOTES.D4, 1.4}, {NOTES.G4, 1.4}, {NOTES.A4, 1.4}, {NOTES.D4, 1.4}
        },
        tempo = 0.7,
        waveform = "triangle"
    },
    
    -- Track 10: Quantum Realm
    {
        name = "Quantum Pulse",
        melody = {
            {NOTES.E5, 0.3}, {NOTES.GS5, 0.3}, {NOTES.B5, 0.3}, {NOTES.E6, 0.3},
            {NOTES.DS6, 0.2}, {NOTES.CS6, 0.2}, {NOTES.B5, 0.4},
            {NOTES.GS5, 0.3}, {NOTES.B5, 0.3}, {NOTES.CS6, 0.3}, {NOTES.E6, 0.3}
        },
        bassline = {
            {NOTES.E4, 0.6}, {NOTES.A4, 0.6}, {NOTES.B4, 0.6}, {NOTES.E4, 0.6}
        },
        tempo = 1.3,
        waveform = "pulse"
    },
    
    -- Track 11: Retro Arcade
    {
        name = "Arcade Beat",
        melody = {
            {NOTES.F5, 0.35}, {NOTES.A5, 0.35}, {NOTES.C6, 0.35}, {NOTES.F6, 0.35},
            {NOTES.E6, 0.25}, {NOTES.D6, 0.25}, {NOTES.C6, 0.5},
            {NOTES.A5, 0.35}, {NOTES.C6, 0.35}, {NOTES.D6, 0.35}, {NOTES.F6, 0.35}
        },
        bassline = {
            {NOTES.F4, 0.7}, {NOTES.AS4, 0.7}, {NOTES.C5, 0.7}, {NOTES.F4, 0.7}
        },
        tempo = 1.1,
        waveform = "square"
    },
    
    -- Track 12: Mystic Realm
    {
        name = "Mystic Journey",
        melody = {
            {NOTES.G5, 0.45}, {NOTES.AS5, 0.45}, {NOTES.D6, 0.45}, {NOTES.G6, 0.45},
            {NOTES.F6, 0.3}, {NOTES.DS6, 0.3}, {NOTES.D6, 0.6},
            {NOTES.AS5, 0.45}, {NOTES.D6, 0.45}, {NOTES.DS6, 0.45}, {NOTES.G6, 0.45}
        },
        bassline = {
            {NOTES.G4, 0.9}, {NOTES.C5, 0.9}, {NOTES.D5, 0.9}, {NOTES.G4, 0.9}
        },
        tempo = 0.95,
        waveform = "sine"
    }
}

-- Audio configuration
local sampleRate = 44100
local bitDepth = 16
local channels = 1
local amplitude = 0.3

-- State management
local state = {
    currentTrack = 1,
    source = nil,
    isPlaying = false,
    isPaused = false,
    volume = 0.7,
    cache = {},  -- Cache generated tracks
    initialized = false
}

----------------------------------------------------------------
-- WAVEFORM GENERATORS (Fixed with error handling)
----------------------------------------------------------------
local function clamp(n, lo, hi)
    if n < lo then return lo end
    if n > hi then return hi end
    return n
end

local function square(freq, t)
    if not freq or not t then return 0 end
    local x = math.sin(2 * math.pi * freq * t)
    return x > 0 and 1 or -1
end

local function saw(freq, t)
    if not freq or not t then return 0 end
    return 2 * (t * freq - math.floor(0.5 + t * freq))
end

local function triangle(freq, t)
    if not freq or not t then return 0 end
    return 2 * math.abs(2 * (t * freq - math.floor(t * freq + 0.5))) - 1
end

local function sine(freq, t)
    if not freq or not t then return 0 end
    return math.sin(2 * math.pi * freq * t)
end

local function pulse(freq, t, duty)
    duty = duty or 0.25
    if not freq or not t then return 0 end
    local period = 1 / freq
    local mod = t % period
    return mod < period * duty and 1 or -1
end

local function getWaveform(waveform, freq, t)
    if not waveform or not freq or not t then return 0 end
    
    if waveform == "square" then
        return square(freq, t)
    elseif waveform == "saw" then
        return saw(freq, t)
    elseif waveform == "triangle" then
        return triangle(freq, t)
    elseif waveform == "sine" then
        return sine(freq, t)
    elseif waveform == "pulse" then
        return pulse(freq, t, 0.25)
    else
        return square(freq, t)  -- Default fallback
    end
end

----------------------------------------------------------------
-- ADSR ENVELOPE (Enhanced)
----------------------------------------------------------------
local function adsr(t, duration, attack, decay, sustain, release)
    -- Default envelope parameters
    attack = attack or 0.02
    decay = decay or 0.05
    sustain = sustain or 0.8
    release = release or 0.05
    
    if t < attack then
        -- Attack phase
        return t / attack
    elseif t < attack + decay then
        -- Decay phase
        local decayProgress = (t - attack) / decay
        return 1 - (1 - sustain) * decayProgress
    elseif t < duration - release then
        -- Sustain phase
        return sustain
    else
        -- Release phase
        local releaseProgress = math.max(0, (duration - t) / release)
        return releaseProgress * sustain
    end
end

----------------------------------------------------------------
-- TRACK GENERATION (Fixed with proper timing)
----------------------------------------------------------------
function Music.GenerateTrack(trackId)
    -- Check cache first
    if state.cache[trackId] then
        return state.cache[trackId]
    end
    
    -- Validate track ID
    if not trackId or trackId < 1 or trackId > #TRACKS then
        trackId = 1
    end
    
    local track = TRACKS[trackId]
    if not track then
        -- Track not found (silenced)
        return nil
    end
    
    -- Calculate total duration (2 loops)
    local totalDuration = 0
    for _, note in ipairs(track.melody) do
        totalDuration = totalDuration + (note[2] or 0)
    end
    totalDuration = totalDuration * 2  -- Two loops
    
    -- Create sound data
    local samples = math.floor(totalDuration * sampleRate)
    if samples <= 0 then
        -- Invalid track duration (silenced)
        return nil
    end
    
    local success, sd = pcall(function()
        return love.sound.newSoundData(samples, sampleRate, bitDepth, channels)
    end)
    
    if not success or not sd then
        -- Failed to create sound data (silenced)
        return nil
    end
    
    -- Generate audio
    local sampleIndex = 0
    
    -- Generate two loops of the track
    for loop = 1, 2 do
        local melodyTime = 0
        local bassTime = 0
        local melodyNoteIndex = 1
        local bassNoteIndex = 1
        local currentMelodyNote = track.melody[1]
        local currentBassNote = track.bassline[1]
        local melodyNoteStart = 0
        local bassNoteStart = 0
        
        while melodyTime < totalDuration / 2 and sampleIndex < samples do
            local t = sampleIndex / sampleRate
            
            -- Update current melody note
            if melodyNoteIndex <= #track.melody then
                currentMelodyNote = track.melody[melodyNoteIndex]
                if melodyTime >= melodyNoteStart + (currentMelodyNote[2] or 0) then
                    melodyNoteStart = melodyNoteStart + (currentMelodyNote[2] or 0)
                    melodyNoteIndex = melodyNoteIndex + 1
                    if melodyNoteIndex <= #track.melody then
                        currentMelodyNote = track.melody[melodyNoteIndex]
                    end
                end
            end
            
            -- Update current bass note
            if bassNoteIndex <= #track.bassline then
                currentBassNote = track.bassline[bassNoteIndex]
                if bassTime >= bassNoteStart + (currentBassNote[2] or 0) then
                    bassNoteStart = bassNoteStart + (currentBassNote[2] or 0)
                    bassNoteIndex = bassNoteIndex + 1
                    if bassNoteIndex <= #track.bassline then
                        currentBassNote = track.bassline[bassNoteIndex]
                    end
                end
            end
            
            -- Generate samples for current time
            local leadSample = 0
            local bassSample = 0
            
            if currentMelodyNote and currentMelodyNote[1] then
                local noteTime = melodyTime - melodyNoteStart
                local env = adsr(noteTime, currentMelodyNote[2] or 0.4)
                leadSample = getWaveform(track.waveform, currentMelodyNote[1], t) * env * amplitude * 0.7
            end
            
            if currentBassNote and currentBassNote[1] then
                local noteTime = bassTime - bassNoteStart
                local env = adsr(noteTime, currentBassNote[2] or 0.8)
                -- Bass is one octave lower
                bassSample = square(currentBassNote[1] / 2, t) * env * amplitude * 0.5
            end
            
            -- Mix and set sample
            local mixedSample = clamp(leadSample + bassSample, -1, 1)
            if sd.setSample then
                sd:setSample(sampleIndex, mixedSample)
            else
                -- Fallback for older LOVE versions
                pcall(function()
                    sd:setSample(sampleIndex, mixedSample)
                end)
            end
            
            sampleIndex = sampleIndex + 1
            melodyTime = sampleIndex / sampleRate
            bassTime = melodyTime  -- Same time for simplicity
        end
    end
    
    -- Fill remaining samples with silence
    while sampleIndex < samples do
        if sd.setSample then
            sd:setSample(sampleIndex, 0)
        end
        sampleIndex = sampleIndex + 1
    end
    
    -- Create source
    local source = love.audio.newSource(sd)
    if source then
        source:setLooping(true)
        source:setVolume(state.volume)
        state.cache[trackId] = source
        -- Generated track (silenced)
    end
    
    return source
end

----------------------------------------------------------------
-- PUBLIC API (Enhanced with error handling)
----------------------------------------------------------------
function Music.Init()
    -- Generate default track
    state.source = Music.GenerateTrack(1)
    state.isPlaying = false
    state.isPaused = false
    state.initialized = true
    
    -- Set volume from settings if available
    if SaveData and SaveData.settings then
        Music.SetVolume(SaveData.settings.musicEnabled and 0.7 or 0.0)
    else
        Music.SetVolume(0.7)
    end
    
    -- Music system initialized
end

function Music.SetTheme(themeName)
    if not state.initialized then
        Music.Init()
    end
    
    -- Get track ID for theme
    local trackId = THEME_TRACKS[themeName] or 1
    
    -- Only change if different track
    if state.currentTrack ~= trackId then
        state.currentTrack = trackId
        
        -- Stop current music
        if state.source and state.isPlaying then
            state.source:stop()
        end
        
        -- Generate or get cached track
        state.source = Music.GenerateTrack(trackId)
        
        -- Resume if was playing
        if state.isPlaying and not state.isPaused then
            if state.source then
                state.source:play()
            end
        end
        
        -- Switched track (silenced)
    end
end

function Music.SetTrack(trackId)
    if not state.initialized then
        Music.Init()
    end
    
    -- Validate track ID
    trackId = math.max(1, math.min(trackId or 1, #TRACKS))
    
    if state.currentTrack ~= trackId then
        state.currentTrack = trackId
        
        -- Stop current music
        if state.source and state.isPlaying then
            state.source:stop()
        end
        
        -- Generate or get cached track
        state.source = Music.GenerateTrack(trackId)
        
        -- Resume if was playing
        if state.isPlaying and not state.isPaused then
            if state.source then
                state.source:play()
            end
        end
        
        -- Switched track (silenced)
    end
end

function Music.Play()
    if not state.initialized then
        Music.Init()
    end
    
    if not state.source then
        state.source = Music.GenerateTrack(state.currentTrack)
    end
    
    if state.source then
        if state.isPaused then
            state.source:play()
            state.isPaused = false
        elseif not state.isPlaying then
            state.source:play()
            state.isPlaying = true
        end
    end
end

function Music.Stop()
    if state.source and state.isPlaying then
        state.source:stop()
        state.isPlaying = false
        state.isPaused = false
    end
end

function Music.Pause()
    if state.source and state.isPlaying then
        state.source:pause()
        state.isPaused = true
    end
end

function Music.Resume()
    if state.source and state.isPaused then
        state.source:play()
        state.isPaused = false
    end
end

function Music.Toggle()
    if not state.initialized then
        Music.Init()
    end
    
    if state.isPlaying then
        if state.isPaused then
            Music.Resume()
        else
            Music.Pause()
        end
    else
        Music.Play()
    end
end

function Music.IsPlaying()
    return state.isPlaying and not state.isPaused
end

function Music.SetVolume(vol)
    vol = math.max(0, math.min(1, vol or 0.7))
    state.volume = vol
    
    if state.source then
        state.source:setVolume(vol)
    end
end

function Music.GetVolume()
    return state.volume
end

function Music.GetCurrentTrack()
    return state.currentTrack
end

function Music.GetTrackName(trackId)
    trackId = trackId or state.currentTrack
    if TRACKS[trackId] then
        return TRACKS[trackId].name
    end
    return "Unknown Track"
end

function Music.GetTrackInfo(trackId)
    trackId = trackId or state.currentTrack
    if TRACKS[trackId] then
        local track = TRACKS[trackId]
        return {
            name = track.name,
            tempo = track.tempo,
            waveform = track.waveform,
            melodyLength = #track.melody,
            bassLength = #track.bassline
        }
    end
    return nil
end

function Music.Cleanup()
    -- Clear cache and stop music
    if state.source then
        state.source:stop()
        state.source = nil
    end
    
    for _, source in pairs(state.cache) do
        if source then
            source:stop()
        end
    end
    
    state.cache = {}
    state.isPlaying = false
    state.isPaused = false
    state.initialized = false
    
    -- Music system cleaned up
end

function Music.PreloadAllTracks()
    -- Preload all tracks for smooth transitions
    -- Preloading all music tracks...
    
    for i = 1, #TRACKS do
        if not state.cache[i] then
            state.cache[i] = Music.GenerateTrack(i)
        end
    end
    
    -- All tracks preloaded
end

function Music.SetTempo(tempo)
    -- Note: Changing tempo requires regenerating tracks
    -- This is a placeholder for future enhancement
    -- Tempo change not implemented (silenced)
end

function Music.TestAllTracks()
    -- Test function to play each track briefly
    -- Testing all tracks... (silenced)
    
    for i = 1, #TRACKS do
        -- Playing track (silenced)
        Music.SetTrack(i)
        Music.Play()
        
        -- Wait a bit (in a real game, you'd use a timer)\
        local start = love.timer.getTime()
        while love.timer.getTime() - start < 2 do
            -- Do nothing for 2 seconds
        end
        
        Music.Stop()
    end
    
    -- Return to first track
    Music.SetTrack(1)
    -- Test complete (silenced)
end

return Music