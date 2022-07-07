import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry

class("Loot").extends(gfx.sprite)

function Loot:init(x, y, i)
    local image = gfx.image.new("images/loot" .. string.format("%03d", i))
    self:setImage(image)
    self:moveTo(x, y)
    self:add()
    local w, h = image:getSize()
    self:setCollideRect(0, 0, w, h / 2)
    self.hooked = false
    self.prevX = x
    self.prevY = y
end

function Loot:update()
    local velocity = geo.vector2D.new(self.x - self.prevX, self.y - self.prevY):scaledBy(0.97)
    self.prevX = self.x
    self.prevY = self.y

    if not self.hooked then
        self:moveBy(velocity.x, velocity.y)

        if not shouldDrawSprite(self) then
            self:setCenter(0.5, 0.5)
            local w, h = self:getImage():getSize()
            self:setCollideRect(0, 0, w, h/2)
            self:moveTo(pd.display.getWidth() / 2, pd.display.getHeight() / 2)
            self:setRotation(0)
            self.prevX = pd.display.getWidth() / 2
            self.prevY = pd.display.getHeight() / 2
        end
    end

    Loot.super.update(self)
end
