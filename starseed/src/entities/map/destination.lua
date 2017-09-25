local BaseEntity = require 'src.entities.shared.base_entity'
local Collision  = require 'src.components.shared.collision'
local ShapeView  = require 'src.components.map.shape_view'
local Position   = require 'src.components.shared.position'

local Destination = class {} : include (BaseEntity)

function Destination:init(ecs, registry, bump, x, y, waitFor)
    BaseEntity.init(self, ecs, registry, bump)

    self.position  = Position(x, y, 5, 5)

    local l, t, w, h = self.position:getBoundingRect()
	self.collision = Collision(l, t, w, h, bump, self)

    local me = self
    self.collision.onCollide = function(self, other)
        if other.movement and other.movement:getCurrentGoal() == me then
            me:emit(tostring(other)..'_reached_goal')
        end
    end

    self.shapeView = ShapeView(l+w/2, t+h/2, 5, {50, 255, 50, 255}, 97)

    self.target = waitFor
end

function Destination:onGoalRemove()
    self:emit('ss_destroy_entity', self)
end

return Destination