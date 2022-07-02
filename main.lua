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
import "scripts/loot"

-- Util functions
function clamp(n, low, high)
    return math.min(math.max(low, n), high)
end

function shouldDrawSprite(s)
    return pd.display:getRect():intersects(s:getBoundsRect())
end

-- State
local player = Player(60, -27)

function initialize()
    -- Use all extra time per frame to run the garbage collector
    pd.setGCScaling(0, 0)

    -- Use the Lua GC mode that's optimized for short lived tiny objects
    collectgarbage("generational")

    Loot(pd.display.getWidth() / 2, pd.display.getHeight() / 2, 1)
end

function pd.update()
    gfx.animation.blinker.updateAll()
    gfx.sprite.update()
    pd.drawFPS()
end

initialize()
