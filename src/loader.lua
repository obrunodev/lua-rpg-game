-- Carregador de bibliotecas essenciais para Ilha Obscura
-- Todas as bibliotecas são carregadas como variáveis locais

-- Sistema de Orientação a Objetos
local classic = require('lib.classic')
_G.Object = classic.class

-- Sistema de Colisão
local bump = require('lib.bump')
bump_world = bump.newWorld()

-- Resolução Virtual
local push = require('lib.push')

-- Sistema de Animação
local anim8 = require('lib.anim8')

-- Sistema de Tweens
local flux = require('lib.flux')

-- Exportar bibliotecas para uso global no projeto
_G.bump_world = bump_world
_G.push = push
_G.anim8 = anim8
_G.flux = flux

print("Bibliotecas carregadas: Classic, Bump, Push, Anim8, Flux")
