local DrawCircularOrbit = tiny.processingSystem(class {})

DrawCircularOrbit.filter = tiny.requireAll('orbit')

DrawCircularOrbit.isDrawSystem = true

function DrawCircularOrbit:process(e, dt)
    lg.setColor(50, 50, 50, 255)
    lg.circle('line', e.orbit.center.x, e.orbit.center.y, e.orbit.radius)
    lg.setColor(255, 255, 255, 255)
end

return DrawCircularOrbit