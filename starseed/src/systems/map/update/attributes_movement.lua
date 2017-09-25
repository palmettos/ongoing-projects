local UpdateAttributesMovement = tiny.processingSystem(class {})

UpdateAttributesMovement.filter = tiny.requireAll('attributes', 'movement')

UpdateAttributesMovement.isUpdateSystem = true

function UpdateAttributesMovement:process(e, dt)
    e.movement.movement_speed = e.attributes.movement_speed
end

return UpdateAttributesMovement