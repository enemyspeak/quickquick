		
local Circle = class('Circle')

Circle.static.SAFEZONE = 64		 --this is a class variable
Circle.static.KILLZONE = 256

Circle.static.COLOR1 = {1,0,1}		
Circle.static.COLOR2 = {8,38,53}	
Circle.static.COLOR3 = {6,24,39}	
				 
Circle.static.CENTERX = IRESX/2
Circle.static.CENTERY = IRESY/2

function Circle:initialize(attributes)
	local attributes = attributes or {}
	self.x = attributes.x or Circle.CENTERX + Circle.SAFEZONE
	self.y = attributes.y or Circle.CENTERY + Circle.SAFEZONE
	self.scale = math.random(0.2,1)
	self.finished = false
	self.direction = math.random(0,1)
	self.speed = attributes.speed or math.random(35,65)
	self.step = math.random(1.0,2.0)
	self.type = math.random(0,1)
	self.time = 0
end

function Circle:setPos(xpos,ypos)
	self.x = xpos
	self.y = ypos
end

function Circle:update(dt)	
	self.time = self.time + dt
	if self.direction > 0.5 then
		self.x = self.x + math.sin(self.step*self.time)
	else
		self.x = self.x - math.sin(self.step*self.time)
	end
	self.y = self.y + (self.speed - math.sin(2*self.step*self.time+3) )* dt
	if value then else
		local cull = (Circle.CENTERX + Circle.KILLZONE)
		if self.x < -cull or self.x  > cull then
			self.finished = true
		end
		cull = (Circle.CENTERY + Circle.KILLZONE)
		if self.y < -cull or self.y  > cull then
			self.finished = true
		end
	end
end

function Circle:isOnScreen()
	self.onScreen = false
	if self.x < Circle.CENTERX+4 and self.x > -Circle.CENTERX-4 then
		if self.y < Circle.CENTERY+4 and self.y > -Circle.CENTERY-4 then
			self.onScreen = true
		end
	end
	return self.onScreen
end

function Circle:getKill()
	return self.finished
end

function Circle:setKill(value)
	self.finished = value
end

function Circle:getDistance(x,y)
	if x == nil or y == nil then 
		return (self.x)^2+(self.y)^2
	else
		return (self.x-x)^2+(self.y-y)^2
	end
end

function Circle:getPos()
	return self.x, self.y, self.z
end

function Circle:draw()
	if self.type > 0.5 then
		if self.direction  > 0.25 then
			love.graphics.setColor(115,127,130,155)	
			love.graphics.point(self.x,self.y)
		else
			love.graphics.setColor(115,127,130,55/(self.scale*10))	
			love.graphics.draw(graphics["glow"],self.x,self.y,0,self.scale,self.scale,20,20)	
		end
	else
		if self.direction > 0.25 then
			love.graphics.setColor(201,210,217,155)	
			love.graphics.point(self.x,self.y)
		else
			love.graphics.setColor(201,210,217,55/(self.scale*10))	
			love.graphics.draw(graphics["glow"],self.x,self.y,0,self.scale,self.scale,20,20)
		end
	end

end

return Circle
