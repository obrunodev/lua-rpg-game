local Battle = {}

-- Estados de batalha
local BattleState = {
    PLAYER_TURN = "PLAYER_TURN",
    ENEMY_TURN = "ENEMY_TURN",
    ANIMATING = "ANIMATING"
}

function Battle.new()
    local self = setmetatable({}, {__index = Battle})
    
    -- Estado da batalha
    self.current_state = BattleState.PLAYER_TURN
    self.current_opponent = nil
    self.arena_center_x = 0
    self.arena_center_y = 0
    self.arena_size = 10 -- 10x10 grid
    
    -- Posições no grid
    self.player_grid_x = 0
    self.player_grid_y = 0
    self.opponent_grid_x = 0
    self.opponent_grid_y = 0
    
    -- Feedback visual
    self.attack_feedback = {
        active = false,
        target = nil,
        timer = 0,
        duration = 0.5
    }
    
    return self
end

function Battle:startBattle(player, opponent, collision_x, collision_y)
    self.current_opponent = opponent
    self.arena_center_x = collision_x
    self.arena_center_y = collision_y
    
    -- Calcular limites da arena
    local arena_start_x = math.floor(self.arena_center_x / 32) - math.floor(self.arena_size / 2)
    local arena_start_y = math.floor(self.arena_center_y / 32) - math.floor(self.arena_size / 2)
    
    -- Definir posições iniciais distantes na arena 10x10
    -- Player na extremidade esquerda [2,5] relativo à arena
    self.player_grid_x = arena_start_x + 2
    self.player_grid_y = arena_start_y + 5
    
    -- Inimigo na extremidade direita [9,5] relativo à arena
    self.opponent_grid_x = arena_start_x + 9
    self.opponent_grid_y = arena_start_y + 5
    
    -- Atualizar posições mundiais (usando cálculo direto: grid * 32 + 16 para centralizar)
    local cell_size = 32
    local cell_offset = cell_size / 2
    player.x = self.player_grid_x * cell_size + cell_offset
    player.y = self.player_grid_y * cell_size + cell_offset
    opponent.x = self.opponent_grid_x * cell_size + cell_offset
    opponent.y = self.opponent_grid_y * cell_size + cell_offset
    
    -- Atualizar posições no bump world
    bump_world:update(player, player.x, player.y)
    bump_world:update(opponent, opponent.x, opponent.y)
    
    self.current_state = BattleState.PLAYER_TURN
    print("Batalha iniciada!")
end

function Battle:handlePlayerInput(key, player)
    if self.current_state ~= BattleState.PLAYER_TURN then
        return false
    end
    
    local new_gx, new_gy = self.player_grid_x, self.player_grid_y
    local main = require('main')
    local map = main.get_map()
    
    -- Movimento no grid
    if key == 'w' then
        new_gy = new_gy - 1
    elseif key == 's' then
        new_gy = new_gy + 1
    elseif key == 'a' then
        new_gx = new_gx - 1
    elseif key == 'd' then
        new_gx = new_gx + 1
    else
        return false
    end
    
    -- Verificar limites da arena
    local arena_start_x = math.floor(self.arena_center_x / 32) - math.floor(self.arena_size / 2)
    local arena_start_y = math.floor(self.arena_center_y / 32) - math.floor(self.arena_size / 2)
    local arena_end_x = arena_start_x + self.arena_size - 1
    local arena_end_y = arena_start_y + self.arena_size - 1
    
    if new_gx < arena_start_x or new_gx > arena_end_x or
       new_gy < arena_start_y or new_gy > arena_end_y then
        return false
    end
    
    -- Verificar se pode mover (terreno walkable)
    if not self:canMoveTo(new_gx, new_gy, map) then
        return false
    end
    
    -- Verificar se está tentando atacar o oponente
    if new_gx == self.opponent_grid_x and new_gy == self.opponent_grid_y then
        self:performAttack(player, self.current_opponent)
        return true
    end
    
    -- Mover jogador
    self.player_grid_x = new_gx
    self.player_grid_y = new_gy
    local cell_size = 32
    local cell_offset = cell_size / 2
    player.x = self.player_grid_x * cell_size + cell_offset
    player.y = self.player_grid_y * cell_size + cell_offset
    bump_world:update(player, player.x, player.y)
    
    -- Mudar para turno do inimigo
    self.current_state = BattleState.ENEMY_TURN
    return true
end

function Battle:performAttack(attacker, target)
    local damage = 25
    local died = false
    
    -- Implementação direta: verificar se target tem health e aplicar dano
    if target and target.health and type(target.health) == "number" then
        target.health = target.health - damage
        if target.health <= 0 then
            target.health = 0
            died = true
        end
        print(string.format("Ataque! %d de dano. HP alvo: %d/%d", damage, target.health, (target.max_health or 100)))
    else
        -- Se não tiver health, adicionar health dinamicamente (fallback)
        if target then
            target.health = (target.health or 100) - damage
            target.max_health = target.max_health or 100
            if target.health <= 0 then
                target.health = 0
                died = true
            end
            print(string.format("Ataque! %d de dano (health adicionado). HP: %d/%d", damage, target.health, target.max_health))
        else
            print("ERRO: target inválido")
            return
        end
    end
    
    -- Ativar feedback visual
    self.attack_feedback.active = true
    self.attack_feedback.target = target
    self.attack_feedback.timer = self.attack_feedback.duration
    
    print(string.format("Ataque! %d de dano", damage))
    
    if died then
        self:endBattle(true)
    else
        -- Mudar turno após ataque
        if self.current_state == BattleState.PLAYER_TURN then
            self.current_state = BattleState.ENEMY_TURN
        else
            self.current_state = BattleState.PLAYER_TURN
        end
    end
end

function Battle:update(dt, player)
    -- Atualizar feedback visual de ataque
    if self.attack_feedback.active then
        self.attack_feedback.timer = self.attack_feedback.timer - dt
        if self.attack_feedback.timer <= 0 then
            self.attack_feedback.active = false
        end
    end
    
    -- IA do inimigo
    if self.current_state == BattleState.ENEMY_TURN then
        self:updateEnemyAI(dt, player)
    end
end

function Battle:updateEnemyAI(dt, player)
    local main = require('main')
    local map = main.get_map()
    local dx = self.player_grid_x - self.opponent_grid_x
    local dy = self.player_grid_y - self.opponent_grid_y
    local distance = math.max(math.abs(dx), math.abs(dy))
    
    -- Verificar se está adjacente ao jogador (distância = 1)
    if distance == 1 then
        -- Atacar diretamente
        self:performAttack(self.current_opponent, player)
        return
    end
    
    -- Se estiver longe, mover em direção ao jogador
    if distance > 1 then
        local new_gx, new_gy = self.opponent_grid_x, self.opponent_grid_y
        
        -- Escolher melhor movimento (priorizar eixo com maior distância)
        if math.abs(dx) > math.abs(dy) then
            new_gx = new_gx + (dx > 0 and 1 or -1)
        else
            new_gy = new_gy + (dy > 0 and 1 or -1)
        end
        
        -- Verificar limites da arena
        local arena_start_x = math.floor(self.arena_center_x / 32) - math.floor(self.arena_size / 2)
        local arena_start_y = math.floor(self.arena_center_y / 32) - math.floor(self.arena_size / 2)
        local arena_end_x = arena_start_x + self.arena_size - 1
        local arena_end_y = arena_start_y + self.arena_size - 1
        
        -- Verificar se pode mover (dentro da arena e terreno walkable)
        if new_gx >= arena_start_x and new_gx <= arena_end_x and
           new_gy >= arena_start_y and new_gy <= arena_end_y and
           self:canMoveTo(new_gx, new_gy, map) then
            
            self.opponent_grid_x = new_gx
            self.opponent_grid_y = new_gy
            local cell_size = 32
            local cell_offset = cell_size / 2
            self.current_opponent.x = self.opponent_grid_x * cell_size + cell_offset
            self.current_opponent.y = self.opponent_grid_y * cell_size + cell_offset
            bump_world:update(self.current_opponent, self.current_opponent.x, self.current_opponent.y)
        end
    end
    
    -- Voltar para turno do jogador
    self.current_state = BattleState.PLAYER_TURN
end

-- Função auxiliar para verificar se pode mover para uma posição
function Battle:canMoveTo(gx, gy, map)
    -- Verificar se o terreno é walkable
    if map and map.isWalkable then
        return map:isWalkable(gx, gy)
    end
    
    -- Fallback: permitir movimento se não houver mapa
    return true
end

function Battle:endBattle(victory)
    -- Reativar todos os monstros e torná-los visíveis novamente
    local main = require('main')
    local monsters = main.get_monsters()
    
    for _, monster in ipairs(monsters) do
        if monster ~= self.current_opponent then
            monster.active = true
            monster.visible = true
        end
    end
    
    if victory and self.current_opponent then
        -- Remover oponente do jogo
        self.current_opponent:destroy()
        -- Remover da lista de monstros
        main.remove_monster(self.current_opponent)
        self.current_opponent = nil
    end
    
    -- Resetar estado
    self.current_state = BattleState.PLAYER_TURN
    self.attack_feedback.active = false
    
    -- Mudar estado global para EXPLORATION
    main.set_current_state(main.GameState.EXPLORATION)
    
    print("Batalha terminada! Retornando à exploração.")
end

function Battle:drawArena(offset_x, offset_y, camera_x, camera_y)
    local main = require('main')
    local map = main.get_map()
    local arena_start_x = math.floor(self.arena_center_x / 32) - math.floor(self.arena_size / 2)
    local arena_start_y = math.floor(self.arena_center_y / 32) - math.floor(self.arena_size / 2)
    
    -- Calcular centro da tela para centralizar a arena
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()
    local arena_pixel_size = self.arena_size * 32
    local centered_offset_x = (screen_width - arena_pixel_size) / 2
    local centered_offset_y = (screen_height - arena_pixel_size) / 2
    
    -- Desenhar overlay escuro
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle('fill', 0, 0, screen_width, screen_height)
    
    -- Desenhar arena (área iluminada) com terreno real
    for y = 0, self.arena_size - 1 do
        for x = 0, self.arena_size - 1 do
            local world_x = arena_start_x + x
            local world_y = arena_start_y + y
            
            -- Obter cor do terreno real
            local color = {0.3, 0.9, 0.3} -- Verde padrão (floor)
            if map and map.getTerrain then
                local terrain = map:getTerrain(world_x, world_y)
                if terrain and map.TERRAIN_PROPS[terrain] then
                    color = map.TERRAIN_PROPS[terrain].color
                end
            end
            
            -- Desenhar tile da arena
            love.graphics.setColor(color[1], color[2], color[3], 1.0)
            love.graphics.rectangle(
                'fill',
                centered_offset_x + x * 32,
                centered_offset_y + y * 32,
                32, 32
            )
            
            -- Desenhar grid
            love.graphics.setColor(1, 1, 1, 0.3)
            love.graphics.rectangle(
                'line',
                centered_offset_x + x * 32,
                centered_offset_y + y * 32,
                32, 32
            )
        end
    end
    
    -- Desenhar oponente primeiro (para ficar atrás do player)
    if self.current_opponent then
        if self.attack_feedback.active and self.attack_feedback.target == self.current_opponent then
            -- Efeito de piscar
            local blink = math.sin(self.attack_feedback.timer * 20) > 0
            love.graphics.setColor(blink and 255 or 128, 0, 0)
        else
            love.graphics.setColor(255, 0, 0)
        end
        
        local opponent_screen_x = centered_offset_x + (self.opponent_grid_x - arena_start_x) * 32
        local opponent_screen_y = centered_offset_y + (self.opponent_grid_y - arena_start_y) * 32
        love.graphics.rectangle('fill', opponent_screen_x, opponent_screen_y, 32, 32)
        
        -- Barra de vida do oponente
        if self.current_opponent.health < self.current_opponent.max_health then
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle('fill', opponent_screen_x, opponent_screen_y - 8, 32, 4)
            
            local health_percent = self.current_opponent.health / self.current_opponent.max_health
            love.graphics.setColor(255, 0, 0)
            love.graphics.rectangle('fill', opponent_screen_x, opponent_screen_y - 8, 32 * health_percent, 4)
        end
    end
    
    -- Desenhar jogador por último (para ficar visível sobre o inimigo)
    love.graphics.setColor(0, 100, 255)
    local player_screen_x = centered_offset_x + (self.player_grid_x - arena_start_x) * 32
    local player_screen_y = centered_offset_y + (self.player_grid_y - arena_start_y) * 32
    love.graphics.rectangle('fill', player_screen_x, player_screen_y, 32, 32)
    
    -- Adicionar borda para melhor visibilidade
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle('line', player_screen_x, player_screen_y, 32, 32)
    
    -- Feedback visual com coordenadas de grid
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("P: %d,%d | E: %d,%d", 
        self.player_grid_x, self.player_grid_y, 
        self.opponent_grid_x, self.opponent_grid_y), 10, 50)
    
    -- Mostrar turno atual
    love.graphics.setColor(1, 1, 1)
    local turn_text = self.current_state == BattleState.PLAYER_TURN and "Seu Turno" or "Turno do Inimigo"
    love.graphics.print(turn_text, 10, 10)
    
    -- Mostrar vida do oponente
    if self.current_opponent then
        love.graphics.print(string.format("Inimigo: %d/%d HP", self.current_opponent.health, self.current_opponent.max_health), 10, 30)
    end
end

return Battle
