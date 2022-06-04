import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/animation"
import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry

import "scripts/chain"
import "scripts/arrow"

class("Player").extends(gfx.sprite)

function Player:init(x, y)
    self.speed = 5

    self.chain = Chain(x, y, 8, 27)
    self.arrow = Arrow(self.chain.hook, 4)

    self:add()
end

function Player:update()
    -- Controls
    local dx = 0
    if pd.buttonIsPressed(pd.kButtonLeft) then
        dx -= self.speed
    elseif pd.buttonIsPressed(pd.kButtonRight) then
        dx += self.speed
    end
    local change, acceleratedChange = pd.getCrankChange()
    local dy = -acceleratedChange / 360 * self.speed * 6
    self.chain:moveBy(dx, dy)

    Player.super.update(self)
end
