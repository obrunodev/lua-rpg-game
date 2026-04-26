# Escopo Técnico: Ilha Obscura

## 1. Visão Geral
- Gênero: Survival Rogue-like Top-Down.
- Estilo de Combate: Turn-based em Grid (ativado por contato).
- Narrativa: Obscura, 20 participantes, apenas 1 sobrevive.

## 2. Pilares de Gameplay (POC)
- [x] **Exploração**: Movimento WASD com colisões (Bump.lua).
- [ ] **Sobrevivência**: Sistema de Fome/Frio que drena vida.
- [ ] **NPCs**: 19 agentes com IA de máquina de estados (Busca/Fuga/Luta).
- [ ] **Mapa**: Geração procedural via Cellular Automata.
- [ ] **Batalha**: Sistema de turnos com grid 10x10.

## 3. Roadmap da POC - Fases de Implementação

### Fase 1: Boilerplate & Movimentação (Semanas 1-2) ✅ CONCLUÍDA
- [x] Configurar estrutura básica do projeto
- [x] Implementar máquina de estados no main.lua
- [x] Criar classe Player básica com movimentação WASD
- [x] Integrar bump.lua para colisões
- [x] Setup de resolução virtual com push.lua

### Fase 2: Mapa Procedural (Semanas 3-4)
- [ ] Implementar gerador de mapa via Cellular Automata
- [ ] Criar sistema de renderização de tiles
- [ ] Definir tipos de terreno (grama, água, pedra)
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

## 4. Fluxo de Dados (Data Driven)
- Itens são definidos em `src/data/items_db.lua`.
- Atributos base em `src/data/constants.lua`.
- Configurações de IA em `src/data/ai_behaviors.lua`.

## 5. Dependências Externas
- `bump.lua`: Detecção de colisão
- `anim8.lua`: Sistema de animação
- `push.lua`: Resolução virtual
- `classic.lua`: Sistema de classes
- `flux.lua`: Tweening e animações

## 6. Métricas de Sucesso da POC
- [ ] Player consegue explorar mapa procedural
- [ ] Sistema de sobrevivência funcional (fome/frio)
- [ ] NPCs interagem via máquina de estados
- [ ] Transição para combate funciona
- [ ] Performance estável (>30 FPS)
