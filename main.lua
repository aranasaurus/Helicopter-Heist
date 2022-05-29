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

-- local player = Chain()

-- pd.inputHandlers.push({
-- 	cranked = function(change, acceleratedChange)
-- 		player:cranked(change, acceleratedChange)
-- 	end
-- })

-- local screenShakeSprite = ScreenShake()

local numPoints = 8
local segLength = 32
local points = table.create(numPoints, 0)
local prevPoints = table.create(numPoints, 0)
points[1] = geo.point.new(60, -120)
prevPoints[1] = points[1]:copy()
for i = 2, numPoints, 1 do
	points[i] = geo.point.new(60, i - 1 + ((i - 1) * segLength) - 120)
	prevPoints[i] = geo.point.new(60, i - 1 + ((i - 1) * segLength) - 120)
end
local grav = geo.vector2D.new(0, 64)
local speed = 5
local tickTime = 0.033


-- Updates all points according to the movement of the first point. Should be called once per frame, after any updates to the first point's location.
function ropeSim()
	for i = 2, #points, 1 do
		local vel = points[i] - prevPoints[i]
		prevPoints[i] = points[i]:copy()
		points[i] += vel
		points[i] += grav * tickTime
	end
end

-- Adjusts the locations of all the points with respect to their neighbors. Should be called at least once per update cycle. Calling it more than that will increase the accuracy of the simulation but decrease performance.
function applyConstraints()
	for i = 1, #points - 1, 1 do
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

-- Returns the length of the chain
function chainLength()
	return #points * segLength
end

function drawChain()
	gfx.clear()
	gfx.setLineWidth(3)
	gfx.setColor(gfx.kColorBlack)
	for i = 1, #points - 1, 1 do
		gfx.drawLine(points[i] .. points[i + 1])
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

	for n = 1, 2, 1 do
		applyConstraints()
	end

	drawChain()
end

pd.inputHandlers.push({
	cranked = function(change, acceleratedChange)
		local delta = -acceleratedChange / 360 * speed * 5
		points[1].y += delta
		points[1].y = clamp(points[1].y, -chainLength() + 16, -1)
	end
})

-- function setShakeAmount(amount)
-- 	screenShakeSprite:setShakeAmount(amount)
-- end
