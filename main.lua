import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry

function clamp(n, low, high)
	return math.min(math.max(low, n), high)
end

local numPoints = 10
local segLength = 24
local chainLength = numPoints * segLength
local points = table.create(numPoints, 0)
local prevPoints = table.create(numPoints, 0)
local startPoint = geo.point.new(60, 0)
points[1] = startPoint
prevPoints[1] = points[1]:copy()
for i = 2, numPoints, 1 do
	points[i] = geo.point.new(startPoint.x, startPoint.y + i)
	prevPoints[i] = points[i]:copy()
end
local speed = 5
local grav = geo.vector2D.new(0, 9.8)

local constraintIterations = 5
local tickTime = 1/pd.display.getRefreshRate()
pd.setGCScaling(0, 0)
collectgarbage("generational")

-- Updates all points according to the movement of the first point. Should be called once per frame, after any updates to the first point's location.
function ropeSim()
	for i = 2, #points, 1 do
		-- calculate velocity using previous point
		local vel = points[i] - prevPoints[i]

		-- update previous point to current values (NOTE: this is setting the values not copying the points, which saves us some gc time)
		prevPoints[i].x = points[i].x
		prevPoints[i].y = points[i].y

		-- apply velocity and gravity to each point
		points[i] += vel
		points[i] += grav * tickTime
	end
end

-- Adjusts the locations of all the points with respect to their neighbors. Should be called at least once per update cycle. Calling it more than that will increase the accuracy of the simulation but decrease performance.
function applyConstraints()
	for i = 1, #points - 1, 1 do
		-- TODO: There is a fair amount of garbage being generated here, future me might want to optimize for that a bit later. When/if I get around to that, I think it'd be worth looking into storing the points as LineSegments instead of points.
		local lineVec = points[i] - points[i + 1]
		local dist = lineVec:magnitude()
		local error = math.abs(dist - segLength)
		local changeDir = geo.vector2D.new(0, 0)

		if dist > segLength then
			changeDir = (points[i + 1] - points[i]):normalized()
		elseif dist < segLength then
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

function drawChain()
	gfx.clear()
	gfx.setLineWidth(3)
	gfx.setColor(gfx.kColorBlack)
	for i = 1, #points - 1, 1 do
		if (points[i + 1].y >= -segLength or points[i + 1].y >= -segLength) and
			((points[i].x >= -8 or points[i + 1].x >= -8) and (points[i].x <= 408 or points[i + 1].x <= 408)) then
			gfx.drawLine(points[i].x, points[i].y, points[i + 1].x, points[i + 1].y)
		end
	end
end

function pd.update()
	-- Controls
	if pd.buttonIsPressed(pd.kButtonLeft) then
		points[1].x -= speed
	elseif pd.buttonIsPressed(pd.kButtonRight) then
		points[1].x += speed
	end
	points[1].x = clamp(points[1].x, 8, 400 - 8)

	ropeSim()

	for n = 1, constraintIterations, 1 do
		applyConstraints()
	end

	drawChain()
	pd.drawFPS()
end

pd.inputHandlers.push({
	cranked = function(change, acceleratedChange)
		local delta = -acceleratedChange / 360 * speed * 5
		points[1].y += delta
		points[1].y = clamp(points[1].y, -chainLength, chainLength / 2)
	end
})
