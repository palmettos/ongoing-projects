local BaseEntity = require 'src.entities.shared.base_entity'
local Position   = require 'src.components.shared.position'
local Collision  = require 'src.components.shared.collision'
local View       = require 'src.components.shared.view'
local Movement   = require 'src.components.battle.movement'

local Ship = class {} : include (BaseEntity)

function Ship:init(ecs, registry, bump, x, y, isPC)
    BaseEntity.init(self, ecs, registry, bump)

    if isPC then
        self:registerSignal (
            'request_player_ref',
            function()
                self:emit('broadcast_player_ref', self)
            end
        )

        self:registerSignal (
            'move',
            function(x, y)
                self.movement.movement_vector.x = self.movement.movement_vector.x + x
                self.movement.movement_vector.y = self.movement.movement_vector.y + y
                self:emit('debug_update_player_vector', self.movement.movement_vector)
            end
        )

        self:emit('broadcast_player_ref', self)

        --register all input signals
    end


    self.position = Position(x, y, 64, 64)

    self.movement = Movement()

    local l, t, w, h = self.position:getBoundingRect()
    self.collision = Collision(l, t, w, h, self.bump, self)

    self.view = View(99)
    self.view.sprite = lg.newImage('assets/sprites/ships/reaver.png')

    function self.view:draw(x, y)
        local ox, oy = self.sprite:getWidth()/2, self.sprite:getHeight()/2
        lg.draw(self.sprite, x, y, self.r, 1, 1, ox, oy)
    end
end

return Ship