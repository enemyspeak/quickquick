
local Game = Gamestate:addState('Game')

local Player =  require 'obj.player'
local Level = require 'obj.level'
local Shape = require 'obj.shapes'
local Hole = require 'obj.holes'

local WIDTH = IRESX
local HEIGHT = IRESY
local CENTERX = WIDTH/2
local CENTERY = HEIGHT/2

local mx,my

local STARTINGSHAPES = 25
local shapeBuffer

local level 
local oldLevel

local input = {}
local joysticks = {}
local shapes = {}
local holes = {}

local gameTween =	{
					translateX = 0,
					translateY = 0,
					gameScale = 1,--0.5,
					tweenToggle = 0,
					dummyVariable = true
					}

local function op_xor(a, b)
	return ((a or b) and (not (a and b)))
end

local function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

local function magnitude_2d_sq(x, y)
	return x*x + y*y
end

local function getShapeAttributes()
	local n = math.random(1,6)
	for i,v in ipairs(shapes) do
		shapes[i]:draw()
	end
end

local function updateInput()
	input.x_has_input = false
	input.y_has_input = false

	input.left = false
	input.right = false
	input.up = false
	input.down = false

	input.left = love.keyboard.isDown("left") or love.keyboard.isDown("a")
	input.right = love.keyboard.isDown("right") or love.keyboard.isDown("d")
	input.up = love.keyboard.isDown("up") or love.keyboard.isDown(" ") or love.keyboard.isDown("w")
	input.down = love.keyboard.isDown("down") or love.keyboard.isDown("s")

--[[			-- controller stuff goes here
	input.left = 
	input.right = 
	input.up = 
	input.down = 
]]

	input.x_has_input = op_xor(input.right, input.left)
	input.y_has_input = op_xor(input.up, input.down)
end

local function updateRoom()
	local x,y = player:getPos()
	local h = level:getGridh()
	local YSize = level:getYSize()
	y =	math.floor((y-12+CENTERY) / h) 
	if y > YSize-2 then
		gameTween.translateX = 0
		gameTween.translateY = CENTERY*2
		gameScore = gameScore + 1

		oldLevel = level
		oldLevel:setPos(0,-CENTERY*2)
		local numLevels = 10
		level = Level:new({x = 0, y = 0,levelNumber = math.random(1,numLevels)})

		for i,v in ipairs(holes) do
			local x,y = holes[i]:getPos()
			holes[i]:setPos(x,y-CENTERY*2)
		end
		
		local temp = level:getHoles()
		for i = 1, #temp do
			holes[#holes+1] =  Hole:new({ x = temp[i][1], y = temp[i][2]})
		end

		local x,y = player:getPos()
		player:setPos(x,y-CENTERY*2)

		gameTween.tweenToggle = 1
		gameTween.dummyVariable = true
	end
end

local function tweenRoom()
	if gameTween.dummyVariable then
		tween(0.5,gameTween,{translateY=0},"inOutSine",
			tween,0.10,gameTween,{tweenToggle=0},"linear")
		gameTween.dummyVariable = false
	end
end

local function updateHoles(dt)
	local cx,cy = player:getPos()
	for i,v in ipairs(holes) do
		if holes[i]:getState(cx,cy,-10) then
			gamestate:gotoState("Gameover")
		end
		holes[i]:update(dt)
		if holes[i]:getKill() == true then
			table.remove(holes,i)
			i = i - 1 -- uhh
		end
	end
end

local function updateShapes(dt)
	for i,v in ipairs(shapes) do
		shapes[i]:update(dt, value)
		if shapes[i]:getKill() == true then
			table.remove(shapes,i)
			i = i - 1 -- uhh
		end
	end

	local interval = 4
	local rate = 2

	if shapeBuffer > interval then
		shapeBuffer = 0
		local x = CENTERX + Shape.SAFEZONE
		local y = math.random(-CENTERY,CENTERY)
		shapes[#shapes + 1] = Shape:new({x = x, y = y, z = math.random(1,3), xsize = math.random(70,120), ysize = math.random(10,30) }) 
	end
	
	shapeBuffer = shapeBuffer + rate*dt
end

local function drawShapes(value)
	local value = value
	for i,v in ipairs(shapes) do
		local x,y,z = shapes[i]:getPos()
		if z == value then
			shapes[i]:draw()
		end
	end
end



local function drawGlow(value)
	local value = value or 0
	local r,g,b = unpack(colors["shadow"])
	love.graphics.setColor(r,g,b,220)
	love.graphics.draw(graphics["glow"],0,value,0,10,10,20,20)
end


local function drawLevel()
	local x,y = player:getPos()
	local levelStencil = function()
		love.graphics.circle("fill",x,y,130)	
	end
	
	love.graphics.setStencil(levelStencil)
	--love.graphics.setColor(104,90,75,255)
	--love.graphics.circle("fill",x,y,130)
		level:draw()
		if oldLevel ~= nil then
			oldLevel:draw()
		end
	love.graphics.setStencil()
end

local function drawHoles( ... )
	for i,v in ipairs(holes) do
		holes[i]:draw()
	end
end


------------------------------------------------------------------------------------------









function Game:enteredState()	
	input = {}
	player = Player:new({x= 0, y = 0})
	level = Level:new()
	gameScore = 0

	mx = 0
	my = 0

--[[
	for i = 1, STARTINGSHAPES do
		shapes[i] =  Shape:new({ x = math.random(-CENTERX-Shape.KILLZONE,CENTERX+Shape.SAFEZONE), y = math.random(-CENTERY,CENTERY), xsize = math.random(30,120), ysize = math.random(4,30)}) 
	end
	for i = 1, STARTINGSHAPES do
		shapes[#shapes+1] =  Shape:new({ x = math.random(-CENTERX-Shape.KILLZONE,CENTERX+Shape.SAFEZONE), y = math.random(-CENTERY,CENTERY), z = 2, xsize = math.random(30,120), ysize = math.random(4,30)}) 
	end
	for i = 1, STARTINGSHAPES/2 do
		shapes[#shapes+1] =  Shape:new({ x = math.random(-CENTERX-Shape.KILLZONE,CENTERX+Shape.SAFEZONE), y = math.random(-CENTERY,CENTERY), z = 3, xsize = math.random(30,120), ysize = math.random(4,30)}) 
	end
	]]
	--shapeBuffer = 0

	holes = {}
end

function Game:exitedState()
	hs:add("a", gameScore)
	tween.stopAll() --stops all animations, without resetting any values
end

function Game:update(dt)
	tween.update(dt)
	mx, my = love.mouse.getPosition()
	mx = mx - CENTERX
	my = my - CENTERY
	if gameTween.tweenToggle == 0 then
		updateInput()
		--updateShapes(dt)
		player:update(dt,input,level)
		level:update()
		updateRoom()
		updateHoles(dt)
	else
		tweenRoom()
	end
end

function Game:draw()
	love.graphics.setBackgroundColor(unpack(colors.background))
	love.graphics.push()
		love.graphics.setColor(unpack(colors.background))
		love.graphics.rectangle("fill",0,0,WIDTH,HEIGHT)
	love.graphics.translate(CENTERX,CENTERY)
	love.graphics.scale(gameTween.gameScale)
	love.graphics.translate(gameTween.translateX,gameTween.translateY)
		drawGlow()	
		drawGlow(-CENTERY*2)
		drawLevel()
		player:draw()
		drawHoles()
	love.graphics.pop()

		love.graphics.setFont(fonts["subtitle"])
		love.graphics.setColor(unpack(colors["subtitle"]))
		love.graphics.print(gameScore,10,10)
		love.graphics.print(mx..", "..my,10,25)
end

function Game:resize(w,h)
	WIDTH = IRESX
	HEIGHT = IRESY
	CENTERX = WIDTH/2
	CENTERY = HEIGHT/2
end

function Game:keypressed(key, unicode)
	if key == 'escape' then
		hs:save()								-- Save the highscores! Then,
		love.event.push('quit')					-- Send 'quit' even to event queue	
	end
end

function Game:mousepressed(x, y, button)
	--gamestate:gotoState(BUTTONSTATE)
end

function Game:joystickpressed(joystick, button)
--	gamestate:gotoState(BUTTONSTATE)
end