local Object = require('lib.classic')
local Entity = Object:extend()

function Entity:new(x, y)
    self.x = x or 0
    self.y = y or 0
    self.width = 32
    self.height = 32
end

function Entity:update(dt)
    -- Override in subclasses
end

function Entity:draw()
    -- Override in subclasses
end

return Entity
