local Entity = require('src.entities.entity')

local Item = Entity:extend()

function Item:new(x, y)
    Item.super.new(self, x, y)
    self.type = "ITEM"
    self.width = 32
    self.height = 32
    self.collected = false
    
    -- Load sprite
    self.sprite = love.graphics.newImage('assets/sprites/potion.png')
    
    -- Add to bump world
    bump_world:add(self, self.x, self.y, self.width, self.height)
end

function Item:update(dt)
    -- Items might have a small floating animation
    self.float_offset = (self.float_offset or 0) + dt * 2
end

function Item:draw()
    if self.collected then return end
    
    local draw_y = self.y + math.sin(self.float_offset or 0) * 4
    
    -- Draw a small shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.ellipse('fill', self.x + self.width/2, self.y + self.height, 12, 4)
    
    -- Draw sprite
    love.graphics.setColor(1, 1, 1, 1)
    -- The sprite might be larger than 32x32, scale it to fit width/height
    local sw, sh = self.sprite:getDimensions()
    local scale_x = self.width / sw
    local scale_y = self.height / sh
    
    love.graphics.draw(self.sprite, self.x, draw_y, 0, scale_x, scale_y)
end

function Item:collect(player)
    if self.collected then return end
    
    self.collected = true
    player.health = player.max_health
    
    -- Remove from bump world
    bump_world:remove(self)
    
    print("Potion collected! Health restored.")
end

return Item
