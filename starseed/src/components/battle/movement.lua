local Movement = class {}

function Movement:init()
    self.movement_speed = 100
    self.movement_vector = vec(0, 0)
    self.direction_vector = vec(0, 0)
end

return Movement