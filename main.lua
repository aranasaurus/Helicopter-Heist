import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry
local vector2D <const> = geo.vector2D

function clamp(n, low, high)
	return math.min(math.max(low, n), high)
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
local chainLength = kNumPoints * kSegLength
local points = table.create(kHookPoint, 0)
local prevPoints = table.create(kHookPoint, 0)
local startPoint = geo.point.new(60, -kSegLength)
local chainImage = gfx.image.new("images/chain")
local chainSprites = table.create(kNumPoints, 0)
local hookImage = gfx.image.new("images/hook")
local hook = gfx.sprite.new(hookImage)

function initialize()
	for i = 1, kNumPoints, 1 do
		points[i] = startPoint:copy()
		prevPoints[i] = points[i]:copy()
		chainSprites[i] = gfx.sprite.new(chainImage)
		chainSprites[i]:add()
		chainSprites[i]:moveTo(points[i].x, points[i].y)
		chainSprites[i]:setCenter(0.5, 0)
	end
	points[kHookConnectionPoint] = points[kNumPoints]:copy()
	prevPoints[kHookConnectionPoint] = points[kHookConnectionPoint]:copy()
	points[kHookPoint] = points[kHookConnectionPoint] + vector2D.new(0, kSegLength)
	prevPoints[kHookPoint] = points[kHookPoint]:copy()
	hook:add()
	hook:moveTo(startPoint.x, startPoint.y + kSegLength)
	hook:setCenter(0.5, 0)

	-- Use all extra time per frame to run the garbage collector
	pd.setGCScaling(0, 0)

	-- Use the Lua GC mode that's optimized for short lived tiny objects
	collectgarbage("generational")
end

-- Updates all points according to the movement of the first point. Should be called once per frame, after any updates to the first point's location.
function ropeSim()
	for i = 2, #points, 1 do
		-- calculate velocity using previous point
		local vel = points[i] - prevPoints[i]
		vel.x *= 1 - kDragFactor.x
		vel.y *= 1 - kDragFactor.y

		-- update previous point to current values (NOTE: this is setting the values not copying the points, which saves us some gc time)
		prevPoints[i].x = points[i].x
		prevPoints[i].y = points[i].y

		-- apply velocity and gravity to each point
		points[i] += vel
		points[i] += kGravity * kTickTime
	end

	-- Make hook "heavier" by applying more gravity to it
	points[kHookConnectionPoint] += kGravity * kTickTime * 0.25
	points[kHookPoint] += kGravity * kTickTime
end

-- Adjusts the locations of all the points with respect to their neighbors. Should be called at least once per update cycle. Calling it more than that will increase the accuracy of the simulation but decrease performance.
function applyConstraints()
	for i = 1, #points - 1, 1 do
		-- TODO: There is a fair amount of garbage being generated here, future me might want to optimize for that a bit later. When/if I get around to that, I think it'd be worth looking into storing the points as LineSegments instead of points.
		local lineVec = points[i] - points[i + 1]
		local dist = lineVec:magnitude()
		local error = math.abs(dist - kSegLength)
		local changeDir = geo.vector2D.new(0, 0)

		if dist > kSegLength then
			changeDir = (points[i + 1] - points[i]):normalized()
		elseif dist < kSegLength then
			changeDir = lineVec:normalized()
		end

		local changeAmount = changeDir * error
		if i == 1 then
			points[i + 1] -= changeAmount
		else
			points[i] += changeAmount * 0.5
			points[i + 1] -= changeAmount * 0.5
		end
	end
end

function shouldDrawPoint(p)
	return p.y <= 240 + kSegLength and p.y >= -kSegLength and p.x >= -kSegLength and p.x <= 400 + kSegLength
end

function drawChain()
	local up = vector2D.new(0, 1)
	for i = 1, kNumPoints, 1 do
		chainSprites[i]:moveTo(points[i].x, points[i].y)
		if shouldDrawPoint(points[i]) or shouldDrawPoint(points[i+1]) then
			chainSprites[i]:setRotation(up:angleBetween(points[i+1] - points[i]))
		end
	end

	hook:moveTo(points[kHookConnectionPoint].x, points[kHookConnectionPoint].y)
	if shouldDrawPoint(points[kHookConnectionPoint]) or shouldDrawPoint(points[kHookPoint]) then
		hook:setRotation(up:angleBetween(points[kHookPoint] - points[kHookConnectionPoint]))
	end
end

function pd.update()
	-- Controls
	if pd.buttonIsPressed(pd.kButtonLeft) then
		points[1].x -= kSpeed
	elseif pd.buttonIsPressed(pd.kButtonRight) then
		points[1].x += kSpeed
	end
	points[1].x = clamp(points[1].x, 8, 400 - 8)

	ropeSim()

	for n = 1, kIterationCount, 1 do
		applyConstraints()
	end

	drawChain()
	gfx.sprite.update()
	pd.drawFPS()
end

pd.inputHandlers.push({
	cranked = function(change, acceleratedChange)
		local delta = -acceleratedChange / 360 * kSpeed * 6
		points[1].y += delta
		points[1].y = clamp(points[1].y, -chainLength + hook.height / 2, 0)
	end
})

initialize()
