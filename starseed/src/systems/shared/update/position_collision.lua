local PositionCollisionUpdate = tiny.processingSystem(class {})

PositionCollisionUpdate.filter = tiny.requireAll('position', 'collision')

PositionCollisionUpdate.isUpdateSystem = true

function PositionCollisionUpdate:process(e, dt)
    local p = e.position
    local c = e.collision

    local l, t, w, h = p:getBoundingRect()

    local _, __, cols, len = e.bump:move (
        e, l, t, function(i, o) return 'cross' end
    )

    c:processCollisions(cols, len)

    -- if len > 0 then
    --     for _, col in ipairs(cols) do
    --         col.other.collision:onCollide(e)
    --     end
    -- end
end

return PositionCollisionUpdate