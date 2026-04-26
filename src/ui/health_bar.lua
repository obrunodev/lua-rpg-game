local Object = require('lib.classic')
local HealthBar = Object:extend()

function HealthBar:new(player)
    self.player = player
    self.x = 20
    self.y = 20
    self.width = 250
    self.height = 25
    
    -- Colors
    self.bg_color = {0.1, 0.1, 0.1, 0.8}
    self.border_color = {0.8, 0.8, 0.8, 1}
    self.health_color = {0.8, 0.1, 0.1, 1}
    self.health_bg_color = {0.3, 0.05, 0.05, 1}
    self.text_color = {1, 1, 1, 1}
end

function HealthBar:draw()
    local hp_percent = self.player.health / self.player.max_health
    
    -- Draw outer shadow/glow
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle('fill', self.x + 2, self.y + 2, self.width, self.height, 4)
    
    -- Draw background
    love.graphics.setColor(unpack(self.bg_color))
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height, 4)
    
    -- Draw health background (darker red)
    love.graphics.setColor(unpack(self.health_bg_color))
    love.graphics.rectangle('fill', self.x + 4, self.y + 4, self.width - 8, self.height - 8, 2)
    
    -- Draw health fill (vibrant red)
    if hp_percent > 0 then
        love.graphics.setColor(unpack(self.health_color))
        love.graphics.rectangle('fill', self.x + 4, self.y + 4, (self.width - 8) * hp_percent, self.height - 8, 2)
        
        -- Add a subtle gradient/highlight on top
        love.graphics.setColor(1, 1, 1, 0.2)
        love.graphics.rectangle('fill', self.x + 4, self.y + 4, (self.width - 8) * hp_percent, (self.height - 8) / 2, 2)
    end
    
    -- Draw border
    love.graphics.setLineWidth(2)
    love.graphics.setColor(unpack(self.border_color))
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height, 4)
    
    -- Draw text
    love.graphics.setColor(unpack(self.text_color))
    local hp_text = string.format("HP: %d / %d", math.ceil(self.player.health), self.player.max_health)
    love.graphics.print(hp_text, self.x + self.width + 10, self.y + 4)
    
    love.graphics.setColor(1, 1, 1, 1)
end

return HealthBar
