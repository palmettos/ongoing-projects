local Destination = require 'src.entities.map.destination'

local Movement = class {}

function Movement:init(e)
    self.e = e
    self.movement_speed = 0
    self:reset()
end

function Movement:appendGoal(goal)
    self.goals:pushRight(goal)
end

function Movement:prependGoal(goal)
    self.goals:pushLeft(goal)
end

function Movement:setGoal(goal)
    self:clearGoals()
    self.goals:pushRight(goal)
end

function Movement:getCurrentGoal()
    return self.goals:peakRight()
end

function Movement:clearCurrentGoal()
    self.goals:popRight():onGoalRemove()
end

function Movement:clearGoals()
    while self.goals:len() > 0 do
        self:clearCurrentGoal()
    end
end

function Movement:stop()
    self.movement_vector = vec(0, 0)
    self.moving = false
    self.waiting = false
end

function Movement:reset()
    self.movement_vector = vec(0, 0)
    self.moving = false
    self.waiting = false
    self.goals = utils.deque()
end

return Movement