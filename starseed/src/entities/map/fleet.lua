local BaseEntity    = require 'src.entities.shared.base_entity'
local ShapeView     = require 'src.components.map.shape_view'
local Collision     = require 'src.components.shared.collision'
local Attributes    = require 'src.components.map.attributes'
local Movement      = require 'src.components.map.movement'
local FleetBehavior = require 'src.behavior.map.fleet'
local Position      = require 'src.components.shared.position'
local Tooltip       = require 'src.components.map.tooltip_data'
local View          = require 'src.components.shared.view'

local Fleet = class {} : include (BaseEntity)
local Unit  = class {}

function Fleet:init(ecs, registry, bump, x, y, pc)
    BaseEntity.init(self, ecs, registry, bump)

    self.units = {}

    if pc then
        --self:registerInputEvents()

        self:registerSignal (
            'get_player_ref',
            function()
                self:emit('broadcast_player_ref', self)
            end
        )

        self:registerSignal (
            'add_player_destination',
            function(x, y)
                self:emit('add_fleet_point_destination', x, y, self)
            end
        )

        self:registerSignal (
            'set_player_destination',
            function(x, y)
                self:emit('set_fleet_point_destination', x, y, self)
            end
        )

        self:registerSignal (
            'add_player_target',
            function(target)
                self:emit('add_fleet_target_destination', self, target)
            end
        )

        self:registerSignal (
            'set_player_target',
            function(target)
                self:emit('set_fleet_target_destination', self, target)
            end
        )
    else
        --add ai component
        self.ai = FleetBehavior
    end

    self.attributes = Attributes()

    self.position = Position (
        x,
        y,
        self.attributes.collide_width,
        self.attributes.collide_height
    )

    self.movement = Movement(self)

    self:registerSignal (
        tostring(self)..'_reached_goal',
        function()
            local goal = self.movement:getCurrentGoal()
            self.movement:clearCurrentGoal()
            self.movement:stop()
        end
    )

    --this needs to be CircleShapeView
    --for some reason circles' x/y coords are center of circle, unlike
    --all other coordinate based drawables :/
    self.view = View(90)
    self.view.sprite = lg.newImage('assets/sprites/ships/reaver.png')

    function self.view:draw(x, y)
        local ox, oy = self.sprite:getWidth()/2, self.sprite:getHeight()/2
        lg.draw(self.sprite, x, y, self.r, 1, 1, ox, oy)
    end

    local l, t, w, h = self.position:getBoundingRect()
    self.collision = Collision(l, t, w, h, bump, self)

    function self.collision.onCollide(c, other)
        if (not self.ai) and other.battle_candidate then
            if self.movement:getCurrentGoal() == other then
                self:emit('player_issue_challenge', self, other)
            end
        end

        if self.movement:getCurrentGoal() == other then
            self.movement:clearCurrentGoal()
            self.movement:stop()
        end

        -- if other.movement and (other.movement:getCurrentGoal() == self) then
        --     c.entity:emit(tostring(other)..'_reached_goal')
        -- end

    end

    self.battle_candidate = true

    self.tooltip_data = Tooltip(tostring(self))
end

function Fleet:addUnit(template)

end

function Fleet:explode()
    self:emit('ss_destroy_entity', self)
end

function Fleet:onDestroy()
    
end

function Fleet:registerInputEvents()
    --register all input signals
end

function Fleet:cleanUp()
    BaseEntity.cleanUp(self)
    --destroy tooltip
end

return Fleet