local playerStartX = 360
local playerStartY = 100

local Player = World:newRectangleCollider(playerStartX, playerStartY, 40, 100, { collision_class = 'Player' })
Player:setFixedRotation(true)
Player.speed =  240
Player.animation = Animations.idle
Player.isMoving = false
Player.direction = 1
Player.grounded = true


function Player.start(self)
	self:setPosition(playerStartX, playerStartY)
end


function Player.update(self, dt)
	if self.body then
		local colliders = World:queryRectangleArea(self:getX() - 20, self:getY() + 50, 40, 2, { 'Platform' })
		if #colliders > 0 then
			self.grounded = true
		else
			self.grounded = false
		end

		self.isMoving = false

		local px, _ = self:getPosition()

		if love.keyboard.isDown('right') then
			self:setX(px + self.speed * dt)
			self.isMoving = true
			self.direction = 1
		end

		if love.keyboard.isDown('left') then
			self:setX(px - self.speed * dt)
			self.isMoving = true
			self.direction = -1
		end

		if self:enter('Danger') then
			self:start()
			-- self:destroy()
		end
	end

	if self.grounded then
		if self.isMoving then
			self.animation = Animations.run
		else
			self.animation = Animations.idle
		end
	else
		self.animation = Animations.jump
	end

	self.animation:update(dt)
end

function Player.jump(self)
	if self.grounded then
		self:applyLinearImpulse(0, -4000)
	end
end

function Player.draw(self)
	local px, py = self:getPosition()
	self.animation:draw(Sprites.playerSheet, px, py, nil, 0.25 * self.direction, 0.25, 130, 300)
end

return Player
