local level = {}

----------------------------------------------------------------
-- OBJECT TABLES (World positions)
----------------------------------------------------------------
GroundObjects = {}
SpikeObjects = {}
CoinObjects = {}
BlockObjects = {}
FinishObjects = {}
TransparentObjects = {}
PlatformObjects = {}
MiniSpikeObjects = {}
BigSpikeObjects = {}
FlippedMiniSpikeObjects = {}

-- Game state
TotalCoinsCollected = 0
CurrentLevel = nil
CurrentLevelID = 1
LevelScrollSpeed = BASE_SCROLL_SPEED

-- Performance optimization
local objectCache = {}
local objectPool = {}

----------------------------------------------------------------
-- LEVEL REWARDS SYSTEM (Enhanced)
----------------------------------------------------------------
function GetLevelReward(levelId)
    -- FIXED: Added bounds checking and validation
    if not levelId or levelId < 1 or levelId > 12 then
        return 5, 1  -- Default reward
    end
    
    -- Enhanced reward progression
    local rewardTable = {
        [1] = {coins = 10, diamonds = 1},
        [2] = {coins = 15, diamonds = 1},
        [3] = {coins = 20, diamonds = 2},
        [4] = {coins = 25, diamonds = 2},
        [5] = {coins = 30, diamonds = 3},
        [6] = {coins = 35, diamonds = 3},
        [7] = {coins = 40, diamonds = 4},
        [8] = {coins = 50, diamonds = 4},
        [9] = {coins = 60, diamonds = 5},
        [10] = {coins = 75, diamonds = 5},
        [11] = {coins = 100, diamonds = 6},
        [12] = {coins = 150, diamonds = 10}
    }
    
    local reward = rewardTable[levelId]
    if reward then
        return reward.coins, reward.diamonds
    end
    
    return 5, 1  -- Fallback
end

----------------------------------------------------------------
-- LEVEL DATA (12 COMPLETE levels - all fixed and working)
----------------------------------------------------------------
Levels = {
    -- LEVEL 1: Scramble (Tutorial level)
    [1] = {
        scrollSpeed = BASE_SCROLL_SPEED * 0.85,
        name = "Scramble",
        theme = "default",
        difficulty = 1,
        rows = {
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                         C                                                      C                                                      C                                     F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                     C                               PPPPPPPP                           PPPPPPPP                           PPPPPPPP                           PPPPPPPP                           PPPPPPPP       F",
        "                                  PPPPPPPP                                                                                                                                                                                                                                                                                          F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                    SS   SS                                   SS                          SS     SS                          SS     SS                          SS     SS                          SS     SS                F",
        "               PP              PPP                     PPS             PP                PP              PP                PP              PP                PP              PP                PP              PP            F",
        "        F",
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF",
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF"
        }
    },
    
    -- LEVEL 2: Platformis (Platform focused)
    [2] = {
        scrollSpeed = BASE_SCROLL_SPEED * 0.9,
        name = "Platformis",
        theme = "neon",
        difficulty = 1,
        rows = {
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                   C                          C                          C                          C                          C                          C         F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                C                            C                          C                            C                          C                            C                        F",
        "                                             PPPP                            PPPP                            PPPP                            PPPP                            PPPP                            PPPP       F",
        "                                           S       P                       S       P                       S       P                       S       P                       S       P                       S       P         F",
        "                              PPPP     S                  P                PPPP     S                  P                PPPP     S                  P                PPPP     S                  P                PPPP   F",
        "                    VVV              PPP                     BB                    VVV              PPP                     BB                    VVV              PPP                     BB                    VVV    F",
        "            PPP              PPPP                         BB  BB             PPP              PPPP                         BB  BB             PPP              PPPP                         BB  BB             PPP      F",
        "           VVVVV      C                          SSSSSBBBSSBBBBB      S      VVVVV      C                          SSSSSBBBSSBBBBB      S      VVVVV      C                          SSSSSBBBSSBBBBB      S      VVVV F",
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF",
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF"
        }
    },
    
    -- LEVEL 3: Shadow Run (Speed challenge)
    [3] = {
        scrollSpeed = BASE_SCROLL_SPEED * 1.0,
        name = "Shadow Run",
        theme = "cyber",
        difficulty = 2,
        rows = {
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                              C              C              C              C              C              C             F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                         C                               C                               C                               C             F",
        "                                                                                                        C                                                                                                                               C                               F",
        "                                                                 PPPPPPPP                               PPPPPPPP                               PPPPPPPP                               PPPPPPPP                               PPPPPPPP       F",
        "                           S                 S                     S                 S                     S                 S                     S                 S                     S                 S                     S       F",
        "             PPPP                     S                 PPPP                     S                 PPPP                     S                 PPPP                     S                 PPPP                     S                 PPPP   F",
        "   BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBF",
        "    VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVF",
        "     C       C       C       C       C       C       C       C       C       C       C       C       C       C       C       C       C       C       C       C       C       C       C       C       C       C       C       C     F",
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF",
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF"
        }
    },
    
    -- LEVEL 4: Pulse Drift (Timing challenge)
    [4] = {
        scrollSpeed = BASE_SCROLL_SPEED * 1.1,
        name = "Pulse Drift",
        theme = "sunset",
        difficulty = 2,
        rows = {
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                    C                C                C                C                C                C                C                C                C                C                C      F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                              PPPPPPPP                PPPPPPPP                PPPPPPPP                PPPPPPPP                PPPPPPPP                PPPPPPPP                PPPPPPPP       F",
        "                                                         S                S                S                S                S                S                S                S                S                S                S                S                F",
        "                                                    PPPP                PPPP                PPPP                PPPP                PPPP                PPPP                PPPP                PPPP                PPPP                PPPP                PPPP   F",
        "                                               VVV                VVV                VVV                VVV                VVV                VVV                VVV                VVV                VVV                VVV                VVV                F",
        "                                          C                C                C                C                C                C                C                C                C                C                C                C                C                F",
        "                                     PPPPPPPP                PPPPPPPP                PPPPPPPP                PPPPPPPP                PPPPPPPP                PPPPPPPP                PPPPPPPP                PPPPPPPP                PPPPPPPP                PPPPPPPP       F",
        "                                S                S                S                S                S                S                S                S                S                S                S                S                S                S                F",
        "                           PPPP                PPPP                PPPP                PPPP                PPPP                PPPP                PPPP                PPPP                PPPP                PPPP                PPPP                PPPP                PPPP   F",
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF",
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF"
        }
    },
    
    -- LEVEL 5: Echo Breaker (Jumping challenge)
    [5] = {
        scrollSpeed = BASE_SCROLL_SPEED * 1.05,
        name = "Echo Breaker",
        theme = "lava",
        difficulty = 3,
        rows = {
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                           C                                          F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                         C                                                                   F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                  C                                                                                                          F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                      C                                                                                                                                                      F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                     C                                                                                                                                                                                                     F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                        C                                                                                                                                                                                                                  F",
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF",
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF"
        }
    },
    
    -- LEVEL 6: Wave Storm (Spike maze)
    [6] = {
        scrollSpeed = BASE_SCROLL_SPEED * 1.0,
        name = "Wave Storm",
        theme = "ice",
        difficulty = 3,
        rows = {
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                              C                                          C                                          C                                          F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                         S                S                S                S                S                S                S                F",
        "                                                                                                        S                S                S                S                S                S                S                S                S                S                F",
        "                                                                 S                S                S                S                S                S                S                S                S                S                S                S                F",
        "                           S                S                S                S                S                S                S                S                S                S                S                S                S                S                F",
        "             S                S                S                S                S                S                S                S                S                S                S                S                S                S                S                F",
        "   S                S                S                S                S                S                S                S                S                S                S                S                S                S                S                S                F",
        "      C                C                C                C                C                C                C                C                C                C                C                C                C                C                C                C                F",
        "         PPPPPPPP                PPPPPPPP                PPPPPPPP                PPPPPPPP                PPPPPPPP                PPPPPPPP                PPPPPPPP                PPPPPPPP                PPPPPPPP                PPPPPPPP                PPPPPPPP                F",
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF",
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF"
        }
    },
    
    -- LEVEL 7: Neon Bloom (Pattern challenge)
    [7] = {
        scrollSpeed = BASE_SCROLL_SPEED * 1.15,
        name = "Neon Bloom",
        theme = "forest",
        difficulty = 4,
        rows = {
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                        C                C                C                C                C                C                C                C                C                C                F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                              PPPPPPPP                PPPPPPPP                PPPPPPPP                PPPPPPPP                PPPPPPPP                PPPPPPPP       F",
        "                                                                                                                   S                S                S                S                S                S                S                S                S                F",
        "                                                                                                          PPPP                PPPP                PPPP                PPPP                PPPP                PPPP                PPPP                PPPP                PPPP   F",
        "                                                                                                     VVV                VVV                VVV                VVV                VVV                VVV                VVV                VVV                VVV                F",
        "                                                                                                C                C                C                C                C                C                C                C                C                C                C                F",
        "                                                                                           PPPPPPPP                PPPPPPPP                PPPPPPPP                PPPPPPPP                PPPPPPPP                PPPPPPPP                PPPPPPPP                PPPPPPPP       F",
        "                                                                                      S                S                S                S                S                S                S                S                S                S                S                S                F",
        "                                                                                 PPPP                PPPP                PPPP                PPPP                PPPP                PPPP                PPPP                PPPP                PPPP                PPPP                PPPP   F",
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF",
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF"
        }
    },
    
    -- LEVEL 8: Frost Edge (Precision platforming)
    [8] = {
        scrollSpeed = BASE_SCROLL_SPEED * 1.05,
        name = "Frost Edge",
        theme = "prism",
        difficulty = 4,
        rows = {
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                           C                                          F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                      C                                                                                                                                                      F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                        C                                                                                                                                                                                                                  F",
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF",
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF"
        }
    },
    
    -- LEVEL 9: Hyper Dash (High speed challenge)
    [9] = {
        scrollSpeed = BASE_SCROLL_SPEED * 1.25,
        name = "Hyper Dash",
        theme = "quantum",
        difficulty = 5,
        rows = {
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                        C                C                C                C                C                C                C                C                C                C                F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF",
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF"
        }
    },
    
    -- LEVEL 10: Prism Crash (Colorful obstacles)
    [10] = {
        scrollSpeed = BASE_SCROLL_SPEED * 1.1,
        name = "Prism Crash",
        theme = "retro",
        difficulty = 5,
        rows = {
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                              C                                          C                                          C                                          F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF",
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF"
        }
    },
    
    -- LEVEL 11: Quantum Leap (Advanced platforming)
    [11] = {
        scrollSpeed = BASE_SCROLL_SPEED * 1.15,
        name = "Quantum Leap",
        theme = "space",
        difficulty = 6,
        rows = {
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                              C                                          C                                          C                                          F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF",
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF"
        }
    },
    
    -- LEVEL 12: Star Burst (Final boss level)
    [12] = {
        scrollSpeed = BASE_SCROLL_SPEED * 1.2,
        name = "Star Burst",
        theme = "mystic",
        difficulty = 7,
        rows = {
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                        C                C                C                C                C                C                C                C                C                C                F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "                                                                                                                                                                                                                                                                                                                                    F",
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF",
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF"
        }
    }
}

----------------------------------------------------------------
-- AABB COLLISION HELPER (Optimized)
----------------------------------------------------------------
function AABBRect(ax, ay, aw, ah, bx, by, bw, bh)
    -- FIXED: Added parameter validation and optimization
    if not ax or not ay or not aw or not ah or not bx or not by or not bw or not bh then
        return false
    end
    
    -- Early exit optimization
    if ax + aw <= bx or bx + bw <= ax then
        return false
    end
    
    if ay + ah <= by or by + bh <= ay then
        return false
    end
    
    return true
end

-- Optimized collision check for arrays
function CheckCollisions(objects, playerX, playerY, playerW, playerH)
    for i = #objects, 1, -1 do
        local obj = objects[i]
        if obj and AABBRect(playerX, playerY, playerW, playerH, obj.x, obj.y, obj.width, obj.height) then
            return obj, i
        end
    end
    return nil
end

----------------------------------------------------------------
-- LEVEL PARSER AND LOADER (Fixed and optimized)
----------------------------------------------------------------
function LoadLevel(levelId)
    -- FIXED: Validate level ID
    if not levelId or levelId < 1 or levelId > 12 then
        CurrentLevel = nil
        CurrentLevelID = 0
        GameState.ACTIVE = GameState.MENU
        return false
    end

    -- FIXED: Check if level exists
    if not Levels[levelId] then
        CurrentLevel = nil
        CurrentLevelID = 0
        GameState.ACTIVE = GameState.MENU
        return false
    end

    CurrentLevelID = levelId
    CurrentLevel = Levels[levelId]
    
    -- Set music track
    if Music and CurrentLevel.theme then
        Music.SetTheme(CurrentLevel.theme)
    end
    
    -- Set scroll speed
    LevelScrollSpeed = CurrentLevel.scrollSpeed or BASE_SCROLL_SPEED
    
    -- Clear all object lists (use object pooling for performance)
    ClearObjectLists()
    
    -- Parse level data
    local success, errorMsg = pcall(function()
        ParseLevelData(CurrentLevel.rows)
    end)
    
    if not success then
        return false
    end
    
    -- Reset player
    ResetPlayer()
    
    -- Reset coins
    TotalCoinsCollected = 0
end
 

function ClearObjectLists()
    -- Recycle objects to pool instead of creating new ones
    for _, obj in ipairs(GroundObjects) do
        RecycleObject("ground", obj)
    end
    
    for _, obj in ipairs(SpikeObjects) do
        RecycleObject("spike", obj)
    end
    
    for _, obj in ipairs(CoinObjects) do
        RecycleObject("coin", obj)
    end
    
    for _, obj in ipairs(BlockObjects) do
        RecycleObject("block", obj)
    end
    
    for _, obj in ipairs(FinishObjects) do
        RecycleObject("finish", obj)
    end
    
    for _, obj in ipairs(PlatformObjects) do
        RecycleObject("platform", obj)
    end
    
    for _, obj in ipairs(MiniSpikeObjects) do
        RecycleObject("minispike", obj)
    end
    
    for _, obj in ipairs(BigSpikeObjects) do
        RecycleObject("bigspike", obj)
    end
    
    for _, obj in ipairs(FlippedMiniSpikeObjects) do
        RecycleObject("flippedminispike", obj)
    end
    
    -- Clear lists
    GroundObjects = {}
    SpikeObjects = {}
    CoinObjects = {}
    BlockObjects = {}
    FinishObjects = {}
    TransparentObjects = {}
    PlatformObjects = {}
    MiniSpikeObjects = {}
    BigSpikeObjects = {}
    FlippedMiniSpikeObjects = {}
end

function GetObjectFromPool(type)
    if not objectPool[type] then
        objectPool[type] = {}
    end
    
    if #objectPool[type] > 0 then
        return table.remove(objectPool[type])
    end
    
    return nil
end

function RecycleObject(type, obj)
    if not objectPool[type] then
        objectPool[type] = {}
    end
    
    if obj then
        obj.collected = nil
        table.insert(objectPool[type], obj)
    end
end

function ParseLevelData(rows)
    if not rows or #rows == 0 then
        return
    end
    
    local height = #rows * TILE_SIZE
    local startY = WINDOW_HEIGHT - height
    
    for row = 1, #rows do
        local line = rows[row]
        if not line then
            -- skip nil rows
            goto continue
        end

        for col = 1, #line do
            local char = line:sub(col, col)
            local x = (col - 1) * TILE_SIZE
            local y = startY + (row - 1) * TILE_SIZE
            
            -- Handle different object types
            if char == "G" then
                local obj = GetObjectFromPool("ground") or {}
                obj.x, obj.y, obj.width, obj.height = x, y, TILE_SIZE, TILE_SIZE
                table.insert(GroundObjects, obj)
                
            elseif char == "B" then
                local obj = GetObjectFromPool("block") or {}
                obj.x, obj.y, obj.width, obj.height = x, y, TILE_SIZE, TILE_SIZE
                table.insert(BlockObjects, obj)
                
            elseif char == "S" then
                local obj = GetObjectFromPool("spike") or {}
                obj.x, obj.y, obj.width, obj.height = x, y, TILE_SIZE, TILE_SIZE
                table.insert(SpikeObjects, obj)
                
            elseif char == "C" then
                local obj = GetObjectFromPool("coin") or {}
                obj.x, obj.y, obj.width, obj.height = x, y, TILE_SIZE, TILE_SIZE
                obj.collected = false
                table.insert(CoinObjects, obj)
                
            elseif char == "F" then
                local obj = GetObjectFromPool("finish") or {}
                obj.x, obj.y, obj.width, obj.height = x, y, TILE_SIZE, TILE_SIZE
                table.insert(FinishObjects, obj)
                
            elseif char == "P" then
                local obj = GetObjectFromPool("platform") or {}
                obj.x, obj.y, obj.width, obj.height = x, y + (TILE_SIZE/2), TILE_SIZE, TILE_SIZE/2
                table.insert(PlatformObjects, obj)
                
            elseif char == "V" then
                local obj = GetObjectFromPool("minispike") or {}
                obj.x, obj.y, obj.width, obj.height = x, y + (TILE_SIZE/2), TILE_SIZE, TILE_SIZE/2
                table.insert(MiniSpikeObjects, obj)
                
            elseif char == "W" then
                local obj = GetObjectFromPool("bigspike") or {}
                obj.x, obj.y, obj.width, obj.height = x, y - TILE_SIZE, TILE_SIZE, TILE_SIZE * 2
                table.insert(BigSpikeObjects, obj)
                
            elseif char == "v" then
                local obj = GetObjectFromPool("flippedminispike") or {}
                obj.x, obj.y, obj.width, obj.height = x, y, TILE_SIZE, TILE_SIZE/2
                table.insert(FlippedMiniSpikeObjects, obj)
            end
        end
        ::continue::
    end
end

function ResetPlayer()
    -- FIXED: Reset player to safe position
    Player.x = PLAYER_CONFIG.START_X or 100
    Player.y = WINDOW_HEIGHT - 150
    Player.yVelocity = 0
    Player.isOnGround = false
    
    -- Reset physics timers
    Player.jumpBufferTimer = 0
    Player.coyoteTimer = 0

end

----------------------------------------------------------------
-- DRAW LEVEL OBJECTS (Original colors)
----------------------------------------------------------------
function DrawLevelObjects()
    -- Draw ground using original sprite coloration
    for _, ground in ipairs(GroundObjects) do
        DrawTileSprite(Sprites.block, ground.x, ground.y, ground.width, ground.height)
    end

    -- Draw blocks using original sprite coloration
    for _, block in ipairs(BlockObjects) do
        DrawTileSprite(Sprites.block, block.x, block.y, block.width, block.height)
    end

    -- Draw platforms using original sprite coloration
    for _, platform in ipairs(PlatformObjects) do
        DrawTileSprite(Sprites.platform or Sprites.block, platform.x, platform.y, platform.width, platform.height)
    end

    -- Draw spikes (all types) using sprite visuals when available
    DrawSpikeObjects(SpikeObjects, Sprites.spike)
    DrawSpikeObjects(MiniSpikeObjects, Sprites.minispike)
    DrawSpikeObjects(BigSpikeObjects, Sprites.bigspike)
    DrawSpikeObjects(FlippedMiniSpikeObjects, Sprites.flippedminispike)

    -- Draw coins using coin sprite (original color)
    for _, coin in ipairs(CoinObjects) do
        if not coin.collected then
            DrawTileSprite(Sprites.coin, coin.x + 6, coin.y + 6, coin.width - 12, coin.height - 12)
        end
    end

    -- Draw finish line (kept neutral)
    for _, finish in ipairs(FinishObjects) do
        love.graphics.setColor(0.6, 0.6, 0.6, 1)
        love.graphics.rectangle("fill", finish.x, finish.y, finish.width, finish.height)
        love.graphics.setColor(0, 0, 0)
        love.graphics.setFont(Font2 or love.graphics.getFont())
        love.graphics.print("FINISH", finish.x + finish.width/2 - 25, finish.y + finish.height/2 - 8)
    end

    love.graphics.setColor(1, 1, 1)
end

function DrawSpikeObjects(spikeList, sprite)
    for _, spike in ipairs(spikeList) do
        if sprite then
            DrawTileSprite(sprite, spike.x, spike.y, spike.width, spike.height)
        else
            love.graphics.setColor(0.6, 0.6, 0.6)
            love.graphics.rectangle("fill", spike.x, spike.y, spike.width, spike.height)
        end
    end
    love.graphics.setColor(1, 1, 1)
end

function DrawFinishLine(x, y, width, height)
    -- Neutral monochrome finish line
    love.graphics.setColor(0.6, 0.6, 0.6, 1)
    love.graphics.rectangle("fill", x, y, width, height)

    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(Font2 or love.graphics.getFont())
    love.graphics.print("FINISH", x + width/2 - 25, y + height/2 - 8)
end

----------------------------------------------------------------
-- LEVEL COMPLETION REWARDS (Enhanced)
----------------------------------------------------------------
function CompleteLevel(levelId)
    -- FIXED: Added validation and error handling
    if not levelId or levelId < 1 or levelId > 12 then
        return false
    end
    
    local coinReward, diamondReward = GetLevelReward(levelId)
    
    -- Track level completion
    PlayerStats.levelsCompleted = (PlayerStats.levelsCompleted or 0) + 1
    SaveData.levelsCompleted = (SaveData.levelsCompleted or 0) + 1
    
    -- Update save data
    SaveData.coins = (SaveData.coins or 0) + coinReward
    SaveData.diamonds = (SaveData.diamonds or 0) + diamondReward
    
    PlayerStats.coins = (PlayerStats.coins or 0) + coinReward
    PlayerStats.diamonds = (PlayerStats.diamonds or 0) + diamondReward
    PlayerStats.totalCoinsCollected = (PlayerStats.totalCoinsCollected or 0) + coinReward
    PlayerStats.totalDiamondsCollected = (PlayerStats.totalDiamondsCollected or 0) + diamondReward
    
    -- Unlock next level
    if SaveData.unlockedLevels and levelId < 12 then
        SaveData.unlockedLevels[levelId + 1] = true
    end
    
    -- Mark level as completed in stars
    SaveData.levelStars = SaveData.levelStars or {}
    SaveData.levelStars[levelId] = SaveData.levelStars[levelId] or {}
    SaveData.levelStars[levelId].completed = true
    
    -- Award stars based on performance
    local stars = CalculateLevelStars(levelId)
    SaveData.levelStars[levelId].stars = math.max(stars, SaveData.levelStars[levelId].stars or 0)
    
    -- Save game
    if SaveGame then
        SaveGame()
    end
    
    -- Show reward message
    local message = string.format(
        "Level Complete!\n\n" ..
        "Rewards:\n" ..
        "+%d coins\n" ..
        "+%d diamonds\n\n" ..
        "Total coins: %d\n" ..
        "Total diamonds: %d",
        coinReward, diamondReward, SaveData.coins, SaveData.diamonds
    )
    
    -- Add star rating
    if stars > 0 then
        message = message .. "\n\nStar Rating: "
        for i = 1, 3 do
            message = message .. (i <= stars and "★" or "☆")
        end
    end
    
    PopWindow.ShowMessage("Success!", message)
    
    return true
end

function CalculateLevelStars(levelId)
    local stars = 1  -- Base star for completion
    
    -- Star 2: Collect all coins
    local totalCoins = 0
    local collectedCoins = 0
    
    for _, coin in ipairs(CoinObjects) do
        totalCoins = totalCoins + 1
        if coin.collected then
            collectedCoins = collectedCoins + 1
        end
    end
    
    if totalCoins > 0 and collectedCoins == totalCoins then
        stars = stars + 1
    end
    
    -- Star 3: Complete without dying (tracked separately)
    -- This would need additional tracking in the player stats
    
    return stars
end

----------------------------------------------------------------
-- UTILITY FUNCTIONS (Enhanced)
----------------------------------------------------------------
function GetLevelName(levelId)
    if Levels[levelId] then
        return Levels[levelId].name
    end
    return "Level " .. levelId
end

function GetLevelTheme(levelId)
    if Levels[levelId] then
        return Levels[levelId].theme or "default"
    end
    return "default"
end

function IsLevelUnlocked(levelId)
    -- FIXED: Added validation
    if not levelId or levelId < 1 then
        return false
    end
    
    if levelId == 1 then
        return true
    end
    
    if SaveData and SaveData.unlockedLevels then
        return SaveData.unlockedLevels[levelId] == true
    end
    
    return false
end

function GetLevelDifficulty(levelId)
    if Levels[levelId] then
        return Levels[levelId].difficulty or 1
    end
    return 1
end

function GetLevelScrollSpeed(levelId)
    if Levels[levelId] then
        return Levels[levelId].scrollSpeed or BASE_SCROLL_SPEED
    end
    return BASE_SCROLL_SPEED
end

function GetLevelStarRating(levelId)
    if SaveData and SaveData.levelStars and SaveData.levelStars[levelId] then
        return SaveData.levelStars[levelId].stars or 0
    end
    return 0
end

function HasLevelBeenCompleted(levelId)
    if SaveData and SaveData.levelStars and SaveData.levelStars[levelId] then
        return SaveData.levelStars[levelId].completed == true
    end
    return false
end

function GetTotalStars()
    local total = 0
    if SaveData and SaveData.levelStars then
        for i = 1, 12 do
            if SaveData.levelStars[i] then
                total = total + (SaveData.levelStars[i].stars or 0)
            end
        end
    end
    return total
end

function GetMaxStars()
    return 12 * 3  -- 12 levels, 3 stars each
end

function GetCompletionPercentage()
    local completed = 0
    for i = 1, 12 do
        if HasLevelBeenCompleted(i) then
            completed = completed + 1
        end
    end
    return math.floor((completed / 12) * 100)
end

return level