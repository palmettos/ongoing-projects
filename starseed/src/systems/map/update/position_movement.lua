local PositionMovementUpdate = tiny.processingSystem(class {})

PositionMovementUpdate.filter = tiny.requireAll('position', 'movement')

PositionMovementUpdate.isUpdateSystem = true

function PositionMovementUpdate:process(e, dt)
    local p = e.position
    local m = e.movement

    if m:getCurrentGoal() then  
        local vec_x = m:getCurrentGoal().position.x - p.x
        local vec_y = m:getCurrentGoal().position.y - p.y
        m.movement_vector = vec(vec_x, vec_y):normalizeInplace()
    end

    -- m.direction_vector = m.movement_vector:clone()
    p.x = p.x + m.movement_vector.x * m.movement_speed * dt
    p.y = p.y + m.movement_vector.y * m.movement_speed * dt

    if p.x > e.bump.maxDist then
        p.x = e.bump.maxDist
    end

    if p.y > e.bump.maxDist then
        p.y = e.bump.maxDist
    end

    if p.x < -e.bump.maxDist then
        p.x = -e.bump.maxDist
    end

    if p.y < -e.bump.maxDist then
        p.y = -e.bump.maxDist
    end
end

return PositionMovementUpdate