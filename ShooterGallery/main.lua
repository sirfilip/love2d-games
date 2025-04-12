local Target = {}
local score
local timer
local gameFont

function love.load()
	Target.x = 300
	Target.y = 300
	Target.radius = 50

	Sprites = {}
	Sprites.sky = love.graphics.newImage('sprites/sky.png')
	Sprites.target = love.graphics.newImage('sprites/target.png')
	Sprites.crosshairs = love.graphics.newImage('sprites/crosshairs.png')

	score = 0
	timer = 10

	GameState = 1

	gameFont = love.graphics.newFont(40)

	love.mouse.setVisible(false)
end


function love.update(dt)
	if GameState == 1 then
		return
	end

	if timer > 0 then
		timer = timer - dt
	end

	if timer < 0 then
		timer = 0
		GameState = 1
	end
end


function love.draw()
	-- love.graphics.setColor(1, 0, 0)
	-- love.graphics.circle("fill", Target.x, Target.y, Target.radius)
	-- love.graphics.setColor(1, 1, 1)
	-- love.graphics.circle("fill", Target.x, Target.y, Target.radius - 10)
	-- love.graphics.setColor(1, 0, 0)
	-- love.graphics.circle("fill", Target.x, Target.y, Target.radius - 20)
	-- love.graphics.setColor(1, 1, 1)
	-- love.graphics.circle("fill", Target.x, Target.y, Target.radius - 30)
	-- love.graphics.setColor(1, 0, 0)
	-- love.graphics.circle("fill", Target.x, Target.y, Target.radius - 40)


	love.graphics.draw(Sprites.sky, 0, 0)

	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(gameFont)
	love.graphics.print("Score: " .. score, 5, 5)
	love.graphics.print("Time: " .. math.ceil(timer), 300, 5)

	if GameState == 1 then
		local text = "Press any key to start"
		love.graphics.printf(text, 0, 250, love.graphics.getWidth(), "center")
	end

	if GameState == 2 then
		love.graphics.draw(Sprites.target, Target.x - Target.radius, Target.y - Target.radius)
	end
	love.graphics.draw(Sprites.crosshairs, love.mouse.getX() - 20, love.mouse.getY() - 20)
end

local function distanceBetween(x1, y1, x2, y2)
	return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function love.mousepressed(x, y, button, istouch, presses)
	if GameState == 1 then
		GameState = 2
		timer = 10
		score = 0
		return
	end
	-- 1 is the left click
	-- and we are only interested in the left click
	if button ~= 1 then
		return
	end

	if distanceBetween(Target.x, Target.y, x, y) < Target.radius then
		score = score + 1
		Target.x = math.random(Target.radius, love.graphics.getWidth() - Target.radius)
		Target.y = math.random(Target.radius, love.graphics.getHeight() - Target.radius)
	end
end

