function love.load()
	love.window.setMode(1000, 768)

	local anim8 = require 'libraries/anim8'
	Sti = require 'libraries/Simple-Tiled-Implementation/sti'
	local cameraFile = require 'libraries/hump/camera'


	Cam = cameraFile()

	Sounds = {}
	Sounds.jump = love.audio.newSource("audio/jump.wav", "static")
	Sounds.music = love.audio.newSource("audio/music.mp3", "stream")
	Sounds.music:setLooping(true)
	Sounds.music:setVolume(0.5)
	Sounds.music:play()

	Sprites = {}
	Sprites.playerSheet = love.graphics.newImage('sprites/playerSheet.png')
	Sprites.enemySheet = love.graphics.newImage('sprites/enemySheet.png')
	Sprites.background = love.graphics.newImage('sprites/background.png')

	local grid = anim8.newGrid(614, 564, Sprites.playerSheet:getWidth(), Sprites.playerSheet:getHeight())
	local enemyGrid = anim8.newGrid(100, 79, Sprites.enemySheet:getWidth(), Sprites.enemySheet:getHeight())

	Animations = {}
	Animations.idle = anim8.newAnimation(grid('1-15', 1), 0.05)
	Animations.jump = anim8.newAnimation(grid('1-7', 2), 0.05)
	Animations.run = anim8.newAnimation(grid('1-15', 3), 0.05)
	Animations.enemy = anim8.newAnimation(enemyGrid('1-2', 1), 0.03)


	local wf = require 'libraries/windfield'
	World = wf.newWorld(0, 800, false)
	World:setQueryDebugDrawing(true)

	World:addCollisionClass('Platform')
	World:addCollisionClass('Player', {
		--[[
		ignores = {
			'Platform',
		},
		--]]
	})
	World:addCollisionClass('Danger')

	Player = require 'player'
	require 'enemy'



	DangerZone = World:newRectangleCollider(-500, 800, 5000, 50, { collision_class = 'Danger' })
	DangerZone:setType('static')

	Platforms = {}

	FlagX = 0
	FlagY = 0

	SaveData = {}
	SaveData.CurrentLevel = 'level1'

	loadMap(SaveData.CurrentLevel)
end


function love.update(dt)
	World:update(dt)
	GameMap:update(dt)
	Player:update(dt)
	updateEnemies(dt)

	local px, py = Player:getPosition()
	Cam:lookAt(px, love.graphics.getHeight() / 2)

	local colliders = World:queryCircleArea(FlagX, FlagY, 10, { 'Player' })
	if #colliders > 0 then
		if SaveData.CurrentLevel == 'level1' then
			loadMap('level2')
		elseif SaveData.CurrentLevel == 'level2' then
			loadMap('level1')
		end
	end
end

function love.draw()
	love.graphics.draw(Sprites.background)
	Cam:attach()
		GameMap:drawLayer(GameMap.layers['Tile Layer 1'])
		-- World:draw()
		Player:draw()
		drawEnemies()
	Cam:detach()
end


function love.keypressed(key)
	if key == 'up' then
		Player:jump()
		Sounds.jump:play()
	end

	if key == 'r' then
		loadMap('level2')
	end
end

function destroyAll()
	local i = #Platforms
	while i > -1 do
		if Platforms[i] ~= nil then
			Platforms[i]:destroy()
		end
		table.remove(Platforms, i)
		i = i - 1
	end

	i = #Enemies
	while i > -1 do
		if Enemies[i] ~= nil then
			Enemies[i]:destroy()
		end
		table.remove(Enemies, i)
		i = i - 1
	end
end


function love.mousepressed(x, y, button)
	if button == 1 then
		local colliders = World:queryCircleArea(x, y, 200, { 'Platform', 'Danger'})
		for i, c in ipairs(colliders) do
			c:destroy()
		end
	end
end

function spawnPlatform(x, y, width, height)
	if width > 0 and height > 0 then
		local platform = World:newRectangleCollider(x, y, width, height, { collision_class = 'Platform' })
		platform:setType('static')
		table.insert(Platforms, platform)
	end
end

function loadMap(mapName)
	SaveData.CurrentLevel = mapName
	destroyAll()
	Player:start()

	GameMap = Sti('maps/'.. SaveData.CurrentLevel .. '.lua')
	for i, obj in pairs(GameMap.layers["Platforms"].objects) do
		spawnPlatform(obj.x, obj.y, obj.width, obj.height)
	end

	for _, obj in pairs(GameMap.layers["Enemies"].objects) do
		spawnEnemy(obj.x, obj.y)
	end

	for _, obj in pairs(GameMap.layers["Flag"].objects) do
		FlagX = obj.x
		FlagY = obj.y
	end
end

