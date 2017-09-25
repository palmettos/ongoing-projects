local CaptureNode = class {}

function CaptureNode:init(faction)
    self.faction = faction or nil
end

function CaptureNode:setFaction(faction)
    self.faction = faction
end

return CaptureNode