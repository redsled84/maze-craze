--Warning when reading code: IS VERY MESSY!

local AdvTiledLoader = require("AdvTiledLoader.Loader")
require("camera")
require("player")

gameState = "level5"

function levelDraw(level)
	level:setDrawRange(0, 0, level.width * level.tileWidth, level.height * level.tileHeight)
end

function love.load()
	
	love.graphics.setBackgroundColor(255,255,255)
	bigFont = love.graphics.setNewFont("manaspc.ttf", 24)
	smallFont = love.graphics.setNewFont("manaspc.ttf", 14)

	AdvTiledLoader.path = "maps/"
	level1 = AdvTiledLoader.load("level1.tmx")
	level2 = AdvTiledLoader.load("level2.tmx")
	level3 = AdvTiledLoader.load("level3.tmx")
	level4 = AdvTiledLoader.load("level4.tmx")
	level5 = AdvTiledLoader.load("level5.tmx")

	levelDraw(level1)
	levelDraw(level2)
	levelDraw(level3)
	levelDraw(level4)
	levelDraw(level5)

	levels = {{36, 36}, {love.graphics.getWidth() - 48, love.graphics.getHeight() - 48}}

	camera:setBounds(0, 0, level1.width, level1.height)

	menuSelection = "Play"

	player = 	{
				x = 48,
				y = 48,
				x_vel = 0,
				y_vel = 0,
				speed = 256,
				flySpeed = 700,
				state = "",
				h = 16,
				w = 16,
				standing = false,
				died = false
				}

	deathLevels = ""

	mapWidth = 480
	mapHeight = 480
  
	
	function player:right()
		
		self.x_vel = self.speed
	
	end
	
	function player:left()
		
		self.x_vel = -1 * (self.speed)
	
	end

	function player:up()
		
		self.y_vel = -1 * (self.speed)
	
	end

	function player:down()
		
		self.y_vel = self.speed
	
	end
	
	function player:stop()
		
		self.x_vel = 0
	
	end
	
	function player:collide(event)

		if event == "floor" then
			self.y_vel = 0
			self.standing = true
		end
		if event == "cieling" then
			self.y_vel = 0
		end
	
	end
	
	function player:update(dt)

		
		self.state = self:getState()

	end
	
	function player:isColliding(map, x, y)

		local layer = map.tl["Solid"]
		local tileX, tileY = math.floor(x / map.tileWidth), math.floor(y / map.tileHeight)
		local tile = layer.tileData(tileX, tileY)
		return not(tile == nil)

	end
	
	function player:getState()
		local tempState = ""
		if self.standing then
			if self.x_vel > 0 then
				tempState = "right"
			elseif self.x_vel < 0 then
				tempState = "left"
			else
				tampState = "stand"
			end
		end
		if self.y_vel > 0 then
			tempState = "fall"
		elseif self.y_vel < 0 then
			tempState = "jump"
		end
		return tempState
	end

	function level(map)
		dt = love.timer.getDelta()

		local halfX = player.w / 2 -- center x of player
		local halfY = player.h / 2 -- center y of player
		
		local nextY = player.y + (player.y_vel*dt)
		if player.y_vel < 0 then
			if not (player:isColliding(map, player.x - halfX, nextY - halfY))
				and not (player:isColliding(map, player.x + halfX - 1, nextY - halfY)) then
				player.y = nextY
				player.standing = false
			else
				player.y = nextY + map.tileHeight - ((nextY - halfY) % map.tileHeight)
				player:collide("cieling")
				player.died = true
				
			end
		end
		if player.y_vel > 2 then
			if not (player:isColliding(map, player.x-halfX, nextY + halfY))
				and not(player:isColliding(map, player.x + halfX - 1, nextY + halfY)) then
					player.y = nextY
					player.standing = false
			else
				player.y = nextY - ((nextY + halfY) % map.tileHeight)
				player:collide("floor")
				player.died = true
			end
		end
		
		local nextX = player.x + (player.x_vel * dt)
		if player.x_vel > 0 then
			if not(player:isColliding(map, nextX + halfX, player.y - halfY))
				and not(player:isColliding(map, nextX + halfX, player.y + halfY - 1)) then
				player.x = nextX
			else
				player.x = nextX - ((nextX + halfX) % map.tileWidth)
				player.died = true
			end
		elseif player.x_vel < 0 then
			if not(player:isColliding(map, nextX - halfX, player.y - halfY))
				and not(player:isColliding(map, nextX - halfX, player.y + halfY - 1)) then
				player.x = nextX
			else
				player.x = nextX + map.tileWidth - ((nextX - halfX) % map.tileWidth)
				player.died = true
			end
		end
end	

end

function playerUpdate(dt)
	
	if dt > 0.05 then
		dt = 0.05
	end
	if love.keyboard.isDown("right") then
		player:right()
	end
	if love.keyboard.isDown("left") then
		player:left()
	end
	if love.keyboard.isDown("down") then
		player:down()
	end
	if love.keyboard.isDown("up") then
		player:up()
	end

	player:update(dt)

end

function playerKeyReleased(key)

	if (key == "left") or (key == "right") then
		player.x_vel = 0
	end
	if (key == "up") or (key == "down") then
		player.y_vel = 0
	end

end

	
function love.update(dt)
	
	playerUpdate(dt)
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end

	if gameState == "title" then
		if love.keyboard.isDown("up") then
			menuSelection = "Play"
		elseif love.keyboard.isDown("down") then
			menuSelection = "Quit"
		end
	
	if love.keyboard.isDown(" ", "enter") and gameState == "title" then
		if menuSelection == "Play" then
			gameState = "level1"

		elseif menuSelection == "Quit" then
			love.event.quit()
		end
	end

	elseif gameState == "level1" then
		level(level1)
		if player.died then
			player.x = 48
			player.y = 48
			player.died = false


		elseif player.y < 40 then
			gameState = "level2"
		end
	end
	if gameState == "level2" then
		level(level2)
		playerUpdate(dt)
		if player.died then
			player.x = love.graphics.getWidth() - 48
			player.y = 50
			player.died = false
		end
		if player.x < 34 then
			gameState = "level3"
		elseif love.keyboard.isDown("r") then
			gameState = "title"
		end
	end
	if gameState == "level3" then
		level(level3)
		playerUpdate(dt)
		if player.y > 443 then
			gameState = "level4"
		end
		if player.died then
			player.x = 48
			player.y = 48
			player.died = false
		end
	end
	if gameState == "level4" then
		level(level4)
		playerUpdate(dt)
		player.w = 16
		player.h = 16
		if player.y < 32 then
			gameState = "level5"
		end
		if player.died then
			player.x = love.graphics.getWidth() - 48
			player.y = love.graphics.getHeight() - 48
			player.died = false
		end
	end
	if gameState == "level5" then
		level(level5)
		playerUpdate(dt)
		player.w = 16
		player.h = 16
		if player.x > love.graphics.getWidth() - 32 then
			gameState = "finish"
		end
		if player.died then
			player.x = 111
			player.y = 47
			player.died = false
		end
	end
	
	if gameState == "finish" then
		if love.keyboard.isDown("r") then
			player.x = 48
			player.y = 48	
			gameState = "title"
		end
		if love.keyboard.isDown(" ", "enter", "escape") then
			love.event.quit()
		end
	end

end

function love.draw()

	if gameState == "title" then
		love.graphics.setBackgroundColor(0,0,0)
		love.graphics.setColor(102,151,147)
		love.graphics.setFont(bigFont)
		love.graphics.print("MAZE GAME", 40, 40)
		if menuSelection == "Play" then 
			
			love.graphics.setColor(255,255,255)
			love.graphics.setFont(smallFont)
			love.graphics.print("(HIT SPACE) (USE ARROW KEYS)", 110, 155)
			love.graphics.setFont(bigFont)
			love.graphics.setColor(255,0,0) 
		else love.graphics.setColor(255,255,255) end
		love.graphics.print("PLAY", 40, 150)
		
		if menuSelection == "Quit" then love.graphics.setColor(255,0,0) else love.graphics.setColor(255,255,255) end
		love.graphics.print("QUIT", 40, 200)

	

	elseif gameState == "finish" then
		love.graphics.setBackgroundColor(0,0,0)
		love.graphics.setColor(255,255,255)
		love.graphics.setFont(bigFont)
		love.graphics.printf("WINNER", 170, 200, 150, "center")
		love.graphics.print("PRESS 'R' TO RESTART", 80, 300)
		
	elseif gameState == "level1" then
		camera:set()
		love.graphics.setColor(0,255,0)
		
		love.graphics.setBackgroundColor(255,255,255)
		love.graphics.setColor(168,17,33)
		love.graphics.rectangle("fill", player.x - player.w/2, player.y - player.h/2, player.w, player.h)

		love.graphics.setColor(255,255,255)
		level1:draw()
		camera:unset()
	elseif gameState == "level2" then
		camera:set()
		love.graphics.setColor(0,255,0)
		love.graphics.setBackgroundColor(255,255,255)
		
		love.graphics.setColor(168,17,33)
	
		love.graphics.rectangle("fill", (player.x - player.w/2) , (player.y - player.h/2), player.w, player.h)

		love.graphics.setColor(255,255,255)
		level2:draw()
		camera:unset()
	elseif gameState == "level3" then
		camera:set()
		love.graphics.setColor(0,255,0)
		love.graphics.setBackgroundColor(255,255,255)
		
		love.graphics.setColor(168,17,33)
	
		love.graphics.rectangle("fill", (player.x - player.w/2) , (player.y - player.h/2), player.w, player.h)

		love.graphics.setColor(255,255,255)
		level3:draw()
		camera:unset()
	elseif gameState == "level4" then
		camera:set()
		love.graphics.setColor(0,255,0)
		love.graphics.setBackgroundColor(255,255,255)
		
		love.graphics.setColor(168,17,33)
	
		love.graphics.rectangle("fill", (player.x - player.w/2) , (player.y - player.h/2), player.w, player.h)

		love.graphics.setColor(255,255,255)
		level4:draw()
		camera:unset()
	elseif gameState == "level5" then
		camera:set()
		love.graphics.setColor(0,255,0)
		love.graphics.setBackgroundColor(255,255,255)
		
		love.graphics.setColor(168,17,33)
	
		love.graphics.rectangle("fill", (player.x - player.w/2) , (player.y - player.h/2), player.w, player.h)

		love.graphics.setColor(255,255,255)
		level5:draw()
		camera:unset()
	elseif gameState == "progress" then
		love.graphics.setColor(255,255,255)
		love.graphics.setBackgroundColor(0,0,0)
		love.graphics.setFont(bigFont)
		love.graphics.print("STILL IN PROGRESS", 100, 220)
		love.graphics.print("(PRESS ESC TO EXIT)", 85, 250)
	end
end
	
function love.keyreleased(key)
	
	playerKeyReleased(key)
end