local music = {}

-- Simple procedural chiptune generator: two voices (lead + bass)
-- Implements Init, Play, Stop, Toggle, Pause, Resume

local sampleRate = 44100
local bitDepth = 16
local channels = 1
local amplitude = 0.2

local function clamp(n, lo, hi)
    if n < lo then return lo end
    if n > hi then return hi end
    return n
end

local NOTES = {
    -- a basic C major-ish scale frequencies (Hz)
    C4 = 261.63,
    D4 = 293.66,
    E4 = 329.63,
    F4 = 349.23,
    G4 = 392.00,
    A4 = 440.00,
    B4 = 493.88,
    C5 = 523.25,
    D5 = 587.33,
}

-- A tiny melody: note + duration (seconds)
local melody = {
    {NOTES.C4, 0.4}, {NOTES.E4, 0.4}, {NOTES.G4, 0.4}, {NOTES.C5, 0.4},
    {NOTES.B4, 0.25}, {NOTES.A4, 0.25}, {NOTES.G4, 0.5},
    {NOTES.E4, 0.4}, {NOTES.G4, 0.4}, {NOTES.A4, 0.4}, {NOTES.C5, 0.4},
}

local bassline = {
    {NOTES.C3, 0.8}, {NOTES.F3, 0.8}, {NOTES.G3, 0.8}, {NOTES.C3, 0.8}
}

-- For the sake of simplicity, define missing low octave notes
NOTES.C3 = NOTES.C4 / 2
NOTES.F3 = 349.23 / 2
NOTES.G3 = 392.00 / 2

local function square(freq, t)
    local x = math.sin(2 * math.pi * freq * t)
    if x > 0 then return 1 else return -1 end
end

local function adsr(t, duration)
    -- basic attack-decay-sustain-release
    local attack = 0.02
    local release = 0.05
    local sustain = 0.8
    if t < attack then
        return (t / attack)
    elseif t > duration - release then
        return math.max(0, (duration - t) / release) * sustain
    else
        return sustain
    end
end

function music.GenerateLoop()
    -- total duration
    local totalSeconds = 0
    for _, v in ipairs(melody) do totalSeconds = totalSeconds + v[2] end
    -- We will repeat melody for a simple 2x loop
    totalSeconds = totalSeconds * 2

    local samples = math.floor(totalSeconds * sampleRate)
    local sd = love.sound.newSoundData(samples, sampleRate, bitDepth, channels)

    local sampleIndex = 0
    -- weave two melodies, lead repeats twice
    for loop = 1, 2 do
        for _, note in ipairs(melody) do
            local freq = note[1]
            local duration = note[2]
            local frames = math.floor(duration * sampleRate)
            for i = 0, frames - 1 do
                local t = i / sampleRate
                local env = adsr(t, duration)
                -- lead: square wave
                local lead = square(freq, t) * env * amplitude
                -- bass: one octave lower at half amplitude
                local bass = square(freq / 2, t) * env * (amplitude * 0.5)
                local sample = clamp(lead + bass, -1, 1)
                sd:setSample(sampleIndex, sample)
                sampleIndex = sampleIndex + 1
                if sampleIndex >= samples then break end
            end
            if sampleIndex >= samples then break end
        end
        if sampleIndex >= samples then break end
    end

    -- fill rest with silence if any
    while sampleIndex < samples do
        sd:setSample(sampleIndex, 0)
        sampleIndex = sampleIndex + 1
    end

    -- create source
    local src = love.audio.newSource(sd)
    src:setLooping(true)
    src:setVolume(0.6)
    return src
end

function music.Init()
    music.source = music.GenerateLoop()
    music.isPlaying = false
end

function music.Play()
    if not music.source then music.Init() end
    if music.source and not music.isPlaying then
        love.audio.play(music.source)
        music.isPlaying = true
    end
end

function music.Stop()
    if music.source and music.isPlaying then
        music.source:stop()
        music.isPlaying = false
    end
end

function music.Pause()
    if music.source and music.isPlaying then
        music.source:pause()
        music.isPlaying = false
    end
end

function music.Resume()
    if music.source and not music.isPlaying then
        music.source:play()
        music.isPlaying = true
    end
end

function music.Toggle()
    if music.isPlaying then
        music.Stop()
    else
        music.Play()
    end
end

function music.IsPlaying()
    return music.isPlaying
end

return music
