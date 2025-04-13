Enemies = {}

function spawnEnemy(x, y)
	local enemy = World:newRectangleCollider(x, y, 70, 90, { collision_class = 'Danger' })
	enemy.direction = 1
	enemy.speed = 200
	enemy.animation = Animations.enemy
	table.insert(Enemies, enemy)
end


function updateEnemies(dt)
	for _, e in ipairs(Enemies) do
		e.animation:update(dt)
		local ex, ey = e:getPosition()

		local colliders = World:queryRectangleArea(ex + (40 * e.direction), ey + 40, 10, 10, { 'Platform' })

		if #colliders == 0 then
			e.direction = e.direction * -1
		end

		e:setX(ex + e.speed * dt * e.direction)
	end
end


function drawEnemies()
	for _, e in ipairs(Enemies) do
		local ex, ey = e:getPosition()
		e.animation:draw(Sprites.enemySheet, ex, ey, nil, e.direction, 1, 50, 65)
	end
end
