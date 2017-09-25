local BaseEntity    = require 'src.entities.shared.base_entity'
local CircularOrbit = require 'src.components.map.circular_orbit'
local ShapeView     = require 'src.components.map.shape_view'
local CaptureNode   = require 'src.components.map.capture_node'

local Station = class {} : include (BaseEntity)

function Station:init(ecs, registry, bump, bodyToOrbit)
    BaseEntity.init(self, ecs, registry, bump)
    self.systemRegistry = registry

    self.orbit = CircularOrbit (
        {
            x = bodyToOrbit.x,
            y = bodyToOrbit.y
        },
        0 + rand(5, 10)
    )

    self.t = rand(1, 360)
    self.speed = rand()*0.1
    while self.speed == 0 do
        self.speed = rand(-1, 1)
    end

    self.x, self.y = self.orbit:getPoint(self.t)
    self.x = self.x + self.orbit.center.x
    self.y = self.y + self.orbit.center.y

    self.size = 2

    self.shapeView = ShapeView (
        self.x, self.y, 2,
        {0, 255, 0, 255},
        85
    )

    self.bodyToOrbit = bodyToOrbit

    self.isCaptureNode = CaptureNode()
end

return Station