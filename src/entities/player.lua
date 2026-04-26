local Entity = require('src.entities.entity')

local Player = Entity:extend()

function Player:new(x, y)
    Player.super.new(self, x, y)
    self.speed = 200
    self.vx = 0
    self.vy = 0
    
    self.health = 100
    self.max_health = 100
    
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
    
    -- Mover com colisão e filtro para detectar NPCs
    local actualX, actualY, collisions, len = bump_world:move(self, 
        self.x + self.vx * dt, 
        self.y + self.vy * dt,
        function(item, other)
            -- Configurar tipos de colisão
            if other.type == "NPC" then
                return 'cross' -- Permitir atravessar para detectar contato
            elseif type(other) == "string" and (other:match("tile_") or false) then
                -- Tiles do mapa (pedra, árvore, água)
                return 'slide' -- Deslizar nas paredes
            else
                return 'slide' -- Padrão para outros objetos
            end
        end)
    
    self.x = actualX
    self.y = actualY
    
    -- Verificar colisões com NPCs para iniciar combate
    for i = 1, len do
        local collision = collisions[i]
        if collision.other.type == "NPC" and collision.other.active then
            -- Iniciar combate
            local main = require('main')
            
            -- Mudar estado global para BATTLE
            main.set_current_state(main.GameState.BATTLE)
            
            -- Obter instância global do battle system
            local battle_system = main.get_battle_system()
            
            -- Iniciar sistema de batalha
            battle_system:startBattle(self, collision.other, self.x, self.y)
            
            -- Isolar combate: desativar outros NPCs
            local npcs = main.get_monsters()
            for _, other_npc in ipairs(npcs) do
                if other_npc ~= collision.other then
                    other_npc.active = false
                    other_npc.visible = false
                end
            end
            
            break -- Apenas um combate por vez
        end
    end
end

function Player:draw()
    -- Placeholder: retângulo azul
    love.graphics.setColor(0, 100, 255)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    love.graphics.setColor(255, 255, 255)
end

return Player
