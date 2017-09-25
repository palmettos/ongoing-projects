local BaseEntity = require 'src.entities.shared.base_entity'
local Fleet      = require 'src.entities.map.fleet'
local choice     = require 'src.utils'.choice
local contains   = require 'src.utils'.contains

local symbols = {
    '$adjective',
    '$org',
    '$pirateorg',
    '$noun'
}

local subs = {
    ['$adjective'] = {
        'Blackened',
        'Darkened',
        'Rayless',
        'Cimmerian',
        'Brilliant',
        'Golden',
        'Radiant',
        'Argent',
        'Sunlit',
        'Astral',
        'Celestial',
        'Shadeless'
    },
    ['$org'] = {
        'Association',
        'Conglomerate',
        'Union',
        'Ring',
        'Chamber',
        'Council',
        'Combine',
        'Trust',
        'Outfit',
        'Consortium',
        'Corporation',
        'Society',
        'Coalition',
        'Confederacy',
        'Supremacy',
        'Skies',
        'Phantoms'
    },
    ['$pirateorg'] = {
        'Cartel',
        'Legion',
        'Pirates'
    },
    ['$noun'] = {
        'Shadow',
        'Gloam',
        'Shade',
        'Umbra',
        'Dusk',
        'Dawn',
        'Penumbra',
        'Umbrage',
        'Daylight',
        'Daybreak',
        'Brilliance',
        'Twilight',
        'Heaven',
        'Transcendence'
    }
}

local nameFormats = {
    ['sovereign'] = {
        '$adjective $noun $org',
        '$adjective $noun $org',
        '$adjective $org',
        '$adjective $noun',
        '$noun $org',
        '$org of $noun',
        '$adjective $org of $noun'
    },
    ['pirate'] = {
        '$adjective $noun $pirateorg',
        '$adjective $noun $pirateorg',
        '$adjective $pirateorg',
        '$adjective $noun',
        '$noun $pirateorg',
        '$pirateorg of $noun',
        '$adjective $pirateorg of $noun'
    }
}

local Faction = class {} : include (BaseEntity)

-- factionType: 'sovereign' or 'pirate'
function Faction:init(ecs, registry, bump, factionType)
    BaseEntity.init(self, ecs, registry, bump)
    self.name = nil
    self.type = factionType
    self.isFaction = true
end

function Faction:generateName(namesToAvoid)
    local name
    repeat
        name = choice(nameFormats[self.type])
        for _, symbol in ipairs(symbols) do
            name = string.gsub(name, symbol, choice(subs[symbol]))
        end
    until not contains(namesToAvoid, name)
    self.name = name
    return name
end

return Faction