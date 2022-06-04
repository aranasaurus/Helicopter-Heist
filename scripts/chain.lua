import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry
local vector2D <const> = geo.vector2D

class("Chain").extends(gfx.sprite)

-- Constants
local kGravity = vector2D.new(0, 9.80)
local kTickTime = 1/pd.display.getRefreshRate()

function Chain:init(x, y, numPoints, segLength)
    self.speed = 5
    self.dragFactor = vector2D.new(0.0125, 0.025)
    self.iterationCount = 5

    self.numPoints = numPoints
    self.hookConnectionPointIdx = numPoints + 1
    self.hookPointIdx = self.hookConnectionPointIdx + 1
    self.segLength = segLength

    local chainImage = gfx.image.new("images/chain")
    local hookImage = gfx.image.new("images/hook")

    -- TODO: Can the points and prevPoints tables be removed by just using chainSprites?
    self.points = table.create(hookPointIdx, 0)
    self.prevPoints = table.create(hookPointIdx, 0)
    self.chainSprites = table.create(numPoints, 0)
    self.hook = gfx.sprite.new(hookImage)

    self.maxChainLength = numPoints * segLength + self.hook.height

    for i = 1, numPoints, 1 do
        self.points[i] = geo.point.new(x, y)
        self.prevPoints[i] = self.points[i]:copy()
        self.chainSprites[i] = gfx.sprite.new(chainImage)
        self.chainSprites[i]:add()
        self.chainSprites[i]:moveTo(self.points[i].x, self.points[i].y)
        self.chainSprites[i]:setCenter(0.5, 0)
    end

    self.points[self.hookConnectionPointIdx] = self.points[numPoints]:copy()
    self.prevPoints[self.hookConnectionPointIdx] = self.points[self.hookConnectionPointIdx]:copy()
    self.points[self.hookPointIdx] = self.points[self.hookConnectionPointIdx] + vector2D.new(0, segLength)
    self.prevPoints[self.hookPointIdx] = self.points[self.hookPointIdx]:copy()

    self.hook:add()
    self.hook:moveTo(x, y + segLength)
    self.hook:setCenter(0.5, 0)

    self:add()
end

-- Updates all points according to the movement of the first point. Should be called once per frame, after any updates to the first point's location.
function Chain:simStep()
    for i = 2, #self.points, 1 do
        -- calculate velocity using previous point
        local vel = self.points[i] - self.prevPoints[i]
        vel.x *= 1 - self.dragFactor.x
        vel.y *= 1 - self.dragFactor.y

        -- update previous point to current values (NOTE: this is setting the values not copying the points, which saves us some gc time)
        self.prevPoints[i].x = self.points[i].x
        self.prevPoints[i].y = self.points[i].y

        -- apply velocity and gravity to each point
        self.points[i] += vel
        self.points[i] += kGravity * kTickTime
    end

    -- Make hook "heavier" by applying more gravity to it
    self.points[self.hookConnectionPointIdx] += kGravity * kTickTime * 0.25
    self.points[self.hookPointIdx] += kGravity * kTickTime
end

-- Adjusts the locations of all the points with respect to their neighbors. Should be called at least once per update cycle. Calling it more than that will increase the accuracy of the simulation but decrease performance.
function Chain:applyConstraints()
    for i = 1, #self.points - 1, 1 do
        -- TODO: There is a fair amount of garbage being generated here, future me might want to optimize for that a bit later. When/if I get around to that, I think it'd be worth looking into storing the points as LineSegments instead of points.
        local lineVec = self.points[i] - self.points[i + 1]
        local dist = lineVec:magnitude()
        local error = math.abs(dist - self.segLength)
        local changeDir = geo.vector2D.new(0, 0)

        if dist > self.segLength then
            changeDir = (self.points[i + 1] - self.points[i]):normalized()
        elseif dist < self.segLength then
            changeDir = lineVec:normalized()
        end

        local changeAmount = changeDir * error
        if i == 1 then
            self.points[i + 1] -= changeAmount
        else
            self.points[i] += changeAmount * 0.5
            self.points[i + 1] -= changeAmount * 0.5
        end
    end
end

function Chain:moveBy(dx, dy)
    -- Keep the chain/hook within reach of the screen
    self.points[1].y = clamp(self.points[1].y + dy, -self.maxChainLength + self.hook.height, 0)
    self.points[1].x = clamp(self.points[1].x + dx, 8, 400 - 8)
end

function Chain:update()
    local up = vector2D.new(0, 1)
    for i = 1, self.numPoints, 1 do
        self.chainSprites[i]:moveTo(self.points[i].x, self.points[i].y)
        if shouldDrawSprite(self.chainSprites[i]) then
            self.chainSprites[i]:setRotation(up:angleBetween(self.points[i+1] - self.points[i]))
        end
    end

    self.hook:moveTo(self.points[self.hookConnectionPointIdx].x, self.points[self.hookConnectionPointIdx].y)
    if shouldDrawSprite(self.hook) then
        self.hook:setRotation(up:angleBetween(self.points[self.hookPointIdx] - self.points[self.hookConnectionPointIdx]))
    end

    self:simStep()

    for n = 1, self.iterationCount, 1 do
        self:applyConstraints()
    end

    Chain.super.update(self)
end
