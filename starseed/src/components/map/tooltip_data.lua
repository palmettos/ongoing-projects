local TooltipData = class {}

-- this is all a big hack
function TooltipData:init(text)
    self.tooltip = loveframes.Create('tooltip')
    self.tooltip:SetObject(self)
    self.tooltip:SetState('map')
    self.tooltip:SetText(text)
    self.tooltip.delay = 0

    self.hover = false
    self.visible = false
    self.state = 'map'
end

return TooltipData