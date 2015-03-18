
local Title = Gamestate:addState('Title')

local Circle = require 'obj.circles'

local BUTTONSTATE = 'Game'

local WIDTH = IRESX
local HEIGHT = IRESY
local CENTERX = WIDTH/2
local CENTERY = HEIGHT/2

local bestScore = gameScore
local newRecord = false
local titleShader
local shaderTime
local firstFrameCatch

local backgroundCanvas
local titleCanvas

local circles = {}
local circleBuffer

local titleTween = {
					x = -CENTERX,
					y = -70,
					toggle = true,
					size = 120,
					strength = 1,
					titleFade = 155,
					crossfade = 255,
					dummyVariable = 0
	 				}


local function setTitleTweenToggle()
	titleTween.toggle = true
end

local function updateCicles(dt)
	for i,v in ipairs(circles) do
		circles[i]:update(dt, value)
		if circles[i]:getKill() == true then
			table.remove(circles,i)
			i = i - 1 -- uhh
		end
	end

	local interval = 2
	local rate = 4--1

	if circleBuffer > interval then
		circleBuffer = 0
		local y = -CENTERY - Circle.SAFEZONE
		local x = math.random(-CENTERY,CENTERY)
		circles[#circles + 1] = Circle:new({x = x, y = y}) 
	end
	
	circleBuffer = circleBuffer + rate*dt
end

local function updateTitle()	-- this doesn't show because it's only drawing the screen once
	if titleTween.toggle then
		tween(1,titleTween,{y = -60, },"inOutSine",
			tween,1,titleTween,{y = -80,},"inOutSine",setTitleTweenToggle)
		
		titleTween.toggle = false
	end
end

local function updateState()
	if titleTween.dummyVariable == 1 then
		gamestate:gotoState(BUTTONSTATE)
	end
end

local function drawTitle()
	---[[
	--love.graphics.setColor()	
	love.graphics.setColor(28,38,39,titleTween.titleFade)

	love.graphics.setFont(fonts["title2"])
	local offset = fonts["title"]:getHeight()
	love.graphics.setFont(fonts["title"])	
	love.graphics.printf("QUICKQUICK", titleTween.x, titleTween.y+offset-15, WIDTH, "center" )
--	love.graphics.setColor(255,110,88,75)
--	love.graphics.draw(graphics["glow2"],0,titleTween.y+offset/2,0,1,1,200,200)
	--]]
	--love.graphics.draw(graphics["title"],titleTween.x,titleTween.y+150,0,1,1,425/2,120)
--	love.graphics.setShader()
end

local function drawCircles()
	for i,v in ipairs(circles) do
		circles[i]:draw()
	end
end

local function drawBestScore()
	love.graphics.setFont(fonts["subtitle"])
	local r,g,b = unpack(colors["subtitle"])
	love.graphics.setColor(r,g,b, titleTween.titleFade)	
	if newRecord then

		love.graphics.printf("NEW RECORD", 0,CENTERY+ 135, WIDTH, "center" )
	end

	love.graphics.printf("BEST SCORE: ".. bestScore, 0, CENTERY+150, WIDTH, "center" )
end

local function drawLastScore()
	love.graphics.setFont(fonts["subtitle"])
	love.graphics.setColor(unpack(colors["subtitle"]))	
	love.graphics.printf(gameScore, -CENTERX, -165, WIDTH, "center" )
end

local function drawGlow()
	love.graphics.setColor(28,38,39,255)
	love.graphics.draw(graphics["glow2"],CENTERX,-CENTERY,0,4,1,200,200)
	love.graphics.draw(graphics["glow2"],-CENTERX,-CENTERY,0,4,1,200,200)
 	love.graphics.draw(graphics["glow2"],CENTERX,CENTERY,0,4,1,200,200)
 	love.graphics.draw(graphics["glow2"],-CENTERX,CENTERY,0,4,1,200,200)
	love.graphics.setColor(41,54,55,255)
	love.graphics.draw(graphics["glow2"],0,-CENTERY,0,4,1,200,200)
	love.graphics.setColor(51,57,59,105)
	love.graphics.draw(graphics["glow2"],0,CENTERY,0,4,1,200,200)

	love.graphics.setColor(85,71,63,225)
	love.graphics.draw(graphics["glow2"],CENTERX,0,0,1,1,200,200)
	love.graphics.draw(graphics["glow2"],-CENTERX,0,0,1,1,200,200)

	--love.graphics.setColor(252,107,83,125)
	love.graphics.setColor(73,75,72,255)
	love.graphics.draw(graphics["glow2"],0,0,0,1.6,1,200,200)
	love.graphics.setColor(117,89,79,225)
	love.graphics.draw(graphics["glow2"],0,0,0,1.6,1,200,200)
	love.graphics.setColor(253,95,69,20)
	love.graphics.draw(graphics["glow2"],0,-10,0,0.8,0.8,200,200)

end

local function drawSun()
	local sunStencil = function()
		love.graphics.circle("fill",5,0,130)
	end

	love.graphics.setInvertedStencil(sunStencil)

	love.graphics.setColor(255,110,88,205)
	love.graphics.draw(graphics["glow2"],-100,0,0,0.2,0.4,200,200)
	love.graphics.draw(graphics["glow2"],100,0,0,0.2,0.4,200,200)

	love.graphics.setColor(255,90,68,205)
	love.graphics.draw(graphics["glow3"],0,0,0,1.8,1.8,100,100)

	love.graphics.setColor(253,95,69,75)
	love.graphics.draw(graphics["glow2"],0,-120,0,0.5,0.2,200,200)

	love.graphics.setColor(253,120,88,105)
	love.graphics.draw(graphics["glow2"],130,-10,0,0.1,0.2,200,200)

	love.graphics.setInvertedStencil()

	love.graphics.setColor(252,127,96,100)
	love.graphics.draw(graphics["glow3"],0,0,0,2,2,100,100)
	love.graphics.setColor(253,122,92,60)
	love.graphics.circle("fill",5,0,130)

	love.graphics.setColor(255,97,74,40)
	love.graphics.draw(graphics["glow2"],130,-10,0,0.2,0.5,200,200)
	love.graphics.draw(graphics["glow2"],-125,-10,0,0.2,0.5,200,200)

	love.graphics.setStencil(sunStencil)

	love.graphics.setColor(161,79,63,200)
	love.graphics.draw(graphics["glow2"],0,100,0,0.7,0.5,200,200)
	--love.graphics.draw(graphics["glow2"],0,100,0,0.7,0.5,200,200)
	love.graphics.setStencil()
end




------------------------------------------------------------------------------------------









function Title:enteredState()	
	newRecord = false
	backgroundCanvas = love.graphics.newCanvas(IRESX,IRESY)
	titleCanvas = love.graphics.newCanvas(IRESX,IRESY)

	firstFrameCatch = false

	titleTween.dummyVariable = 0

	local shaderCode = [[
        extern number time = 0.0;
        extern number size = 64.0;
        extern number strength = 1.0;
        extern vec2 res = vec2(480.0, 360.0);
        uniform sampler2D tex0;
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {
            float tmp = sin(sqrt(pow(texture_coords.x * size - size / 2.0, 2.0) + pow(texture_coords.y * size - size / 2.0, 2.0)) - time * 16.0);
            vec2 uv         = vec2(
                texture_coords.x - tmp * strength / 1024.0,
                texture_coords.y - tmp * strength / 1024.0
            );
            vec3 col        = vec3(
                texture2D(tex0,uv).x,
                texture2D(tex0,uv).y,
                texture2D(tex0,uv).z
            );
         return vec4(col, 1.0);
        }
    ]]
    titleShader = love.graphics.newShader(shaderCode)
	shaderTime = 0

	circles = {}
	circleBuffer = 0

	for i = 1, 10 do
		circles[i] = Circle:new({x = math.random(-CENTERX,CENTERX), y = math.random(-CENTERY,CENTERY)}) 
	end

	local x, y = hs:get(1)				-- Get the top entry from the highscore table, with x a dummy variable to fill that argument
	if bestScore ~= y and gameScore ~= 0 then
		newRecord = true	
	end
	bestScore = y

	tween(2,titleTween,{dummyVariable = -1 },"linear",
		tween,1,titleTween,{dummyVariable = 0 },"linear",
			tween,1,titleTween,{titleFade = 1},"inQuad",
				tween,2,titleTween,{dummyVariable = 1},"linear")
end

function Title:exitedState()
	newRecord = false
	tween.stopAll() --stops all animations, without resetting any values
end

function Title:update(dt)
	tween.update(dt)
	shaderTime = shaderTime + dt

	titleShader:send('time', shaderTime)
	titleShader:send('strength', titleTween.strength)
	titleShader:send('size', titleTween.size)

	updateCicles(dt)
	--updateTitle()	-- this doesn't show with the optimization
	updateState()
end

function Title:draw()
	if firstFrameCatch then else
		backgroundCanvas:clear()
		
		love.graphics.setBackgroundColor(unpack(colors.background))
		love.graphics.push()
			love.graphics.setColor(unpack(colors.background))
			love.graphics.rectangle("fill",0,0,WIDTH,HEIGHT)
		love.graphics.translate(CENTERX,CENTERY)
		love.graphics.setCanvas(backgroundCanvas)	
			drawGlow()
			drawGlow()
			drawSun()
			drawSun()

			love.graphics.setColor(28,38,39,55)
			love.graphics.draw(graphics["glow2"],0,CENTERY,0,4,0.5,200,200)

			local mode = love.graphics.getBlendMode( )
			love.graphics.setBlendMode( "additive")
				love.graphics.setColor(253,125,97,20)
				love.graphics.draw(graphics["glow2"],0,0,0,1,0.5,200,200)
			love.graphics.setBlendMode( mode )
			
		love.graphics.pop()
	end
		love.graphics.push()
		love.graphics.translate(CENTERX,CENTERY)
			titleCanvas:clear()
			love.graphics.setCanvas(titleCanvas)
			love.graphics.setColor(255,255,255,titleTween.crossfade)
			love.graphics.draw(backgroundCanvas,-CENTERX,-CENTERY)
			drawCircles()

			love.graphics.setColor(28,38,39,105)
			love.graphics.draw(graphics["glow2"],0,CENTERY,0,4,0.25,200,200)	

			drawTitle()
		love.graphics.pop()	
		love.graphics.setCanvas(scaleCanvas)

		love.graphics.setShader(titleShader)
		love.graphics.setColor(255,255,255,titleTween.crossfade)
		love.graphics.draw(titleCanvas,0,0)
		
		love.graphics.setShader()
		drawBestScore()
		firstFrameCatch = true
end

function Title:resize(w,h)
	WIDTH = IRESX
	HEIGHT = IRESY
	CENTERX = WIDTH/2
	CENTERY = HEIGHT/2
end

function Title:keypressed(key, unicode)
	if key == 'escape' then
		hs:save()								-- Save the highscores! Then,
		love.event.push('quit')					-- Send 'quit' even to event queue	
	end
end

function Title:mousepressed(x, y, button)
end

function Title:joystickpressed(joystick, button)
end
