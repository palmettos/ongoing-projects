local PositionOrbitUpdate = tiny.processingSystem(class {})

PositionOrbitUpdate.filter = tiny.requireAll('position', 'orbit')

PositionOrbitUpdate.isUpdateSystem = true

function PositionOrbitUpdate:process(e, dt)
    local p = e.position
    local o = e.orbit

    o.t = o.t + o.speed * dt

    p.x, p.y = o:getPoint(o.t)
    p.x = p.x + o.center.x
    p.y = p.y + o.center.y
end

return PositionOrbitUpdate