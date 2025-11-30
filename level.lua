local level = {}
---------------------------------------------------------
-- OBJECT TABLES (world positions)
---------------------------------------------------------
GroundObjects = {}   -- { x,y,width,height }
SpikeObjects = {}
CoinObjects = {}
BlockObjects = {}
FinishObjects = {}
-- NEW object lists:
TransparentObjects = {} -- T (no collision)
PlatformObjects    = {} -- P (top-only collision; half height tile visually if desired)
MiniSpikeObjects   = {} -- V (half height, 16px tall)
BigSpikeObjects    = {} -- W (double height, 64px tall)
FlippedMiniSpikeObjects   = {} -- v 
TotalCoinsCollected = 0
CurrentLevel = nil
CurrentLevelID = 1
---------------------------------------------------------
-- INLINE LEVELS (supports new chars: T,P,V,W)
-- Characters: G ground, B block, S spike, C coin, F finish, T transparent, P platform, V minispike, W bigspike
---------------------------------------------------------
Levels = {
    [1] = {
        scrollSpeed = Ss,
        rows = {
        "                                                                                                                             F", --1
        "                                                                                                                             F", --2
        "                                                                                                                             F", --3
        "                                                                                                                             F", --4
        "                                                                                                                             F", --5
        "                                                                                                                             F", --6
        "                                                                                                                             F", --7
        "                                                                                                                             F", --8
        "                                                                                                                             F", --9
        "                                                                                                                             F", --10
        "                                                                                                                             F", --11
        "                                                                                                       C                     F", --12
        "                                                                                                                             F", --13
        "                                                 C                                                 PPP    P                  F", --14
        "                                             PP  PP  PP                                         PPP                          F", --15
        "                                         PP             PP                       C           PPP                             F", --16
        "               S            SS      BBBSSSSSSSWWWWWWWWWSSSSSBBBBB        SS     BBBBBVVVBBBBBSSSSSSSSSSSSSSSS            S   F", --17
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF", --18
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF"  --19
        }
    },
    [2] = {
        scrollSpeed = Ss,
        rows = {
        "                                                                                                                             F", --1
        "                                                                                                                             F", --2
        "                                                                                                                             F", --3
        "                                                                                                                             F", --4
        "                                                                                                                             F", --5
        "                                                                                                                             F", --6
        "                                                                                                                             F", --7
        "                                                                    C                                                        F", --8
        "                                                                                                                             F", --9
        "                                                                                                                             F", --10
        "                                                                    S                                        VV              F", --11
        "                                                                PPPPB                                                        F", --12
        "                                                              S        P                                                     F", --13
        "                                                          PPPPB           P                              BB                  F", --14
        "                          VVVVV                         S                    P                       BB  BB  BB              F", --15
        "                PPPP                  PPPP          PPPPB                                        BB  BB  BB  BB   C  S       F", --16
        "               VVVVVV       C        VVVVVV       SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSBBB       BBBSSSSSSBBSSBBSSBBBBBBBBB       F", --17
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF", --18
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF"  --19
        }
    },
    [3] = {
        scrollSpeed = (Ss * 1.4 ),
        rows = {
        "                                                                                                                             F", --1
        "                                                                                                                             F", --2
        "                                                                                                                             F", --3
        "                                                                        BBBBB                                              F", --4
        "                                                                     BBBvvvvv                                               F", --5
        "                                                                BBBBBvvv                                                        F", --6
        "                                                          BBBBBBvvvvv                                                          F", --7
        "                                                    BBBBBBvvvvvv             C                                                   F", --8
        "                                              BBBBBBvvvvvv                                                                   F", --9
        "               BB     BB     BB               vvvvvv                                                                         F", --10
        "               vv     vv     vv                                            PP                                                     F", --11
        "                                                                     PP                                                        F", --12
        "                                                                PP                                                           F", --13
        "                                                          PPP                                                                F", --14
        "                                                    PPP                                                                      F", --15
        "                                   VVVVV     PPP                                                                            F", --16
        "               SS     SS     SS                                                                                                F", --17
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF", --18
        "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF"  --19
        }
    },
    [4] = {
        scrollSpeed = Ss,
        rows = {
            "                                                                                                                             F", --1
            "                                                                                                                             F", --2
            "                                                                                                                             F", --3
            "                                                                                                                             F", --4
            "                                                                                                                             F", --5
            "                                                                                                                             F", --6
            "                                                                                                                             F", --7
            "                                                                                                                             F", --8
            "                                                                                                                             F", --9
            "                                                                                                                             F", --10
            "                                                                                                                             F", --11
            "                                                                                                                             F", --12
            "                                                                                                                             F", --13
            "                                                                                                                             F", --14
            "                                                                                                                             F", --15
            "                                                                                                                             F", --16
            "                                                                                                                             F", --17
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF", --18
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF"  --19
        }
    },
    [5] = {
        scrollSpeed = Ss,
        rows = {
            "                                                                                                                             F", --1
            "                                                                                                                             F", --2
            "                                                                                                                             F", --3
            "                                                                                                                             F", --4
            "                                                                                                                             F", --5
            "                                                                                                                             F", --6
            "                                                                                                                             F", --7
            "                                                                                                                             F", --8
            "                                                                                                                             F", --9
            "                                                                                                                             F", --10
            "                                                                                                                             F", --11
            "                                                                                                                             F", --12
            "                                                                                                                             F", --13
            "                                                                                                                             F", --14
            "                                                                                                                             F", --15
            "                                                                                                                             F", --16
            "                                                                                                                             F", --17
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF", --18
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGF"  --19
        }
    },
    [6] = {
        scrollSpeed = Ss,
        rows = {
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "        C                                                                       ",
            "                                                                                ",
            "           B     B       V                                                      ",
            "   B        P       B                                                           ",
            "          S                                                                     ",
            "                            W                                                   ",
            "                 B                                                              ",
            "    C                                                                           ",
            "        B          S       B                                                     ",
            "                 B                 F                                           ",
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG"
        }
    },
    [7] = {
        scrollSpeed = Ss,
        rows = {
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "             C                                                                  ",
            "                                                                                ",
            "     B      B         P                                                          ",
            "                B       V                                                       ",
            "   S                                                                            ",
            "                   B                                                            ",
            "                      W                                                         ",
            "                 C                                                              ",
            "        B           B       S                                                    ",
            "                           B           F                                        ",
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG"
        }
    },
    [8] = {
        scrollSpeed = Ss,
        rows = {
            "                                                                                ",
            "                                                                                ",
            "          C                                                                     ",
            "                                                                                ",
            "      B           B       V                                                     ",
            "             P                                                                   ",
            "   S                                                                            ",
            "                 B                                                              ",
            "                        W                                                       ",
            "           C                                                                    ",
            "        B           S       B                                                    ",
            "                     B              F                                           ",
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG"
        }
    },
    [9] = {
        scrollSpeed = Ss,
        rows = {
            "                                                                                ",
            "        C                                                                       ",
            "                                                                                ",
            "       B     V       B                                                           ",
            "                P                                                               ",
            "   S                                                                            ",
            "                     W                                                          ",
            "            B                                                                   ",
            "       C                                                                            ",
            "           B          S       B                                                  ",
            "                        B                 F                                      ",
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG"
        }
    },
    [10] = {
        scrollSpeed = Ss,
        rows = {
            "                                                                                ",
            "                                                                                ",
            "             C                                                                  ",
            "         B         V                                                            ",
            "                P                                                               ",
            "   S                                                                            ",
            "                 W                                                              ",
            "      B                                                                         ",
            "           C                                                                    ",
            "       B        S       B                                                        ",
            "                         B                F                                      ",
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG"
        }
    },
    [11] = {
        scrollSpeed = Ss,
        rows = {
            "                                                                                ",
            "                                                                                ",
            "           C                                                                    ",
            "        B          V                                                             ",
            "                 P                                                              ",
            "   S                                                                            ",
            "                      W                                                          ",
            "                 B                                                              ",
            "          C                                                                     ",
            "        B          S       B                                                     ",
            "                            B                 F                                   ",
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG"
        }
    },
    [12] = {
        scrollSpeed = Ss,
        rows = {
            "                                                                                ",
            "              C                                                                 ",
            "       B          V                                                              ",
            "                 P                                                              ",
            "   S                                                                            ",
            "                         W                                                      ",
            "                 B                                                              ",
            "           C                                                                    ",
            "        B          S       B                                                     ",
            "                            B                 F                                   ",
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG"
        }
    }
}
---------------------------------------------------------
-- AABB helper (rectangle vs rectangle)
---------------------------------------------------------
function AABBRect(ax, ay, aw, ah, bx, by, bw, bh)
    return ax < bx + bw and bx < ax + aw and ay < by + bh and by < ay + ah
end
---------------------------------------------------------
-- LEVEL PARSER: from rows -> object tables
---------------------------------------------------------
function LoadLevel(levelID)
    if not Levels[levelID] then
        CurrentLevel = nil
        CurrentLevelID = 0
        GameState.active = GameState.menu
        return
    end
    CurrentLevelID = levelID
    CurrentLevel = Levels[levelID]
    -- clear object lists
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
    local rows = CurrentLevel.rows
    for row = 1, #rows do
        local line = rows[row]
        for col = 1, #line do
            local ch = line:sub(col, col)
            local x = (col - 1) * TILE
            local y = (row - 1) * TILE
            if ch == "G" then
                table.insert(GroundObjects, {x = x, y = y, width = TILE, height = TILE})
            elseif ch == "B" then
                table.insert(BlockObjects, {x = x, y = y, width = TILE, height = TILE})
            elseif ch == "S" then
                table.insert(SpikeObjects, {x = x, y = y, width = TILE, height = TILE})
            elseif ch == "C" then
                table.insert(CoinObjects, {x = x, y = y, width = TILE, height = TILE, collected = false})
            elseif ch == "F" then
                table.insert(FinishObjects, {x = x, y = y, width = TILE, height = TILE})
            elseif ch == "T" then
                table.insert(TransparentObjects, {x = x, y = y, width = TILE, height = TILE})
            elseif ch == "P" then
                -- platform is half-height visually (player lands on top); store full tile but collision is top-only
                table.insert(PlatformObjects, {x = x, y = y + (TILE/2), width = TILE, height = TILE/2})
            elseif ch == "V" then
                -- mini spike: half height (16px)
                table.insert(MiniSpikeObjects, {x = x, y = y + (TILE/2), width = TILE, height = TILE/2})
            elseif ch == "W" then
                -- big spike: 2x height (place its top one tile above)
                table.insert(BigSpikeObjects, {x = x, y = y - TILE, width = TILE, height = TILE * 2})
            elseif ch == "v" then
                --
                table.insert(FlippedMiniSpikeObjects, {x = x, y = y + (TILE/4), width = TILE, height = TILE/2})
            end
        end
    end
    -- reset player
    Player.x = 100
    Player.y = WindowHeight - 150
    Player.yVelocity = 0
    Player.isOnGround = false
    TotalCoinsCollected = 0
end
return level