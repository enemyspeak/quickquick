		
local Hole = class('Hole')

Hole.static.SAFEZONE = 64		 --this is a class variable
Hole.static.KILLZONE = 256

Hole.static.COLOR1 = {1,0,1}		
Hole.static.COLOR2 = {8,38,53}	
Hole.static.COLOR3 = {6,24,39}	
				 
Hole.static.CENTERX = IRESX/2
Hole.static.CENTERY = IRESY/2

Hole.static.KILLZONE = Hole.CENTERX*3


function Hole:initialize(attributes)
	local attributes = attributes or {}
	self.x = attributes.x or Hole.CENTERX + Hole.SAFEZONE
	self.y = attributes.y or Hole.CENTERY + Hole.SAFEZONE
	self.scale = attributes.scale or math.random(1,10)
	self.finished = false
	self.speed = attributes.speed or math.random(5,25)
	self.type = 1
end

function Hole:setPos(xpos,ypos)
	self.x = xpos
	self.y = ypos
end

function Hole:update(dt)	
	self.scale = self.scale + self.speed*dt

	local cull = (Hole.CENTERX + Hole.KILLZONE)
	if self.x < -cull or self.x  > cull then
		self.finished = true
	end
	cull = (Hole.CENTERY + Hole.KILLZONE)
	if self.y < -cull or self.y  > cull then
		self.finished = true
	end
end

function Hole:isOnScreen()
	self.onScreen = false
	if self.x < Hole.CENTERX+4 and self.x > -Hole.CENTERX-4 then
		if self.y < Hole.CENTERY+4 and self.y > -Hole.CENTERY-4 then
			self.onScreen = true
		end
	end
	return self.onScreen
end

function Hole:getKill()
	return self.finished
end

function Hole:setKill(value)
	self.finished = value
end

function Hole:getDistance(x,y)
	if x == nil or y == nil then 
		return (self.x)^2+(self.y)^2
	else
		return (self.x-x)^2+(self.y-y)^2
	end
end

function Hole:getPos()
	return self.x, self.y, self.z
end

function Hole:getScale( ... )
	return self.scale
end



function Hole:getState(xpos,ypos, value) 
	local value = value or 0
	local temp = false
	if ( self.x - xpos ) ^ 2 + ( self.y - ypos ) ^ 2 < (self.scale - value) ^ 2 then		-- Within Circle (x-a)^2 + (y-b)^2 = r ^2
		temp = true
	end
	return temp
end

function Hole:draw()
	local mode = self.type

	if mode == 1 then
		local f = function()
			local jitterx = math.random(-2,2) 
			local jittery = math.random(-2,2)
			love.graphics.circle("fill",self.x+jitterx,self.y+jittery,self.scale)
		end

		love.graphics.setStencil(f)
		love.graphics.setColor(225,155,33,255)	
			love.graphics.circle("fill",self.x,self.y,self.scale+15)
		
			love.graphics.setColor(201,210,217,155/(self.scale*10))	
			--love.graphics.draw(graphics["glow"],self.x,self.y,0,self.scale,self.scale,20,20)
		love.graphics.setStencil()
	else
		love.graphics.setColor(225,155,33,255)	
		if self.x < 0 then
			love.graphics.rectangle("fill",-Hole.CENTERX,self.y,self.scale*4,16)
		else
			love.graphics.rectangle("fill",Hole.CENTERX,self.y,-self.scale*4,16)
		end
	end
end

return Hole
