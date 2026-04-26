local Map = {}
Map.__index = Map

-- Constants
local CELL_SIZE = 32
local MAP_WIDTH = 50
local MAP_HEIGHT = 50

-- Terrain types
local TERRAIN = {
    FLOOR = 0,
    STONE = 1,
    TREE = 2,
    WATER = 3
}

-- Terrain properties
local TERRAIN_PROPS = {
    [TERRAIN.FLOOR] = {
        color = {0.3, 0.9, 0.3},
        walkable = true,
        cover = 0,
        movement_cost = 1
    },
    [TERRAIN.STONE] = {
        color = {0.6, 0.6, 0.6},
        walkable = false,
        cover = 0.2,
        movement_cost = nil
    },
    [TERRAIN.TREE] = {
        color = {0.1, 0.5, 0.1},
        walkable = false,
        cover = 0.4,
        movement_cost = nil
    },
    [TERRAIN.WATER] = {
        color = {0.2, 0.4, 0.8},
        walkable = false,
        cover = 0,
        movement_cost = nil
    }
}

function Map.new(width, height, cell_size, bump_world)
    local self = setmetatable({}, Map)
    self.width = width or MAP_WIDTH
    self.height = height or MAP_HEIGHT
    self.cell_size = cell_size or CELL_SIZE
    self.grid = {}
    self.entities = {} -- Entities on the map for battle mode
    self.bump_world = bump_world
    
    self:generate()
    self:registerCollisions()
    return self
end

-- Convert world coordinates to grid coordinates
function Map:worldToGrid(x, y)
    local gx = math.floor(x / self.cell_size)
    local gy = math.floor(y / self.cell_size)
    
    -- Clamp to map bounds
    gx = math.max(0, math.min(gx, self.width - 1))
    gy = math.max(0, math.min(gy, self.height - 1))
    
    return gx, gy
end

-- Convert grid coordinates to world coordinates (center of cell)
function Map:gridToWorld(gx, gy)
    local x = gx * self.cell_size + self.cell_size / 2
    local y = gy * self.cell_size + self.cell_size / 2
    return x, y
end

-- Get terrain at grid position
function Map:getTerrain(gx, gy)
    if gx < 0 or gx >= self.width or gy < 0 or gy >= self.height then
        return nil
    end
    return self.grid[gy][gx]
end

-- Check if position is walkable
function Map:isWalkable(gx, gy)
    local terrain = self:getTerrain(gx, gy)
    if not terrain then return false end
    return TERRAIN_PROPS[terrain].walkable
end

-- Get movement cost for battle mode
function Map:getMovementCost(gx, gy)
    local terrain = self:getTerrain(gx, gy)
    if not terrain then return math.huge end
    return TERRAIN_PROPS[terrain].movement_cost or math.huge
end

-- Get cover bonus for battle mode
function Map:getCover(gx, gy)
    local terrain = self:getTerrain(gx, gy)
    if not terrain then return 0 end
    return TERRAIN_PROPS[terrain].cover or 0
end

-- Register collision objects with Bump world
function Map:registerCollisions()
    if not self.bump_world then return end
    
    for y = 0, self.height - 1 do
        for x = 0, self.width - 1 do
            local terrain = self.grid[y][x]
            if not TERRAIN_PROPS[terrain].walkable then
                -- Add collision rectangle for solid tiles
                local tile_x = x * self.cell_size
                local tile_y = y * self.cell_size
                self.bump_world:add(
                    "tile_" .. x .. "_" .. y,
                    tile_x, tile_y,
                    self.cell_size, self.cell_size
                )
            end
        end
    end
end

-- Generate procedural map using cellular automata
function Map:generate()
    -- Initialize grid with random noise
    for y = 0, self.height - 1 do
        self.grid[y] = {}
        for x = 0, self.width - 1 do
            if math.random() < 0.45 then
                self.grid[y][x] = TERRAIN.STONE
            else
                self.grid[y][x] = TERRAIN.FLOOR
            end
        end
    end
    
    -- Apply cellular automata rules
    for _ = 1, 5 do
        self:smoothMap()
    end
    
    -- Add features
    self:addWater()
    self:addTrees()
end

-- Smooth map using cellular automata
function Map:smoothMap()
    local new_grid = {}
    
    for y = 0, self.height - 1 do
        new_grid[y] = {}
        for x = 0, self.width - 1 do
            local stone_neighbors = self:countNeighbors(x, y, TERRAIN.STONE)
            
            if stone_neighbors > 4 then
                new_grid[y][x] = TERRAIN.STONE
            else
                new_grid[y][x] = TERRAIN.FLOOR
            end
        end
    end
    
    self.grid = new_grid
end

-- Count neighbors of specific terrain type
function Map:countNeighbors(gx, gy, terrain_type)
    local count = 0
    
    for dy = -1, 1 do
        for dx = -1, 1 do
            if dx == 0 and dy == 0 then goto continue end
            
            local nx, ny = gx + dx, gy + dy
            if nx >= 0 and nx < self.width and ny >= 0 and ny < self.height then
                if self.grid[ny][nx] == terrain_type then
                    count = count + 1
                end
            end
            
            ::continue::
        end
    end
    
    return count
end

-- Add water features
function Map:addWater()
    -- Add some water pools
    for _ = 1, math.random(3, 6) do
        local x = math.random(2, self.width - 3)
        local y = math.random(2, self.height - 3)
        local size = math.random(2, 4)
        
        for dy = -size, size do
            for dx = -size, size do
                if dx * dx + dy * dy <= size * size then
                    local nx, ny = x + dx, y + dy
                    if nx >= 0 and nx < self.width and ny >= 0 and ny < self.height then
                        if math.random() < 0.8 then
                            self.grid[ny][nx] = TERRAIN.WATER
                        end
                    end
                end
            end
        end
    end
end

-- Add tree areas
function Map:addTrees()
    -- Add tree patches
    for _ = 1, math.random(4, 8) do
        local x = math.random(1, self.width - 2)
        local y = math.random(1, self.height - 2)
        local size = math.random(3, 6)
        
        for dy = -size, size do
            for dx = -size, size do
                if dx * dx + dy * dy <= size * size then
                    local nx, ny = x + dx, y + dy
                    if nx >= 0 and nx < self.width and ny >= 0 and ny < self.height then
                        if self.grid[ny][nx] == TERRAIN.FLOOR and math.random() < 0.7 then
                            self.grid[ny][nx] = TERRAIN.TREE
                        end
                    end
                end
            end
        end
    end
end


-- Draw map for exploration mode
function Map:drawExplored(camera_x, camera_y, screen_w, screen_h)
    local start_x = math.max(0, math.floor(camera_x / self.cell_size))
    local end_x = math.min(self.width - 1, math.ceil((camera_x + screen_w) / self.cell_size))
    local start_y = math.max(0, math.floor(camera_y / self.cell_size))
    local end_y = math.min(self.height - 1, math.ceil((camera_y + screen_h) / self.cell_size))
    
    for y = start_y, end_y do
        for x = start_x, end_x do
            local terrain = self.grid[y][x]
            local color = TERRAIN_PROPS[terrain].color
            
            love.graphics.setColor(color)
            love.graphics.rectangle(
                "fill",
                x * self.cell_size - camera_x,
                y * self.cell_size - camera_y,
                self.cell_size,
                self.cell_size
            )
        end
    end
end

-- Draw map for battle mode (grid view)
function Map:drawBattle(offset_x, offset_y)
    love.graphics.setColor(1, 1, 1, 0.3)
    
    -- Draw grid lines
    for x = 0, self.width do
        love.graphics.line(
            offset_x + x * self.cell_size,
            offset_y,
            offset_x + x * self.cell_size,
            offset_y + self.height * self.cell_size
        )
    end
    
    for y = 0, self.height do
        love.graphics.line(
            offset_x,
            offset_y + y * self.cell_size,
            offset_x + self.width * self.cell_size,
            offset_y + y * self.cell_size
        )
    end
    
    -- Draw terrain
    for y = 0, self.height - 1 do
        for x = 0, self.width - 1 do
            local terrain = self.grid[y][x]
            local color = TERRAIN_PROPS[terrain].color
            
            love.graphics.setColor(color[1], color[2], color[3], 0.8)
            love.graphics.rectangle(
                "fill",
                offset_x + x * self.cell_size,
                offset_y + y * self.cell_size,
                self.cell_size,
                self.cell_size
            )
        end
    end
end

-- Public access to constants
Map.TERRAIN = TERRAIN
Map.TERRAIN_PROPS = TERRAIN_PROPS

return Map
