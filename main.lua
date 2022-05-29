import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry

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
for i = 1, numPoints, 1 do
	points[i] = geo.point.new(30, i - 1 + ((i - 1) * segLength))
	prevPoints[i] = geo.point.new(30, i - 1 + ((i - 1) * segLength))
end
local grav = geo.vector2D.new(0, 64)
local speed = 5

function pd.update()
	-- Sim
	for i = 2, #points, 1 do
		local vel = points[i] - prevPoints[i]
		prevPoints[i] = points[i]:copy()
		points[i] += vel
		points[i] += grav * 0.033
	end
	
	-- Controls
	if pd.buttonIsPressed(pd.kButtonLeft) then
		if points[1].x > 8 then
			points[1].x -= speed
		end
	elseif pd.buttonIsPressed(pd.kButtonRight) then
		if points[1].x < 400 - 8 then
			points[1].x += speed
		end
	end
	if pd.buttonIsPressed(pd.kButtonUp) then
		if points[1].y > -120 then
			points[1].y -= speed
		end
	elseif pd.buttonIsPressed(pd.kButtonDown) then
		if points[1].y < 0 then
			points[1].y += speed
		end
	end
	
	-- Constraints
	for n = 1, 1, 1 do
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
	
	-- Draw the lines
	gfx.clear()
	gfx.setLineWidth(3)
	gfx.setColor(gfx.kColorBlack)
	for i = 1, #points - 1, 1 do
		gfx.drawLine(points[i] .. points[i + 1])
	end
end

-- function setShakeAmount(amount)
-- 	screenShakeSprite:setShakeAmount(amount)
-- end
