local function spawnBullet()
	local bullet = {}
	bullet.x = Player.x
	bullet.y = Player.y
	bullet.angle = Player:angle()
	bullet.speed = 500
	table.insert(Bullets, bullet)
end

local function spawnZombie()
	local zombie = {}
	zombie.speed = 100

	local side = math.random(1, 4)

	if side == 1 then
		zombie.x = -30
		zombie.y = math.random(0, love.graphics.getHeight())
	elseif side ==  2 then
		zombie.x = love.graphics.getWidth() + 30
		zombie.y = math.random(0, love.graphics.getHeight())
	elseif side == 3 then
		zombie.x = math.random(0, love.graphics.getWidth())
		zombie.y = -30
	else
		zombie.x = math.random(0, love.graphics.getWidth())
		zombie.y = love.graphics.getHeight() + 30
	end

	table.insert(Zombies, zombie)
end

local function zombiePlayerAngle(enemy)
	return  math.atan2(Player.y - enemy.y, Player.x - enemy.x)
end

local function distanceBetween(x1, y1, x2, y2)
	return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function love.load()
	math.randomseed(os.time())

	Sprites = {}
	Sprites.background = love.graphics.newImage('sprites/background.png')
	Sprites.bullet = love.graphics.newImage('sprites/bullet.png')
	Sprites.zombie = love.graphics.newImage('sprites/zombie.png')
	Sprites.player = love.graphics.newImage('sprites/player.png')

	Zombies = {}

	Bullets = {}

	Player = {}
	Player.x = love.graphics.getWidth() / 2
	Player.y = love.graphics.getHeight() / 2
	Player.speed = 180

	Player.angle = function(player)
		return  math.atan2(player.y - love.mouse.getY(), player.x - love.mouse.getX()) + math.pi
	end

	Player.moveRight = function(player, dt)
		if player.x < love.graphics.getWidth() - Sprites.player:getWidth() then
			player.x = player.x + player.speed * dt
		else
			player.x = love.graphics.getWidth() - Sprites.player:getWidth()
		end
	end

	Player.moveLeft = function(player, dt)
		if player.x > Sprites.player:getWidth() then
			player.x = player.x - player.speed * dt
		else
			player.x = Sprites.player:getWidth()
		end
	end

	Player.moveDown = function(player, dt)
		if player.y < love.graphics.getHeight() - Sprites.player:getHeight() then
			player.y = player.y + player.speed * dt
		else
			player.y = love.graphics.getHeight() - Sprites.player:getHeight()
		end
	end

	Player.moveUp = function(player, dt)
		if player.y > Sprites.player:getHeight() then
			player.y = player.y - player.speed * dt
		else
			player.y = Sprites.player:getHeight()
		end
	end

	GameState = 2
	MaxTime = 2
	Timer = MaxTime
end

function love.update(dt)
	if GameState == 2 then
		Timer = Timer - dt
		if Timer < 0 then
			spawnZombie()
			Timer = MaxTime
			MaxTime = MaxTime * 0.95
		end

		if love.keyboard.isDown('d') then
			Player:moveRight(dt)
		end

		if love.keyboard.isDown('a') then
			Player:moveLeft(dt)
		end

		if love.keyboard.isDown('w') then
			Player:moveUp(dt)
		end

		if love.keyboard.isDown('s') then
			Player:moveDown(dt)
		end

		local zombiesOnStage = {}
		for _, z in ipairs(Zombies) do
			z.x = z.x + math.cos(zombiePlayerAngle(z)) * z.speed * dt
			z.y = z.y + math.sin(zombiePlayerAngle(z)) * z.speed * dt

			if distanceBetween(z.x, z.y, Player.x, Player.y) < 30 then
				-- player is caught
				GameState = 1
			end

			local onStage = true
			for _, b in ipairs(Bullets) do
				if distanceBetween(z.x, z.y, b.x, b.y) < 30 then
					onStage = false
				end
			end

			if onStage then
				table.insert(zombiesOnStage, z)
			end
		end

		Zombies = zombiesOnStage

		local bulletsOnStage = {}
		for _, b in ipairs(Bullets) do
			b.x = b.x + math.cos(b.angle) * b.speed * dt
			b.y = b.y + math.sin(b.angle) * b.speed * dt

			local onStage = true
			if b.x < 0 or b.x > love.graphics.getWidth() then
				onStage = false
			end

			if b.y < 0 or b.y > love.graphics.getHeight() then
				onStage = false
			end

			if onStage then
				table.insert(bulletsOnStage, b)
			end
		end

		Bullets = bulletsOnStage
	end
end

function love.draw()
	love.graphics.draw(Sprites.background, 0, 0)

	if GameState == 2 then

		love.graphics.draw(Sprites.player, Player.x, Player.y, Player:angle(), nil, nil, Sprites.player:getWidth() / 2, Sprites.player:getHeight() / 2)

		for _, z in ipairs(Zombies) do
			love.graphics.draw(Sprites.zombie, z.x, z.y, zombiePlayerAngle(z), nil, nil, Sprites.zombie:getWidth() / 2, Sprites.zombie:getHeight() / 2)
		end

		for _, b in ipairs(Bullets) do
			love.graphics.draw(Sprites.bullet, b.x, b.y, b.angle, 0.5, nil, Sprites.bullet:getWidth() / 2, Sprites.bullet:getHeight() / 2)
		end
	end
end

function love.mousepressed(x, y, button)
	if button == 1 and GameState == 2 then
		spawnBullet()
	elseif button == 1 and GameState == 1 then
		GameState = 2
	end
end
