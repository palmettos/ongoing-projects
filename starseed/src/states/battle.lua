local Battle = class {}

function Battle:init()
    print('battle init called')
    self.entities = {
        Ship = require 'src.entities.battle.ship'
    }

    self.ecs = tiny.world (
        --systems go here

        --update
        require 'src.systems.battle.update.position_movement'(),
        require 'src.systems.shared.update.position_collision'(),

        --draw
        require 'src.systems.shared.draw.position_view'()
    )

    self.bump = bump.newWorld(64)
    self.bump.maxDist = 10000

    self.registry = signal.new()

    self.camera = camera()

    self.events = utils.deque()

    self:registerSignal (
        'broadcast_player_ref',
        function(ref)
            self.playerRef = ref
        end
    )

    self.player_vector = {x = 0, y = 0}

    self:registerSignal (
        'debug_update_player_vector',
        function(vector)
            self.player_vector = vector
        end
    )
end

function Battle:emit(signal, ...)
    self.registry:emit(signal, ...)
end

function Battle:registerSignal(signal, func)
    self.registry:register(signal, func)
end

function Battle:registerEvent(signal, func)
    self.registry:register (
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

function Battle:addEvent(func)
    self.events:pushRight(func)
end

function Battle:processEvents()
    while self.events:len() > 0 do
        self.events:popLeft()()
    end
end

function Battle:enter(previous, fleet1, fleet2)
    self.fleet2 = fleet2
    self:createEntity('Ship', 100, 100, true)
    self:createEntity('Ship', 200, 200)
end

function Battle:leave()
    tiny.clearEntities(self.ecs)
end

function Battle:keypressed(key, isrepeat)
    if key == 'escape' then
        self.fleet2:explode()
        gs.pop()
    end

    if key == 'w' then
        self:emit('move', 0, -1)
    end

    if key == 'a' then
        self:emit('move', -1, 0)
    end

    if key == 's' then
        self:emit('move', 0, 1)
    end

    if key == 'd' then
        self:emit('move', 1, 0)
    end
end

function Battle:keyreleased(key)
    if key == 'w' then
        self:emit('move', 0, 1)
    end

    if key == 'a' then
        self:emit('move', 1, 0)
    end

    if key == 's' then
        self:emit('move', 0, -1)
    end

    if key == 'd' then
        self:emit('move', -1, 0)
    end
end

function Battle:draw()
    self.camera:attach()
    self.camera:lookAt(0, 0)
    tiny.update(self.ecs, nil, tiny.requireAll('isDrawSystem'))
    self.camera:detach()
    lg.print('x='..tostring(self.player_vector.x), 0, 0)
    lg.print('y='..tostring(self.player_vector.y), 10, 0)
end

function Battle:update(dt)
    tiny.update(self.ecs, dt, tiny.requireAll('isUpdateSystem'))
    self:processEvents()
end

function Battle:createEntity(entity, ...)
    local entity = self.entities[entity] (
        self.ecs,
        self.registry,
        self.bump,
        ...
    )

    tiny.add(self.ecs, entity)
    entity:onCreate()
    return entity
end

function Battle:destroyEntity(entity)
    entity:onDestroy()
    self.bump:remove(tiny.removeEntity(self.ecs, entity))
    entity:cleanUp()
end

function Battle:getColsByQueryRect(l, t, w, h, filter)
    local items, len = self.bump:queryRect(l, t, w, h, filter)
    return items, len
end

return Battle