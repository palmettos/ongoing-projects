local Collision = class {}

function Collision:init(l, t, w, h, world, e)
    self.world = world
    self.entity = e
    self.world:add(e, l, t, w, h)
end

-- function Collision:querySurroundings(range)
--     local cx = self.l+self.w/2
--     local cy = self.t+self.h/2
--     local l = cx-range/2
--     local t = cy-range/2
--     local w = l+range
--     local h = t+range
--     local items, len = self.world:queryRect(l, t, w, h)
--     return items
-- end

function Collision:applyDamage()
    -- implement in entity if this should be processed
end

function Collision:applyActiveEffect()
    -- implement in entity if this should be processed
end

function Collision:processCollisions(cols, len)
    if len > 0 then
        for _, col in ipairs(cols) do
            col.other.collision:onCollide(self.entity)
        end
    end
end

function Collision:onCollide(other)
    -- implement in entity
    -- other.collision:applyDamage(x), etc...
end

return Collision