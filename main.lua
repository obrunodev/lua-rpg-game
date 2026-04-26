print("Iniciando Ilha Obscura")

-- Carregar bibliotecas
require('src.loader')

-- Estados do jogo
local GameState = {
    MENU = "MENU",
    EXPLORATION = "EXPLORATION",
    BATTLE = "BATTLE"
}

local current_state = GameState.MENU
local player
local map
local battle_system
local npcs = {} -- Lista de NPCs no jogo

function love.load()
    print("Ilha Obscura carregada com sucesso")
    
    -- Configurar resolução virtual (16:9 aspect ratio)
    push:setupScreen(1280, 720, 1280, 720, {
        fullscreen = false,
        resizable = false,
        vsync = 1
    })
    
    -- Criar mapa procedural
    local Map = require('src.systems.map_gen')
    map = Map.new(80, 60, 32, bump_world)
    
    -- Criar player
    local Player = require('src.entities.player')
    player = Player(1280, 960) -- Centro do mapa (40 * 32, 30 * 32)
    
    -- Criar sistema de batalha
    local Battle = require('src.systems.battle')
    battle_system = Battle.new()
    
    -- Criar alguns NPCs para teste
    package.loaded['src.entities.npc'] = nil -- Forçar recarga
    local NPC = require('src.entities.npc')
    for i = 1, 5 do
        local mx = math.random(200, 2360)
        local my = math.random(200, 1720)
        local npc = NPC(mx, my)
        table.insert(npcs, npc)
    end
    
    -- Iniciar no estado de exploração
    current_state = GameState.EXPLORATION
end

function love.update(dt)
    if current_state == GameState.EXPLORATION then
        player:update(dt)
        
        -- Atualizar NPCs
        for _, npc in ipairs(npcs) do
            if npc.active then
                npc:update(dt)
            end
        end
        
    elseif current_state == GameState.BATTLE then
        battle_system:update(dt, player)
    elseif current_state == GameState.MENU then
        -- Lógica de menu
    end
end

function love.draw()
    -- Iniciar renderização virtual
    push:start()
    
    if current_state == GameState.EXPLORATION then
        -- Calcular câmera para seguir o player
        local camera_x = player.x - 640
        local camera_y = player.y - 360
        
        -- Renderizar mapa
        map:drawExplored(camera_x, camera_y, 1280, 720)
        
        -- Renderizar entidades do mundo (player e monstros) com transformação da câmera
        love.graphics.push()
        love.graphics.translate(-camera_x, -camera_y)
        
        -- Renderizar NPCs
        for _, npc in ipairs(npcs) do
            if npc.visible then
                npc:draw()
            end
        end
        
        -- Renderizar player
        player:draw()
        
        love.graphics.pop()
        
        -- Mostrar coordenadas para debug
        local gx, gy = map:worldToGrid(player.x, player.y)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(string.format("World: (%.0f, %.0f) | Grid: (%d, %d)", player.x, player.y, gx, gy), 10, 10)
        
    elseif current_state == GameState.BATTLE then
        -- Calcular câmera focada nos combatentes
        -- Obter posições dos combatentes
        local player_world_x = battle_system.player_grid_x * 32 + 16
        local player_world_y = battle_system.player_grid_y * 32 + 16
        local opponent_world_x = battle_system.opponent_grid_x * 32 + 16
        local opponent_world_y = battle_system.opponent_grid_y * 32 + 16
        
        -- Calcular centro entre os combatentes
        local center_x = (player_world_x + opponent_world_x) / 2
        local center_y = (player_world_y + opponent_world_y) / 2
        
        -- Calcular câmera para mostrar a arena 10x10 ao redor do centro
        local arena_size_pixels = battle_system.arena_size * 32
        local camera_x = center_x - arena_size_pixels / 2
        local camera_y = center_y - arena_size_pixels / 2
        
        -- Calcular offset para desenhar arena centralizada na tela
        local arena_offset_x = (1280 - arena_size_pixels) / 2
        local arena_offset_y = (720 - arena_size_pixels) / 2
        
        -- Desenhar arena de combate com a câmera ajustada
        battle_system:drawArena(arena_offset_x, arena_offset_y, camera_x, camera_y)
        
    elseif current_state == GameState.MENU then
        -- Renderizar menu
        love.graphics.setColor(30, 30, 30)
        love.graphics.rectangle('fill', 0, 0, 1280, 720)
    end
    
    -- Finalizar renderização virtual
    push:finish()
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif current_state == GameState.BATTLE then
        -- Movimento tático no modo batalha
        battle_system:handlePlayerInput(key, player)
    end
end

-- Exportar para outros módulos
return {
    GameState = GameState,
    current_state = function() return current_state end,
    set_current_state = function(state) current_state = state end,
    get_monsters = function() return npcs end,
    remove_monster = function(npc)
        for i, n in ipairs(npcs) do
            if n == npc then
                table.remove(npcs, i)
                break
            end
        end
    end,
    get_battle_system = function() return battle_system end,
    get_map = function() return map end
}
