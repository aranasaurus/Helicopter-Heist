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
    self:setCollideRect(0, 0, image:getSize())
end
