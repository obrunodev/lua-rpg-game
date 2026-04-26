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
local npcs = {} -- Lista de NPCs no jogo
local items = {} -- Lista de itens no jogo
local health_bar

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
    
    -- Criar Health UI
    local HealthBar = require('src.ui.health_bar')
    health_bar = HealthBar(player)
    
    -- Criar itens (Potions)
    local Item = require('src.entities.item')
    local spawned_items = 0
    while spawned_items < 5 do
        local gx = math.random(0, map.width - 1)
        local gy = math.random(0, map.height - 1)
        
        if map:isWalkable(gx, gy) then
            local x, y = gx * map.cell_size, gy * map.cell_size
            local item = Item(x, y)
            table.insert(items, item)
            spawned_items = spawned_items + 1
        end
    end
    
    -- Criar alguns NPCs para teste
    local NPC = require('src.entities.npc')
    for i = 1, 5 do
        local gx = math.random(0, map.width - 1)
        local gy = math.random(0, map.height - 1)
        
        if map:isWalkable(gx, gy) then
            local x, y = gx * map.cell_size, gy * map.cell_size
            local npc = NPC(x, y)
            table.insert(npcs, npc)
        end
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
        
        -- Atualizar Itens
        for _, item in ipairs(items) do
            item:update(dt)
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
        
        -- Renderizar Itens
        for _, item in ipairs(items) do
            item:draw()
        end
        
        -- Renderizar player
        player:draw()
        
        love.graphics.pop()
        
        -- Renderizar UI (sem transformação da câmera)
        health_bar:draw()
        
        -- Mostrar coordenadas para debug
        local gx, gy = map:worldToGrid(player.x, player.y)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(string.format("World: (%.0f, %.0f) | Grid: (%d, %d)", player.x, player.y, gx, gy), 10, 50)
        
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
