local pd <const> = playdate
local gfx <const> = pd.graphics

class("Player").extends(gfx.sprite)

function Player:init(x, y)
	local hook = gfx.image.new("images/hook")
	self:setImage(hook)
	self:setCenter(0.5, 1)
	self:moveTo(x, y)
	-- self:add()
	
	self.speed = 3
end

function Player:update()
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

function Player:cranked(change, acceleratedChange)
	local delta = -change / 360 * self.speed * 5
	if (self.y > 24 and delta < 0) or (self.y < 240 and delta > 0) then
		self:moveBy(0, delta)
	end
end

function Player:move(x)
	-- Create 4 arrays of numbers:
	--   String1_X (0 to 31)
	--   String1_Y (0 to 31)
	--   String2_X (0 to 31)
	--   String2_Y (0 to 31)
	-- 
	-- Initialise all the points in String_X() and String_Y():
	-- 
	--   Loop i from 0 to 31
	-- 	  String1_X (i) = 0
	-- 	  String1_Y (i) = i
	--   end of loop
	-- 
	--   Loop Forever
	-- 
	-- 	  Loop i from 0 to 31
	-- 
	-- 		  X_vector1 = String1_X(i- 1) - String1_X(i)
	-- 		  Y_vector1 = String1_Y(i - 1) - String1_Y(i)
	-- 		  Magnitude1 = LengthOf (X_Vector1, Y_Vector1)
	-- 		  Extension1 = Magnitude1 - Normal_Length
	-- 
	-- 		  X_vector2 = String1_X(i + 1) - String1_X(i)
	-- 		  Y_vector2 = String1_Y(i + 1) - String1_Y(i)
	-- 		  Magnitude2 = LengthOf(X_Vector2, Y_Vector2)
	-- 		  Extension2 = Magnitude2 - Normal_Length
	-- 
	-- 		  xv = (X_Vector1 / Magnitude1 * Extension1) + (X_Vector2 / Magnitude2 * Extension2)
	-- 		  yv = (Y_Vector1 / Magnitude1 * Extension1) + (Y_Vector2 / Magnitude2 * Extension2) + Gravity
	-- 
	-- 		  String2_X(i) = String1_X(i) + (xv * .01)
	-- 		  String2_Y(i) = String1_Y(i) + (yv * .01)
	-- 	  (Note you can use what ever value you like instead of .01)
	-- 	
	-- 	  end of loop
	-- 
	-- 	  Copy all of String2_X to String1_X
	-- 	  Copy all of String2_Y to String1_Y
	-- 	  Draw lines between all adjacent points
	-- 
	-- end of LoopForever
end
