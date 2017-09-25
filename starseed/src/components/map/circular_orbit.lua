local CircularOrbit = class {}

function CircularOrbit:init(center, radius, sway, swayDist)
    self.radius = radius
    self.center = center

    self.speed = (rand(-1, 1)+rand())*0.01
    while self.speed == 0 do
        self.speed = rand(-1, 1)
    end
        
    self.t = rand(1, 360)

    if sway and swayDist then
        self.center.x = self.center.x + rand(-swayDist, swayDist)
        self.center.y = self.center.y + rand(-swayDist, swayDist)
    end
end

function CircularOrbit:getPoint(r)
    local x = self.radius * cos(r)
    local y = self.radius * sin(r)
    return x, y
end

return CircularOrbit