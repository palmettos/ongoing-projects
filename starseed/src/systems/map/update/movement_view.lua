local UpdateMovementView = tiny.processingSystem(class {})

UpdateMovementView.filter = tiny.requireAll('movement', 'view')

UpdateMovementView.isUpdateSystem = true

function UpdateMovementView:process(e, dt)
    if e.movement.movement_vector:len() > 0 then
        if e.view.rtween then
            timer.cancel(e.view.rtween)
        end

        local diff = e.view.rVec:normalizedAngle(e.movement.movement_vector)

        e.view.rVec:rotateInplace(diff * dt * 20)

        e.view.r = e.view.rVec:angleTo() + math.pi/2
    end
end

return UpdateMovementView