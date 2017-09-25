local DrawPositionView = tiny.sortedProcessingSystem(class {})

DrawPositionView.filter = tiny.requireAll('position', 'view')

DrawPositionView.isDrawSystem = true

function DrawPositionView:compare(e1, e2)
    local v1, v2 = e1.view, e2.view
    return (v1.strata > v2.strata) --and (v1.time < v2.time)
end

function DrawPositionView:process(e, dt)
    e.view:draw(e.position.x, e.position.y)
end

return DrawPositionView