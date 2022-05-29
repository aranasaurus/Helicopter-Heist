import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "chain"
import "screenShake"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry

local player = Chain()

pd.inputHandlers.push({
	cranked = function(change, acceleratedChange)
		player:cranked(change, acceleratedChange)
	end
})

local screenShakeSprite = ScreenShake()

function pd.update()
	player:update()
	gfx.sprite.update()
	pd.timer.updateTimers()
end

function setShakeAmount(amount)
	screenShakeSprite:setShakeAmount(amount)
end
