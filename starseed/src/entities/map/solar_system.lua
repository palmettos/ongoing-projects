local Planet      = require 'src.entities.map.planet'
local Fleet       = require 'src.entities.map.fleet'
local Destination = require 'src.entities.map.destination'
--local Boundary    = require 'src.entities.map.zone_boundary'

local SolarSystem = class {}

function SolarSystem:init(mapRegistry)
    self.ecs = tiny.world (

        --draw order
        --eventually draw orbits once on its own transparent canvas
        --disable to save the frames
        --require 'src.systems.map.draw.circular_orbit'(),
        require 'src.systems.shared.draw.position_view'(),
        --require 'src.systems.map.draw.shape_sprite'(),
        --require 'src.systems.map.draw.collision'(),

        --give all entities event handlers? update entity events?

        --update system order
        require 'src.systems.map.update.attributes_movement'(),

        --all movements modifying positions
        require 'src.systems.map.update.position_movement'(),
        require 'src.systems.map.update.position_orbit'(),

        --process before collision due to mouse sensor activation
        --we could deactivate all entities in a more clearly defined
        --system for setting preprocessing ui flags sometime later
        --for now this doesn't conflict with anything and shouldn't
        --necessarily ever
        require 'src.systems.map.update.position_tooltip'(),

        --collisions
        require 'src.systems.shared.update.position_collision'(),

        --views
        require 'src.systems.map.update.movement_view'(),

        --ai
        require 'src.systems.map.update.ai'()

        --ui?
    )

    self.entities = {
        Planet      = Planet,
        Fleet       = Fleet,
        Destination = Destination,
        MouseSensor = MouseSensor
        --Boundary    = Boundary
    }

    self.bump = bump.newWorld(64)

    self.mapRegistry = mapRegistry
    self.systemRegistry = signal.new()

    self.mapCameraState = nil

    self.events = utils.deque()

    self.mapRegistry:register (
        'generatePlanets',
        function()
            self:generatePlanets()
        end
    )

    self.mapRegistry:register (
        'generateNeutralFleets',
        function()
            self:generateNeutralFleets()
        end
    )

    self.mapRegistry:register (
        'update_camera_state',
        function(camera)
            self.mapCameraState = camera
            self:emit('update_camera_state', camera)
        end
    )

    -- self.systemRegistry:register (
    --     'setMovementDestination',
    --     function(entity, x, y)
    --         entity.movement.destination = {
    --             x = x,
    --             y = y
    --         }
    --         -- local dest = Destination (
    --         --     x,
    --         --     y,
    --         --     self.bump,
    --         --     self.systemRegistry,
    --         --     entity
    --         -- )
    --         -- tiny.add(self.ecs, dest)

    --         if entity == self.player then
    --             self.playerDestination = self:createEntity('Destination', x, y, entity)
    --         else
    --             self:createEntity('Destination', x, y, entity)
    --         end
    --     end
    -- )

    -- self.systemRegistry:register (
    --     'ss_dest_reached',
    --     function(dest, entity)
    --         self.systemRegistry:emit('destroy', dest)
    --         entity.movement:reset()
    --     end
    -- )

    -- self.systemRegistry:register (
    --     'create',
    --     function(entity, ...)
    --         local t = ...
    --         self:addEvent (
    --             self:createEntity(entity, unpack(t))
    --         )
    --     end
    -- )

    self:registerEvent (
        'ss_create_entity',
        function(entity, ...)
            self:createEntity(entity, ...)
        end
    )

    self:registerEvent (
        'ss_destroy_entity',
        function(entity)
            self:destroyEntity(entity)
        end
    )

    self:registerSignal (
        'add_fleet_point_destination',
        function(destX, destY, fleet)
            fleet.movement:prependGoal (
                self:createEntity (
                    'Destination',
                    destX,
                    destY,
                    fleet
                )
            )
        end
    )

    self:registerSignal (
        'set_fleet_point_destination',
        function(destX, destY, fleet)
            fleet.movement:clearGoals()
            fleet.movement:appendGoal (
                self:createEntity (
                    'Destination',
                    destX,
                    destY,
                    fleet
                )
            )
        end
    )

    self:registerSignal (
        'set_fleet_target_destination',
        function(fleet, target)
            fleet.movement:setGoal(target)
        end
    )

    self:registerSignal (
        'add_fleet_target_destination',
        function(fleet, target)
            fleet.movement:prependGoal(target)
        end
    )

    self:registerSignal (
        'player_issue_challenge',
        function(player, other)
            self.mapRegistry:emit (
                'player_issue_challenge',
                player, other
            )
        end
    )

    self:registerSignal (
        'broadcast_player_ref',
        function(player)
            self.mapRegistry:emit('broadcast_player_ref', player)
        end
    )

    self.mapRegistry:register (
        'get_player_ref',
        function()
            self:emit('get_player_ref')
        end
    )


    -- self:registerSignal (
    --     ''
    -- )

    -- self.systemRegistry:register (
    --     'destroy',
    --     function(entity)
    --         self:addEvent (
    --             function()
    --                 self:destroyEntity(entity)
    --             end
    --         )
    --     end
    -- )

end

function SolarSystem:emit(signal, ...)
    self.systemRegistry:emit(signal, ...)
end

function SolarSystem:registerSignal(signal, func)
    self.systemRegistry:register(signal, func)
end

function SolarSystem:registerEvent(signal, func)
    self.systemRegistry:register (
        signal,
        function(...)
            local t = {...}
            self:addEvent (
                function()
                    func(unpack(t))
                end
            )
        end
    )
end

function SolarSystem:addEvent(func)
    self.events:pushRight(func)
end

function SolarSystem:processEvents()
    while self.events:len() > 0 do
        self.events:popLeft()()
    end
end

function SolarSystem:draw()
    tiny.update(self.ecs, 0, tiny.requireAll('isDrawSystem'))
end

function SolarSystem:update(dt)

    if self.mapCameraState then
        local x, y = self.mapCameraState:worldCoords(lm.getX(), lm.getY())
        self:emit('ss_mouse_sensor_coords', x, y)
    end

    tiny.update(self.ecs, dt, tiny.requireAll('isUpdateSystem'))
    self:processEvents()
end

function SolarSystem:createEntity(entity, ...)
    local entity = self.entities[entity] (
        self.ecs,
        self.systemRegistry,
        self.bump,
        ...
    )

    tiny.add(self.ecs, entity)
    entity:onCreate()
    return entity
end

function SolarSystem:destroyEntity(entity)
    entity:onDestroy()
    self.bump:remove(tiny.removeEntity(self.ecs, entity))
    entity:cleanUp()
end

function SolarSystem:generatePlanets()
    self:createEntity('Planet', {x=0, y=0}, 0, 200, {100, 255, 255, 255})

    local minOrbitRadius = 650
    local maxOrbitRadius = 700
    local swayRange      = 400
    local minSize        = 75
    local maxSize        = 125

    local largest = 0

    for i=1, 8 do--rand(4, 8) do
        local thisRadius = i * rand(minOrbitRadius, maxOrbitRadius) + largest/2
        local swayX      = rand(-swayRange, swayRange)*largest/thisRadius
        local swayY      = rand(-swayRange, swayRange)*largest/thisRadius
        local size       = rand(minSize, maxSize)
        self:createEntity('Planet', {x=0+swayX, y=0+swayY}, thisRadius, size)

        largest = thisRadius
    end

    self.bump.maxDist = largest + largest * 0.25
   --local boundarySideLength = largest * 2 + largest * 0.5
   --self:createEntity('Boundary', boundarySideLength)
end

function SolarSystem:createPlanet()
    self:createEntity('Planet')
end

function SolarSystem:generateNeutralFleets()
    for i=1, 16 do
        self:createNeutralFleet()
    end
end

function SolarSystem:createPlayer()
    local x = rand(-self.bump.maxDist, self.bump.maxDist)
    local y = rand(-self.bump.maxDist, self.bump.maxDist)
    self:createEntity('Fleet', x, y, true)
end

function SolarSystem:createNeutralFleet()
    local x = rand(-self.bump.maxDist, self.bump.maxDist)
    local y = rand(-self.bump.maxDist, self.bump.maxDist)
    self:createEntity('Fleet', x, y)
end

--[[----------------------------------------------------------------------------
-- Return all collisions inside given query rect.
--]]----------------------------------------------------------------------------
function SolarSystem:getColsByQueryRect(l, t, w, h, filter)
    local items, len = self.bump:queryRect(l, t, w, h, filter)
    return items, len
end

function SolarSystem:activate()
    --local x, y = self.mapCameraState:worldCoords(lm.getX(), lm.getY())
    --self:emit('ss_create_entity', 'MouseSensor', x, y, self.mapCameraState.scale)
end

function SolarSystem:deactivate()
    self:emit('ss_deactivate')
end

return SolarSystem