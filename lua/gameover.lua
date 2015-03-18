
local Gameover = Gamestate:addState('Gameover')

local BUTTONSTATE = 'Game'

local WIDTH = IRESX
local HEIGHT = IRESY
local CENTERX = WIDTH/2
local CENTERY = HEIGHT/2

local function drawGameOver()
	love.graphics.setFont(fonts["subtitle"])
	love.graphics.setColor(unpack(colors["subtitle"]))
	love.graphics.printf("GAME OVER", 0, CENTERY, WIDTH, "center" )
end



------------------------------------------------------------------------------------------









function Gameover:enteredState()	
	
end

function Gameover:exitedState()
	
end

function Gameover:update(dt)
	
end

function Gameover:draw()
	love.graphics.setBackgroundColor(unpack(colors.background))
	love.graphics.setColor(unpack(colors.background))
	love.graphics.rectangle("fill",0,0,WIDTH,HEIGHT)
	love.graphics.setColor(5,17,32,255)
	love.graphics.draw(graphics["glow2"],CENTERX,CENTERY,0,2,2,200,200)
	drawGameOver()
end

function Gameover:resize(w,h)
	WIDTH = IRESX
	HEIGHT = IRESY
	CENTERX = WIDTH/2
	CENTERY = HEIGHT/2
end

function Gameover:keypressed(key, unicode)
	if key == 'escape' then
		hs:save()								-- Save the highscores! Then,
		love.event.push('quit')					-- Send 'quit' even to event queue	
	elseif key == '1' or key == '2' or key == '3' then
	else	
		gamestate:gotoState(BUTTONSTATE)
	end
end

function Gameover:mousepressed(x, y, button)
end

function Gameover:joystickpressed(joystick, button)
end




