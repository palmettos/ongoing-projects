local Attributes = class {}

function Attributes:init()
    self.movement_speed = 800
    self.collide_width  = 24
    self.collide_height = 24

    self.base_values = {
        movement_speed = 50,
        collide_width = 32,
        collide_height = 32,

    }
    
    -- self.modded_values = {}

    -- for k, v in pairs(self.base_values) do
    --     self.modded_values[k] = v
    -- end

    self.active_effects = {}
end

function Attributes:set(attribute, value)
    if self[attribute] then
        self[attribute] = value
    end
    return
end

function Attributes:mod(attribute, value)
    if self[attribute] then
        self[attribute] = self[attribute] + value
    end
    return
end

--[[
active effect format:
{
    {
        attribute = attribute (string),
        modValue  = modValue (int),
        duration  = duration (int),
        name      = name (string),
        desc      = description (string)
    }
}
]]--
function Attributes:applyActiveEffect(activeEffect)
    for i, effect in ipairs(activeEffect) do
        local attribute = effect.attribute
        local modValue  = effect.modValue
        local duration  = effect.duration
        self:mod(attribute, modValue)
        timer.after (
            duration,
            function()
                self:mod(attribute, -modValue)
            end
        )
    end
end

return Attributes