local ShapeView = class {}

function ShapeView:init(x, y, r, color, strata, override)
    self.x, self.y = x, y
    self.r = r
    self.color  = color
	self.strata = strata
    self.override = override
end

return ShapeView