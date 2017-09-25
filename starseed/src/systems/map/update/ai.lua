local AIUpdate = tiny.processingSystem(class {})

AIUpdate.filter = tiny.requireAll('ai')

AIUpdate.isUpdateSystem = true

function AIUpdate:init()
    self.interval = 2 --process every 1 second
    self.accumulated = 0
end

function AIUpdate:preProcess(dt)
    --self.accumulated = self.accumulated + dt
end

function AIUpdate:process(e, dt)
    -- if math.floor(self.accumulated) % self.every == 0 then
    e.ai:setObject(e)
    e.ai:run()
    -- end
end

return AIUpdate