import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/animation"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry
local vector2D <const> = geo.vector2D

import "scripts/player"

-- Util functions
function clamp(n, low, high)
    return math.min(math.max(low, n), high)
end

function shouldDrawSprite(s)
    return pd.display:getRect():intersects(s:getBoundsRect())
end

-- Constants
local kNumPoints = 8
local kHookConnectionPoint = kNumPoints + 1
local kHookPoint = kHookConnectionPoint + 1
local kSegLength = 27
local kSpeed = 5
local kGravity = vector2D.new(0, 9.80)
local kDragFactor = vector2D.new(0.0125, 0.025)
local kIterationCount = 5
local kTickTime = 1/pd.display.getRefreshRate()

-- State
local player = Player(60, -27)

function initialize()
    -- Use all extra time per frame to run the garbage collector
    pd.setGCScaling(0, 0)

    -- Use the Lua GC mode that's optimized for short lived tiny objects
    collectgarbage("generational")
end

function pd.update()
    gfx.animation.blinker.updateAll()
    gfx.sprite.update()
    pd.drawFPS()
end

initialize()
