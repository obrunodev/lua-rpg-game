local Entity = require('src.entities.entity')

local NPC = Entity:extend()

function NPC:new(x, y)
    NPC.super.new(self, x, y)
    self.type = "NPC"
    self.health = 100
    self.max_health = 100
    self.speed = 80
    self.visible = true
    self.active = true
    
    -- IA de movimento
    self.move_timer = 0
    self.move_interval = 2.0 -- 2 segundos entre movimentos
    self.current_direction = {0, 0} -- vx, vy
    self.directions = {
        {0, -1},  -- Norte
        {0, 1},   -- Sul
        {-1, 0},   -- Oeste
        {1, 0}     -- Leste
    }
    
    -- Adicionar ao mundo de colisão bump
    bump_world:add(self, self.x, self.y, self.width, self.height)
end

function NPC:update(dt)
    if not self.active then return end
    
    -- Atualizar temporizador de movimento
    self.move_timer = self.move_timer + dt
    
    if self.move_timer >= self.move_interval then
        self.move_timer = 0
        
        -- Escolher direção aleatória
        local dir_index = math.random(1, 4)
        self.current_direction = self.directions[dir_index]
        
        -- Calcular velocidade baseada na direção
        self.vx = self.current_direction[1] * self.speed
        self.vy = self.current_direction[2] * self.speed
        
        -- Tentar mover com colisão
        local new_x = self.x + self.vx * dt * 10 -- Multiplicar para movimento mais notável
        local new_y = self.y + self.vy * dt * 10
        
        -- Verificar limites do mapa antes de mover
        local map = require('src.systems.map_gen')
        -- Obter instância do mapa do main.lua
        local main = require('main')
        -- Usar valores fixos baseados na criação do mapa (80x60 tiles de 32px)
        local map_width = 80 * 32
        local map_height = 60 * 32
        
        -- Clamp para dentro dos limites do mapa
        new_x = math.max(0, math.min(new_x, map_width - self.width))
        new_y = math.max(0, math.min(new_y, map_height - self.height))
        
        -- Mover com bump.lua para respeitar colisões
        local actualX, actualY, collisions, len = bump_world:move(self, new_x, new_y)
        
        self.x = actualX
        self.y = actualY
        
        -- Resetar velocidade após movimento
        self.vx = 0
        self.vy = 0
    end
end

function NPC:draw()
    if not self.visible then return end
    
    -- Placeholder: retângulo laranja para diferenciar de monstros
    love.graphics.setColor(255, 165, 0)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    
    -- Desenhar barra de vida se estiver danificado
    if self.health < self.max_health then
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle('fill', self.x, self.y - 8, self.width, 4)
        
        local health_percent = self.health / self.max_health
        love.graphics.setColor(255, 165, 0)
        love.graphics.rectangle('fill', self.x, self.y - 8, self.width * health_percent, 4)
    end
    
    love.graphics.setColor(255, 255, 255)
end

function NPC:takeDamage(amount)
    self.health = self.health - amount
    if self.health <= 0 then
        self.health = 0
        return true -- Morreu
    end
    return false
end

function NPC:destroy()
    -- Remover do mundo de colisão
    bump_world:remove(self)
end

return NPC
