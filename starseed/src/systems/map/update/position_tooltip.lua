local PositionTooltipUpdate = tiny.processingSystem(class {})

PositionTooltipUpdate.filter = tiny.requireAll('position', 'tooltip_data')

PositionTooltipUpdate.isUpdateSystem = true

function PositionTooltipUpdate:process(e, dt)
    local p = e.position
    local t = e.tooltip_data

    t.x = p.x
    t.y = p.y

    t.visible = false
    t.hover = false
end

return PositionTooltipUpdate