








function love.run()
    if love.math then
        love.math.setRandomSeed(os.time())
    end

    if love.event then
        love.event.pump()
    end

    if love.load then love.load(arg) end

    -- We don't want the first frame's dt to include time taken by love.load.
    if love.timer then love.timer.step() end

    local dt = 0

    -- Main loop time.
    while true do
        -- Process events.
        if love.event then
            love.event.pump()
            for e,a,b,c,d in love.event.poll() do
                if e == "quit" then 
                    if not love.quit or not love.quit() then
                        if love.audio then
                            love.audio.stop()
                        end
                        return
                    end
                end
                love.handlers[e](a,b,c,d)
            end
        end

        -- Update dt, as we'll be passing it to update
        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end

        -- Call update and draw
        if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

        if love.window and love.graphics and love.window.isCreated() then
            love.graphics.clear()
            love.graphics.origin()
            if love.draw then love.draw() end
            love.graphics.present()
        end

        if love.timer then love.timer.sleep(0.001) end
    end
end


function love.load()
	math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))	-- OSX randomseed
	for i=1, 4 do math.random() end	-- For good measure

	love.graphics.setDefaultFilter("linear","linear")
	love.graphics.setPointStyle("smooth")
    love.graphics.setLineStyle("smooth")
   	love.graphics.setPointSize(1)
	love.graphics.setLineWidth(1)
    love.mouse.setVisible(true)
	
	TOGGLEBIG = true
	IRESX = 480
	IRESY = 360 -- 4:3 resolution

	if love.graphics.getHeight() == IRESY and love.graphics.getWidth() == IRESX then 
		ISCALE = 1
	else
		if love.graphics.getWidth()/IRESX >= love.graphics.getHeight()/IRESY then
			ISCALE = love.graphics.getHeight()/IRESY 
		else
			ISCALE = love.graphics.getHeight()/IRESX
		end
	end
	HASFOCUS = true

	scaleCanvas = love.graphics.newCanvas(IRESX,IRESY)


	colorseperator = love.graphics.newShader([[
		extern vec2 dimensions = vec2(480.0, 360.0);
		
		extern number separateamount = 1.0; 
		
		extern vec2 redoffset = vec2(0.5, 0.0);
		extern vec2 blueoffset = vec2(-0.5, 0.0);
		
		vec4 effect(vec4 vcolor, Image texture, vec2 texture_coords, vec2 pixel_coords)
		{
			vec2 redcoord = clamp(texture_coords + redoffset/dimensions.s, 0.0, 1.0);
			vec2 bluecoord = clamp(texture_coords + blueoffset/dimensions.t, 0.0, 1.0);
			
			vec4 texcolor = Texel(texture, texture_coords);
			
			vec4 red = Texel(texture, redcoord);
			vec4 blue = Texel(texture, bluecoord);
			
			return vcolor * vec4(red.r, texcolor.g, blue.b, max(max(red.a, blue.b), texcolor.g));
		}
	]])

-- 	External Files
					require 'lib.middleclass'
	Stateful = 		require 'lib.stateful.stateful'
	hs2 = 			require 'lib.hs2.hs2'
	tween =		 	require 'lib.tween.tween'
					require 'lib.ellipse.ellipse'
	common =		require 'lib.common.common'

	love.filesystem.setIdentity("QuickQuick")		
	hs = hs2.load("highscores.txt", 1, "a", 0)
	gameScore = 0
	
	require 'obj.gamestate'  	-- Go go gadget gamestate
	
	require 'lua.title'
	require 'lua.game'
	require 'lua.gameover'
	
	colors = 		{	
					background = {0,8,14},
					black = {1,0,1},
					white = {218,228,180},
					grey = {39,40,39},
					title = {229,90,22},
					title2 = {255,132,26},
					subtitle = {162,88,74},
					highlight = {244,127,21},
					green = {88,96,73},
					blue = {72,98,100},
					blue2 = {16,32,45},
					shadow = {0,21,27}
					}
	fonts = 		{
					title = love.graphics.newFont("res/bk.otf",65),
					title2 = love.graphics.newFont("res/bko.otf",65),
					subtitle = love.graphics.newFont("res/bk.otf",15)
					}
	audio =			{
					Game = love.audio.newSource("res/1.mp3","stream") 
					}
	graphics = 		{
					title = love.graphics.newImage("res/title.png"),
					glow = love.graphics.newImage("res/glow.png"),
					glow2 = love.graphics.newImage("res/glow2.png"),
					glow3 = love.graphics.newImage("res/underglow.png")
					}

	love.audio.setVolume( 1 )					
	audio["Game"]:setVolume(0.75) -- 50% of ordinary volume
	audio["Game"]:setLooping( true )
					
	stateCarrier = {}
	gamestate = Gamestate:new()
	gamestate:gotoState('Title')
end

function love.update(dt)
	local fps = love.timer.getFPS( )
	love.window.setTitle( fps )


	if HASFOCUS then		-- pause when the game loses focus
		gamestate:update(dt)
	end
end

function love.draw()
	scaleCanvas:clear()
	love.graphics.setCanvas(scaleCanvas)
		love.graphics.setBackgroundColor(0,0,0)
		love.graphics.setColor(unpack(colors.white))
		love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())	
		
		gamestate:draw()
	
	love.graphics.setCanvas()
	love.graphics.setColor(255,255,255,255)	
	love.graphics.setShader(colorseperator)
		love.graphics.draw(scaleCanvas,love.graphics.getWidth()/2,love.graphics.getHeight()/2,0,ISCALE,ISCALE,IRESX/2,IRESY/2)
	love.graphics.setShader()
end

function love.resize( w, h )
	local w = w
	local h = h
	if w/IRESX >= h/IRESY then
		ISCALE = h/IRESY
	else
		ISCALE = w/IRESX
	end
	--gamestate:resize(w,h)
end

function love.focus(f)
	HASFOCUS = f
end

function love.joystickpressed(joystick, button)
	gamestate:joystickpressed(joystick, button)
end

function love.joystickreleased(joystick, button)
	gamestate:joystickreleased(joystick, button)
end

function love.keypressed(key, unicode)
	if key == "3" then
		local s = love.graphics.newScreenshot() 
		s:encode("QuickQuick"..os.time()..".png")
	end
	gamestate:keypressed(key, unicode)
end

function love.keyreleased(key)
	gamestate:keyreleased(key)
end

function love.mousepressed(x, y, button)
	gamestate:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	gamestate:mousereleased(x, y, button)
end

function love.quit()
	gamestate:quit()
end
