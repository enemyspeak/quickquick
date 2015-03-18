		
local Blip = class('Blip')

Blip.static.SAFEZONE = 64		 --this is a class variable
Blip.static.KILLZONE = 256

Blip.static.COLOR1 = {252,163,100}	
				 
Blip.static.CENTERX = IRESX/2
Blip.static.CENTERY = IRESY/2

function Blip:initialize(attributes)
	local attributes = attributes or {}
	self.x = attributes.x or Blip.CENTERX + Blip.SAFEZONE
	self.y = attributes.y or Blip.CENTERY + Blip.SAFEZONE
	self.finished = false
	self.direction = math.random(0,1)
	self.speed = 20
	self.step = math.random(1.0,2.0)
	self.time = 0
end

function Blip:setPos(xpos,ypos)
	self.x = xpos
	self.y = ypos
end

function Blip:update(dt)	
	self.time = self.time + dt
	if self.direction == 1 then
		self.x = self.x + math.sin(self.step*self.time)
	else
		self.x = self.x - math.sin(self.step*self.time)
	end
	self.y = self.y + self.speed * dt
	if value then else
		local cull = (Blip.CENTERX + Blip.KILLZONE)
		if self.x < -cull or self.x  > cull then
			self.finished = true
		end
		cull = (Blip.CENTERY + Blip.KILLZONE)
		if self.y < -cull or self.y  > cull then
			self.finished = true
		end
	end
end

function Blip:isOnScreen()
	self.onScreen = false
	if self.x < Blip.CENTERX+4 and self.x > -Blip.CENTERX-4 then
		if self.y < Blip.CENTERY+4 and self.y > -Blip.CENTERY-4 then
			self.onScreen = true
		end
	end
	return self.onScreen
end

function Blip:getKill()
	return self.finished
end

function Blip:setKill(value)
	self.finished = value
end

function Blip:getDistance(x,y)
	if x == nil or y == nil then 
		return (self.x)^2+(self.y)^2
	else
		return (self.x-x)^2+(self.y-y)^2
	end
end

function Blip:getPos()
	return self.x, self.y, self.z
end

function Blip:draw()
	if self.type == 1 then
		love.graphics.setColor(115,127,130,255)	
	else
		--love.graphics.setColor(157,170,179,255)	
		love.graphics.setColor(201,210,217,255)	
	end

	love.graphics.point(self.x,self.y)
end

return Blip
