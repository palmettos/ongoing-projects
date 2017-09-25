local EllipticalOrbit = class {}

function EllipticalOrbit:init(center, radius, sway, swayDist)
    self.radius = {
        x = radius,
        y = math.random(radius*0.75, radius*1.25)
    }
    self.center = center

    if sway then
        self.center.x = self.center.x + rand(-swayDist, swayDist)
        self.center.y = self.center.y + rand(-swayDist, swayDist)
    end
end

function EllipticalOrbit:getPoint(r)
    local x = self.radius.x * cos(r)
    local y = self.radius.y * sin(r)
    return x, y
end

return EllipticalOrbit