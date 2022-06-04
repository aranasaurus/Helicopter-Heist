import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/animation"
import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry

import "scripts/chain"

class("Player").extends(gfx.sprite)

local arrowUp = gfx.image.new("images/arrow-up")
local arrowLeft = gfx.image.new("images/arrow-left")
local arrowRight = gfx.image.new("images/arrow-right")

function Player:init(x, y)
    self.speed = 5

    self.chain = Chain(x, y, 8, 27)

    self.arrow = gfx.sprite.new()
    self.arrow:add()
    self.arrow:setVisible(false)
    self.arrow:setZIndex(32767)

    self.arrowAnim = gfx.animation.blinker.new()
    self.arrowAnim:stop()

    self:add()
end

function Player:drawArrow()
    -- bail early and turn off the arrow and its animation if the hook is on the screen
    if shouldDrawSprite(self.chain.hook) then
        self.arrowAnim:stop()
        self.arrow:setUpdatesEnabled(false)
        self.arrow:setVisible(false)
        return
    end

    -- start the animation and re-enable the arrow sprite
    self.arrow:setUpdatesEnabled(true)
    if not self.arrowAnim.running then
        self.arrowAnim:startLoop()
    end

    -- update the location of the arrow to match the midpoint of the hook
    local hx, hy = self.chain.hook.x, self.chain.hook.y
    local p = geo.point.new(hx, hy + (self.chain.hook.height / 2))
    local margin = 4
    local hOffset = arrowUp.width / 2
    local vOffset = arrowUp.height / 2
    local x = clamp(p.x, margin + hOffset, pd.display.getWidth() - hOffset - margin)
    local y = clamp(p.y, margin + vOffset, pd.display.getHeight() - vOffset - margin)
    self.arrow:moveTo(x, y)

    -- pick the right image / orientation
    if p.y < 0 then
        self.arrow:setImage(arrowUp)
    elseif p.x < 0 then
        self.arrow:setImage(arrowLeft)
    elseif p.x > 400 then
        self.arrow:setImage(arrowRight)
    end

    -- update visibility based on the animation state
    self.arrow:setVisible(self.arrowAnim.on)
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

    self:drawArrow()
end
