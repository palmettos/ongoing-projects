local BaseEntity = class {}

function BaseEntity:init(ecs, registry, bump)
    self.ecs      = ecs
    self.registry = registry
    self.bump     = bump
    self.signals = {}
end

function BaseEntity:setECS(ecs)
    self.ecs = ecs
end

function BaseEntity:setRegistry(registry)
    self.registry = registry
end

function BaseEntity:registerSignal(signal, func)
    self.signals[signal] = self.registry:register(signal, func)
end

function BaseEntity:removeSignal(signal)
    self.registry:remove(signal, self.signals[signal])
    self.signals[signal] = nil
end

function BaseEntity:clearSignals()
    for signal in pairs(self.signals) do
        self:removeSignal(signal)
    end
end

function BaseEntity:emit(signal, ...)
    self.registry:emit(signal, ...)
end

function BaseEntity:setBumpWorld(bump)
    self.bump = bump
end

function BaseEntity:onCreate()
    --virtual
end

function BaseEntity:onGoalRemove()
    --virtual
end

function BaseEntity:onDestroy()
    --virtual
end

function BaseEntity:cleanUp()
    self:clearSignals()
end

return BaseEntity