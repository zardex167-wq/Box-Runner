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
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                           C                                    ",
            "                     C                                                          ",
            "             B      B       V    S            P       B         F              ",
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG"
        }
    },

    [2] = {
        scrollSpeed = Ss,
        rows = {
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "              C               C                                                 ",
            "         B     B     B   W     S                 B       B          F           ",
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG"
        }
    },

    [3] = {
        scrollSpeed = Ss,
        rows = {
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "        T                                                                       ",
            "        T                                                                       ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "                                                                                ",
            "      C           B    C                         B                              ",
            "   B   B     B       B      S                  BBBBB               F          ",
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