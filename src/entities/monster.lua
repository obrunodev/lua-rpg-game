local Entity = require('src.entities.entity')

local Monster = Entity:extend()

function Monster:new(x, y)
    Monster.super.new(self, x, y)
    self.type = "Monster"
    self.health = 100
    self.max_health = 100
    self.speed = 50
    self.vx = 0
    self.vy = 0
    self.visible = true
    self.active = true
    
    -- Adicionar ao mundo de colisão bump
    bump_world:add(self, self.x, self.y, self.width, self.height)
end

function Monster:update(dt)
    if not self.active then return end
    
    -- Movimento aleatório simples
    if math.random() < 0.02 then
        self.vx = (math.random() - 0.5) * self.speed
        self.vy = (math.random() - 0.5) * self.speed
    end
    
    -- Mover com colisão
    local actualX, actualY, collisions, len = bump_world:move(self, 
        self.x + self.vx * dt, 
        self.y + self.vy * dt)
    
    self.x = actualX
    self.y = actualY
    
    -- Parar movimento
    self.vx = 0
    self.vy = 0
end

function Monster:draw()
    if not self.visible then return end
    
    -- Placeholder: retângulo vermelho
    love.graphics.setColor(255, 0, 0)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    
    -- Desenhar barra de vida
    if self.health < self.max_health then
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle('fill', self.x, self.y - 8, self.width, 4)
        
        local health_percent = self.health / self.max_health
        love.graphics.setColor(255, 0, 0)
        love.graphics.rectangle('fill', self.x, self.y - 8, self.width * health_percent, 4)
    end
    
    love.graphics.setColor(255, 255, 255)
end

function Monster:takeDamage(amount)
    self.health = self.health - amount
    if self.health <= 0 then
        self.health = 0
        return true -- Morreu
    end
    return false
end

function Monster:destroy()
    -- Remover do mundo de colisão
    bump_world:remove(self)
end

return Monster
