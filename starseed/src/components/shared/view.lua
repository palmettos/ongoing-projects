local View = class {}

function View:init(strata)
    self.x = 0
    self.y = 0
    self.r = 0
    self.rVec = vec(0,1)
    self.sx = 0
    self.sy = 0
    self.ox = 0
    self.oy = 0

    self.strata = strata
    self.time = lt.getTime()
    self.rotationFollowsMovement = true
end

function View:draw()
    --implement per entity
end

return View