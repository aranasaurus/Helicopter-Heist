import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/animation"
import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry

class("Arrow").extends(gfx.sprite)

local arrowUp = gfx.image.new("images/arrow-up")
local arrowLeft = gfx.image.new("images/arrow-left")
local arrowRight = gfx.image.new("images/arrow-right")

function Arrow:init(trackedSprite, margin)
    self.trackedSprite = trackedSprite
    self.margin = margin
    self.anim = gfx.animation.blinker.new()
    self.anim:stop()

    self:moveTo(0, 0)
    self:setVisible(false)
    self:setZIndex(32767)
    self:add()
end

function Arrow:start()
    if self.anim.running then
        return
    end

    self.anim:startLoop()
    self:setVisible(false)
end

function Arrow:stop()
    if not self.anim.running then
        return
    end

    self.anim:stop()
    self:setVisible(false)
end

function Arrow:update()
    local sprite = self.trackedSprite
    if pd.display:getRect():intersects(sprite:getBoundsRect()) then
        self:stop()
        return
    end

    self:start()

    -- update the location of the arrow to match the midpoint of the sprite
    local cx, cy = sprite:getCenter()
    local p = geo.point.new(sprite.x + sprite.width * cx, sprite.y + sprite.height * cy)
    local hOffset = arrowUp.width / 2
    local vOffset = arrowUp.height / 2
    local x = clamp(p.x, self.margin + hOffset, pd.display.getWidth() - hOffset - self.margin)
    local y = clamp(p.y, self.margin + vOffset, pd.display.getHeight() - vOffset - self.margin)
    self:moveTo(x, y)

    -- pick the right image / orientation
    local left = arrowLeft.width / 2 + self.margin
    local right = pd.display.getWidth() - arrowRight.width / 2 - self.margin
    local top = arrowUp.height / 2 + self.margin
    local bottom = arrowUp.height / 2 - self.margin - pd.display.getHeight()

    if self.y == top and self.x > left and self.x < right then
        self:setImage(arrowUp)
    elseif self.x == left then
        self:setImage(arrowLeft)
    elseif self.x == right then
        self:setImage(arrowRight)
    end

    -- update visibility based on the animation state
    self:setVisible(self.anim.on)
end
