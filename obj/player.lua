
local Player = class('Player')

Player.static.WIDTH = IRESX
Player.static.HEIGHT = IRESY
Player.static.CENTERX = Player.WIDTH/2
Player.static.CENTERY = Player.HEIGHT/2
Player.static.COLOR1 = {255,255,255,255}
Player.static.COLOR2 = {235,165,118}
Player.static.COLOR3 = {86,73,109}
Player.static.gravity = 600
Player.static.MAXYSPEED = 600
Player.static.STANDING = love.graphics.newImage("res/11.png")
Player.static.RUNNING1 = love.graphics.newImage("res/2.png")
Player.static.RUNNING2 = love.graphics.newImage("res/33.png")
Player.static.RUNNING3 = love.graphics.newImage("res/44.png")
Player.static.FALLING = love.graphics.newImage("res/55.png")

function Player:initialize(attributes)
	local attributes = attributes or {}
	self.x = attributes.x or 0
	self.y = attributes.y or 0

	self.xVel = 0
	self.yVel = 0

	self.width = 24
	self.height = 24
	
	self.normalAcceleration = 200
	
	self.drag_active = 0.9
	self.drag_passive = 0.7
	
	self.maxSpeed = 225 --800
	self.maxSpeed_sq = self.maxSpeed * self.maxSpeed

	self.jumpTime = 0.1
	self.maxJump = 0.1
	self.jumpHeight = 275
	self.collide = false

	self.state = "Standing"
	self.animationCounter = 1 
end

function Player:update(dt, input,level)
	local dt = dt
	local input = input
	local level = level
	local function magnitude_2d(x, y)
		return math.sqrt(x*x + y*y)
	end

	local function round(num, idp)
		local mult = 10^(idp or 0)
		return math.floor(num * mult + 0.5) / mult
	end

	local function magnitude_2d_sq(x, y)
		return x*x + y*y
	end

	local function normalize_2d(x, y)
		local mag = magnitude_2d(x, y)
		if mag == 0 then return {0,0} end
		return {x/mag, y/mag}
	end

	local tempXAccel = 0
	local tempYAccel = 0

	if (input.left and (not input.right)) then 
		tempXAccel = -1
		self.state = "RunningL"
	elseif (input.right and (not input.left)) then 
		tempXAccel = 1 
		self.state = "RunningR"
	end
	
	if tempXAccel == 0 then
		self.state = "Standing"
	end
	
	local tempNormAccel = normalize_2d(tempXAccel,tempYAccel)
	tempXAccel = tempNormAccel[1]*self.normalAcceleration
	
	local tempXVel = self.xVel
	local tempYVel = 0
	local curSpeed = magnitude_2d(self.xVel,0)
		
	if ((self.normalAcceleration + curSpeed) > self.maxSpeed) then
		local accelMagnitude = self.maxSpeed - curSpeed
		if (accelMagnitude < 0) then accelMagnitude = 0 end

		tempXAccel = tempNormAccel[1]*accelMagnitude
	--	tempYAccel = tempNormAccel[2]*accelMagnitude
	end

	tempXVel = tempXVel + tempXAccel
	--tempYVel = tempYVel + tempYAccel

	temp_vel = magnitude_2d_sq(tempXVel, 0)

	if(math.abs(temp_vel) > self.maxSpeed_sq) then
		tempXVel = self.xVel
	--	tempYVel = self.yVel
	end

	temp_drag = self.drag_passive

	if (input.x_has_input or input.y_has_input) then
		temp_drag = self.drag_active
	end

	self.xVel = tempXVel * temp_drag
	if self.xVel ~= 0 then  
		local gridw = level:getGridw()
		local k 
		local i = math.abs(self.xVel) * dt
		if self.xVel > 0 then k = 1 else k = -1 end
	
	end
	local x = self.x + Player.CENTERX + level:getGridw() - 12
	local y = self.y + Player.CENTERY + level:getGridw() - 12
	if level:check(x+self.xVel*dt,y,self.width,self.height) then else
		self.x = self.x + self.xVel*dt
	end
--[[
	if self.y > Player.CENTERY then 	-- this is where collision detection would happen.
		self.y = -Player.CENTERY
	end
	]]
	if self.jumpTime > 0 and (input.up and (not input.down)) then	-- jump!
		self.jumpTime = self.jumpTime - dt
		self.yVel = self.yVel - self.jumpHeight * (dt / self.maxJump)
		self.collide = false
	end

	y = self.y + Player.CENTERY + self.yVel * dt + level:getGridw() - 12
	player:setCollide(level:check(x,y,self.width,self.height))

	if self.collide then
		self.yVel = 0
		self.jumpTime = self.maxJump
	else
		self.y = self.y + self.yVel*dt
		self.yVel = self.yVel + Player.gravity * dt
		if self.yVel > Player.MAXYSPEED then
			self.yVel = Player.MAXYSPEED
		end
	end
	if math.abs(self.yVel) < 100 then else
		self.state = "Falling"
	end
end

function Player:getYVel()
	return self.yVel
end

function Player:getPos()
	return self.x,self.y
end

function Player:setPos(x,y)
	self.x = x
	self.y = y
end	

function Player:getCollide()
	return self.collide
end

function Player:setCollide(value)
	self.collide = value
end

function Player:draw()
	love.graphics.setColor(255,255,255,255)
--	love.graphics.rectangle("line",self.x-12,self.y-12,24,24)
---[[
	if self.state == "Standing" then
		love.graphics.draw(Player.STANDING,self.x,self.y,0,1,1,10,12)
	elseif self.state == "RunningR" or self.state == "RunningL" then
		local d
		if self.state == "RunningR" then
			d = 1
		else
			d = -1
		end
		if self.animationCounter > 4 then self.animationCounter = 1 end
		if math.floor(self.animationCounter) == 1 then
			love.graphics.draw(Player.RUNNING1,self.x,self.y,0,d,1,12,10)
		elseif math.floor(self.animationCounter) == 2 then--or  math.floor(self.animationCounter) == 4 then
			love.graphics.draw(Player.RUNNING2,self.x,self.y,0,d,1,12,11)
		elseif math.floor(self.animationCounter) == 3 then
			love.graphics.draw(Player.RUNNING3,self.x,self.y,0,d,1,12,10)
		end
		self.animationCounter = self.animationCounter + 0.20
	elseif self.state == "Falling" then
		love.graphics.draw(Player.FALLING,self.x,self.y,0,d,1,12,12)
	end
--]]

end

return Player
