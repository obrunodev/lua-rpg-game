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
    
    -- Iniciar no estado de exploração
    current_state = GameState.EXPLORATION
end

function love.update(dt)
    if current_state == GameState.EXPLORATION then
        player:update(dt)
    elseif current_state == GameState.BATTLE then
        -- Lógica de batalha
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
        
        -- Renderizar player
        love.graphics.push()
        love.graphics.translate(-camera_x, -camera_y)
        player:draw()
        love.graphics.pop()
        
        -- Mostrar coordenadas para debug
        local gx, gy = map:worldToGrid(player.x, player.y)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(string.format("World: (%.0f, %.0f) | Grid: (%d, %d)", player.x, player.y, gx, gy), 10, 10)
        
    elseif current_state == GameState.BATTLE then
        -- Exemplo de modo batalha: mostrar grid centralizado
        local offset_x = (1280 - 80 * 32) / 2
        local offset_y = (720 - 60 * 32) / 2
        
        -- Renderizar mapa em modo batalha
        map:drawBattle(offset_x, offset_y)
        
        -- Converter posição do player para grid e mostrar
        local gx, gy = map:worldToGrid(player.x, player.y)
        local wx, wy = map:gridToWorld(gx, gy)
        
        -- Desenhar indicador da posição do player no grid
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle(
            "fill",
            offset_x + gx * 32 + 8,
            offset_y + gy * 32 + 8,
            16, 16
        )
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(string.format("Battle Mode - Player at Grid: (%d, %d)", gx, gy), 10, 10)
        
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
    elseif key == 'b' then
        -- Alternar entre EXPLORATION e BATTLE
        if current_state == GameState.EXPLORATION then
            current_state = GameState.BATTLE
            print("Modo BATTLE ativado - posição convertida para grid")
        elseif current_state == GameState.BATTLE then
            current_state = GameState.EXPLORATION
            print("Modo EXPLORATION ativado - movimento livre")
        end
    end
end
