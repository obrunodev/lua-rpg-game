local Entity = require('src.entities.entity')

local Player = Entity:extend()

function Player:new(x, y)
    Player.super.new(self, x, y)
    self.speed = 200
    self.vx = 0
    self.vy = 0
    
    -- Adicionar ao mundo de colisão bump
    bump_world:add(self, self.x, self.y, self.width, self.height)
end

function Player:update(dt)
    -- Resetar velocidade
    self.vx = 0
    self.vy = 0
    
    -- Movimento WASD
    if love.keyboard.isDown('w') then
        self.vy = -self.speed
    end
    if love.keyboard.isDown('s') then
        self.vy = self.speed
    end
    if love.keyboard.isDown('a') then
        self.vx = -self.speed
    end
    if love.keyboard.isDown('d') then
        self.vx = self.speed
    end
    
    -- Normalizar movimento diagonal
    if self.vx ~= 0 and self.vy ~= 0 then
        self.vx = self.vx * 0.707
        self.vy = self.vy * 0.707
    end
    
    -- Mover com colisão (placeholder por enquanto)
    local actualX, actualY, collisions, len = bump_world:move(self, 
        self.x + self.vx * dt, 
        self.y + self.vy * dt)
    
    self.x = actualX
    self.y = actualY
end

function Player:draw()
    -- Placeholder: retângulo azul
    love.graphics.setColor(0, 100, 255)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    love.graphics.setColor(255, 255, 255)
end

return Player
