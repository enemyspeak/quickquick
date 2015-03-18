		
local Shape = class('Shape')

Shape.static.SAFEZONE = 64		 --this is a class variable
Shape.static.KILLZONE = 256

Shape.static.COLOR1 = {1,0,1}		
Shape.static.COLOR2 = {8,38,53}	
Shape.static.COLOR3 = {6,24,39}	
				 
Shape.static.CENTERX = IRESX/2
Shape.static.CENTERY = IRESY/2

function Shape:initialize(attributes)
	local attributes = attributes or {}
	self.x = attributes.x or Shape.CENTERX + Shape.SAFEZONE
	self.y = attributes.y or Shape.CENTERY + Shape.SAFEZONE
	self.xsize = attributes.xsize or 10
	self.ysize = attributes.ysize or 10
	self.finished = false
	self.z = attributes.z or 1
	self.speed = attributes.speed or math.random(5,15)
end

function Shape:setPos(xpos,ypos)
	self.x = xpos
	self.y = ypos
end

function Shape:update(dt)	
	--if self.x < 0 then
		self.x = self.x - self.speed * dt
	--else
	--	self.x = self.x + self.speed * dt
	--end
	if value then else
		local cull = (Shape.CENTERX + Shape.KILLZONE)
		if self.x < -cull or self.x  > cull then
			self.finished = true
		end
		cull = (Shape.CENTERY + Shape.KILLZONE)
		if self.y < -cull or self.y  > cull then
			self.finished = true
		end
	end
end

function Shape:isOnScreen()
	self.onScreen = false
	if self.x < Shape.CENTERX+4 and self.x > -Shape.CENTERX-4 then
		if self.y < Shape.CENTERY+4 and self.y > -Shape.CENTERY-4 then
			self.onScreen = true
		end
	end
	return self.onScreen
end

function Shape:getKill()
	return self.finished
end

function Shape:setKill(value)
	self.finished = value
end

function Shape:getDistance(x,y)
	if x == nil or y == nil then 
		return (self.x)^2+(self.y)^2
	else
		return (self.x-x)^2+(self.y-y)^2
	end
end

function Shape:getPos()
	return self.x, self.y, self.z
end

function Shape:draw()
--	love.graphics.setColor(255,255,255,255)
	if self.z == 1 then
	 	r,g,b = unpack(Shape.COLOR1)
		love.graphics.setColor(r,g,b,128)
		love.graphics.rectangle("fill",self.x-self.xsize/2,self.y-self.ysize/2,self.xsize,self.ysize)
	elseif self.z == 2 then
		r,g,b = unpack(Shape.COLOR2)
		love.graphics.setColor(r,g,b,255)
		love.graphics.rectangle("fill",self.x-self.xsize/2,self.y-self.ysize/2,self.xsize,self.ysize)
	elseif self.z == 3 then
		r,g,b = unpack(Shape.COLOR3)
		love.graphics.setColor(r,g,b,255)
		love.graphics.rectangle("fill",self.x-self.xsize/2,self.y-self.ysize/2,self.xsize,self.ysize)
	end
end

return Shape
