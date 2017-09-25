local Position = class {}

function Position:init(x, y, w, h)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
end

function Position:getBoundingRect(w, h)
    local w = w or self.w
    local h = h or self.h
    return self.x-w/2, self.y-h/2, w, h
end

return Position