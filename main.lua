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

function love.load()
    print("Ilha Obscura carregada com sucesso")
    
    -- Configurar resolução virtual (16:9 aspect ratio)
    push:setupScreen(1280, 720, 1280, 720, {
        fullscreen = false,
        resizable = false,
        vsync = 1
    })
    
    -- Criar player
    local Player = require('src.entities.player')
    player = Player(640, 360)
    
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
        -- Renderizar fundo
        love.graphics.setColor(50, 50, 50)
        love.graphics.rectangle('fill', 0, 0, 1280, 720)
        
        -- Renderizar player
        player:draw()
        
    elseif current_state == GameState.BATTLE then
        -- Renderizar tela de batalha
        love.graphics.setColor(100, 50, 50)
        love.graphics.rectangle('fill', 0, 0, 1280, 720)
        
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
    end
end
