local DrawCollision = tiny.processingSystem(class {})

DrawCollision.filter = tiny.requireAll('collision')

DrawCollision.isDrawSystem = true

function DrawCollision:process(e, dt)
    lg.setColor(255, 100, 100, 100)

    local l, t, w, h = e.collision.world:getRect(e)
    lg.rectangle('line', l, t, w, h)
    
    lg.setColor(255, 255, 255, 255)
end

return DrawCollision