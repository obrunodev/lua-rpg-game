# Escopo Técnico: Ilha Obscura

## 1. Visão Geral
- Gênero: Survival Rogue-like Top-Down.
- Estilo de Combate: Turn-based em Grid (ativado por contato).
- Narrativa: Obscura, 20 participantes, apenas 1 sobrevive.

## 2. Pilares de Gameplay (POC)
- [x] **Exploração**: Movimento WASD com colisões (Bump.lua).
- [ ] **Sobrevivência**: Sistema de Fome/Frio que drena vida.
- [ ] **NPCs**: 19 agentes com IA de máquina de estados (Busca/Fuga/Luta).
- [x] **Mapa**: Geração procedural via Cellular Automata.
- [x] **Batalha**: Sistema de turnos com grid e conversão de coordenadas.

## 3. Roadmap da POC - Fases de Implementação

### Fase 1: Boilerplate & Movimentação (Semanas 1-2) ✅ CONCLUÍDA
- [x] Configurar estrutura básica do projeto
- [x] Implementar máquina de estados no main.lua
- [x] Criar classe Player básica com movimentação WASD
- [x] Integrar bump.lua para colisões
- [x] Setup de resolução virtual com push.lua

### Fase 2: Mapa Procedural (Semanas 3-4) ✅ CONCLUÍDA
- [x] Implementar gerador de mapa via Cellular Automata
- [x] Criar sistema de renderização de tiles
- [x] Definir tipos de terreno (CHÃO, PEDRA, ÁRVORE, ÁGUA)
- [x] Implementar colisões reais com Bump.lua
- [x] Sistema de conversão worldToGrid/gridToWorld
- [ ] Implementar sistema de spawn de itens no mapa

### Fase 3: NPCs & IA (Semanas 5-6)
- [ ] Criar classe base Entity com Classic.lua
- [ ] Implementar 19 NPCs com IA básica
- [ ] Máquina de estados: Patrulha → Busca → Fuga → Combate
- [ ] Sistema de percepção (visão/audição)

### Fase 4: Sobrevivência & Itens (Semanas 7-8)
- [ ] Implementar sistema de fome/frio
- [ ] Criar database de itens em `src/data/items_db.lua`
- [ ] Sistema de inventário simples
- [ ] Efeitos de status e regeneração

### Fase 5: Sistema de Batalha (Semanas 9-10)
- [ ] Implementar grid de combate 10x10
- [ ] Sistema de turnos com iniciativa
- [ ] Ações básicas: atacar, defender, usar item
- [ ] Transição suave entre exploração e combate

## 4. Arquitetura de Sistemas Implementados

### 4.1 Sistema de Mapa (`src/systems/map_gen.lua`)
- **Geração Procedural**: Cellular Automata com 5 iterações
- **Tipos de Tiles**: CHÃO (0), PEDRA (1), ÁRVORE (2), ÁGUA (3)
- **Colisões**: Registro automático no Bump.lua para tiles sólidos
- **Conversão de Coordenadas**: `worldToGrid(x, y)` e `gridToWorld(gx, gy)`
- **Renderização Dual**: Modo EXPLORATION (livre) e BATTLE (grid)

### 4.2 Sistema de Entidades
- **Entity Base**: Classe base em `src/entities/entity.lua` (Classic.lua)
- **Player**: Movimento WASD com colisões via `bump_world:move()`
- **Integração**: Player registrado no mundo Bump com colisões reais

### 4.3 Estados do Jogo
- **EXPLORATION**: Movimento livre com câmera seguindo player
- **BATTLE**: Visualização em grid com coordenadas convertidas
- **Transição**: Tecla 'B' alterna entre modos

## 5. Fluxo de Dados (Data Driven)
- Itens são definidos em `src/data/items_db.lua`.
- Atributos base em `src/data/constants.lua`.
- Configurações de IA em `src/data/ai_behaviors.lua`.

## 6. Dependências Externas
- `bump.lua`: Detecção de colisão
- `anim8.lua`: Sistema de animação
- `push.lua`: Resolução virtual
- `classic.lua`: Sistema de classes
- `flux.lua`: Tweening e animações

## 7. Métricas de Sucesso da POC
- [x] Player consegue explorar mapa procedural
- [ ] Sistema de sobrevivência funcional (fome/frio)
- [ ] NPCs interagem via máquina de estados
- [x] Transição para combate funciona
- [x] Colisões funcionam com tiles sólidos
- [x] Performance estável (>30 FPS)
