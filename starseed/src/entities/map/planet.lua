local BaseEntity      = require 'src.entities.shared.base_entity'
-- local ShapeView       = require 'src.components.map.shape_view'
local View            = require 'src.components.shared.view'
local Collision       = require 'src.components.shared.collision'
local EllipticalOrbit = require 'src.components.map.elliptical_orbit'
local CircularOrbit   = require 'src.components.map.circular_orbit'
local Position        = require 'src.components.shared.position'
local Station         = require 'src.entities.map.station'
local Tooltip         = require 'src.components.map.tooltip_data'

local Planet = class {} : include (BaseEntity)

function Planet:init(ecs, registry, bump, center, orbit_radius, size, color)
    BaseEntity.init(self, ecs, registry, bump)

    self.orbit = CircularOrbit (
        center or {x=0, y=0},
        orbit_radius or rand(200, 1000)
    )

    local px, py = self.orbit:getPoint(self.orbit.t)
    self.position = Position(px, py, size*2, size*2)

    self.position.x = self.position.x + self.orbit.center.x
    self.position.y = self.position.y + self.orbit.center.y

    self.size = size

    -- local r, g, b = rand(0, 255), rand(0, 255), rand(0, 255)
    -- self.shapeView = ShapeView (
    --     self.position.x,
    --     self.position.y,
    --     size,
    --     color or {r, g, b, 255},
    --     97
    -- )

    self.view = View(91)

    local cxt = self
    function self.view:draw(x, y)
        lg.circle('fill', x, y, size)
        lg.setColor(255, 255, 255, 30)
        lg.circle('line', cxt.orbit.center.x, cxt.orbit.center.y, cxt.orbit.radius, 96)
        lg.setColor(255, 255, 255, 255)
    end
    
    local l, t, w, h = self.position:getBoundingRect()
    self.collision = Collision(l, t, w, h, bump, self)

    function self.collision.onCollide(c, other)
        if other.movement and (other.movement:getCurrentGoal() == self) then
            c.entity:emit(tostring(other)..'_reached_goal')
        end
    end

    -- self.registry:register (
    --     'generateStations',
    --     function(ecs)
    --         self:createStation(ecs)
    --     end
    -- )

    self.tooltip_data = Tooltip(tostring(self))
end

-- function Planet:createStation(ecs)
--     local station = Station (
--         self.systemRegistry,
--         self
--     )
--     self.children[#self.children+1] = station
--     tiny.add(ecs, station)
-- end

return Planet