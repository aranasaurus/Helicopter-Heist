import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry
local vector2D <const> = geo.vector2D
local point <const> = geo.point

class("ChainSegment").extends(gfx.sprite)

function ChainSegment:init(p)
	local image = gfx.image.new("images/chain")
	self:setImage(image)
	-- self:setCenter(0.5, 0.0)
	self:moveTo(p)
	self:add()
	
	self.prevPoint = p:copy()
	self.point = p:copy()
end

class("Chain").extends()

function Chain:init()
	-- each chain sprite is 8x30
	self.segLength = 30
	
	-- (240 / 30) + 1, make the chain long enough to cover the screen vertically
	local numSegments = 9  
	self.segments = table.create(numSegments, 0)
	
	-- start with the hook near the center vertically
	local pos = point.new(30, 0)
	self.x, self.y = pos:unpack()
	
	for i = 1, numSegments, 1 do
		self.segments[i] = ChainSegment(pos)
		pos.y += self.segLength
	end
	
	self.speed = 5
end

function Chain:update()
	if pd.buttonIsPressed(pd.kButtonLeft) then
		if self.x > 8 then
			self:moveBy(-self.speed, 0)
		end
	elseif pd.buttonIsPressed(pd.kButtonRight) then
		if self.x < 400 - 8 then
			self:moveBy(self.speed, 0)
		end
	end
end

function Chain:cranked(change, acceleratedChange)
	-- local delta = -change / 360 * self.speed 
	-- if (self.y > 24 and delta < 0) or (self.y < 240 and delta > 0) then
	-- 	self:moveBy(0, delta)
	-- end
end

local grav = vector2D.new(0, 1) * 0.033

function Chain:moveBy(x, y)
	self.x += x
	self.y += y
	self.segments[1].point.x += x
	self.segments[1].point.y += y
	for i, segment in ipairs(self.segments) do
		local vel = segment.point - segment.prevPoint
		segment.prevPoint = segment.point:copy()
		segment.point += vel + grav
		segment:moveTo(segment.point)
	end
	
	local segLength = self.segLength
	for _ = 1, 50, 1 do
		for i, segment in ipairs(self.segments) do
			if i >= #self.segments then
				break
			end
			local next = self.segments[i+1]
			local dist = segment.point:distanceToPoint(next.point)
			local error = math.abs(dist - segLength)
			local changeDir = vector2D.new(0, 0)
			
			if dist > segLength then
				changeDir = (segment.point - next.point):normalized()
			elseif (dist < segLength) then
				changeDir = (next.point - segment.point):normalized()
			end
			
			local changeAmount = changeDir * error
			if i ~= 1 then
				segment.point -= changeAmount * 0.5
				next.point += changeAmount * 0.5
			else
				next.point += changeAmount
			end
			
			local startV = vector2D.new(segment.point.x, segment.point.y)
			local endV = vector2D.new(next.point.x, next.point.y)
			segment:setRotation(startV:angleBetween(endV))
			segment:moveTo(segment.point:unpack())
			next:moveTo(next.point:unpack())
		end
	end
end
