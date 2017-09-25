local SolarSystem = require 'src.entities.map.solar_system'
local Faction     = require 'src.entities.map.faction'
local Pie         = require 'libs.piefiller.piefiller'
local contains    = require 'src.utils'.contains
local Battle      = require 'src.states.battle'

local Map = class {}

function Map:init()
    self.camera = camera()

    self.cameras = {}

    self.cameras.fg = camera()
    self.cameras.fg.ratio = 1
    self.cameras.fg.scaleRatio = 1

    self.cameras.bg1 = camera()
    self.cameras.bg1.ratio = 1/500
    self.cameras.bg1.scaleRatio = 1/50

    self.cameras.bg2 = camera()
    self.cameras.bg2.ratio = 1/135
    self.cameras.bg2.scaleRatio = 1/8
    self.bg2rot = 0

    self.cameras.bg3 = camera()
    self.cameras.bg3.ratio = 1/50
    self.cameras.bg3.scaleRatio = 1/4
    self.bg3rot = 1

    self.bg     = lg.newImage('assets/bg/bg1.png')
    self.bg:setFilter('nearest', 'nearest')
    -- self.bg:setMipmapFilter('nearest')
    self.bg1    = lg.newImage('assets/bg/bg2.png')
    self.bg1:setFilter('nearest', 'nearest')
    -- self.bg1:setMipMapFilter('nearest')
    self.bg2    = lg.newImage('assets/bg/neb1.png')
    self.bg2:setFilter('nearest', 'nearest')
    -- self.bg2:setMipMapFilter('nearest')
    self.bg3    = lg.newImage('assets/bg/neb1.png')
    self.bg3:setFilter('nearest', 'nearest')
    -- self.bg3:setMipMapFilter('nearest')
    self.border = lg.newImage('assets/bg/border.png')

    self.totalSystems = 8
    self.timescale    = 1

    self.timeSinceUpdate = 0
    self.fgTimePerFrame  = 1/60
    self.bgTimePerFrame  = 5/1

    self.registry = signal.new()

    self.children = {}

    self.activeSystemId = nil

    self.registry:register (
        'broadcast_player_ref',
        function(ref)
            self.playerRef = ref
        end
    )

    self.registry:register (
        'player_issue_challenge',
        function(player, other)
            self.activeSystem:deactivate()
            --self.map_paused = true

            --push battle scene onto gamestate stack
            Map:pushBattleScene(player, other)

            -- self.interface_locked = true
            -- self:configureChallengeWindow(player, other)
            -- self:displayChallengeWindow()
            -- self:lookAt(other)
        end
    )

    self.player_cache = {}

    self.map_paused = false
    self.interface_locked = false

    self.windows = {}
    self:createWindows()
end

function Map:pushBattleScene(fleet1, fleet2)
    gs.push(Battle, fleet1, fleet2)
end

function Map:resume()
    self.activeSystem:activate()
    self.activeSystem:processEvents()
end

function Map:createWindows()

    local challenge = loveframes.Create('frame')
    challenge:SetName('')
    challenge:SetState('map')
    challenge:SetVisible(false)
    challenge:SetDraggable(false)
    challenge:ShowCloseButton(false)
    challenge:SetWidth(300)
    challenge:SetHeight(300)

    local text = loveframes.Create('text', challenge)
    text:SetMaxWidth(240)
    text:CenterX()
    text:SetY(25)

    local str = '...'
    text:SetText(str)

    local grid = loveframes.Create('grid', challenge)
    grid:SetRows(1)
    grid:SetColumns(2)
    grid:SetCellWidth(100)
    grid:SetCellHeight(50)
    grid:SetVisible(true)
    grid:Center()
    grid:SetItemAutoSize(false)

    local button1 = loveframes.Create('button')
    button1:SetText('Leave')

    button1.OnClick = function(object, x, y)
        challenge:SetVisible(false)
        self:clearInterfaceLock()
        self.activeSystem:activate()
    end
    button1:SetSize(80, 40)

    grid:AddItem(button1, 1, 1)

    self.windows['challenge_dialogue'] = challenge
end

function Map:configureChallengeWindow(player, other)
    local height = self.windows['challenge_dialogue']:GetHeight()
    self.windows['challenge_dialogue']:SetX(lg.getWidth()/2+10)
    self.windows['challenge_dialogue']:SetY(lg.getHeight()/2-height-10)
end

function Map:displayChallengeWindow()
    self.windows['challenge_dialogue']:SetVisible(true)
end

function Map:clearInterfaceLock()
    self.map_paused = false
    self.interface_locked = false
end

function Map:lookAt(object)
    if self.camera.lookTween then
        timer.cancel(self.camera.lookTween)
    end

    self.camera.lookTween = timer.tween (
        0.5,
        self.camera,
        {x=object.position.x, y=object.position.y},
        'out-quad'
    )

    if self.camera.scale < 0.25 then
        if self.camera.zoomTween then
            timer.cancel(self.camera.zoomTween)
        end

        self.camera.zoomTween = timer.tween (
            2,
            self.camera,
            {scale = 0.25},
            'out-cubic'
        )
    end
end

function Map:activateSolarSystem(num)
    self.activeSystem:deactivate()
    self.activeSystemId = num
    self.activeSystem:activate()
end

function Map:emit(signal, ...)
    self.registry:emit(signal, ...)
end

function Map:createSolarSystem()
    self.children[#self.children+1] = SolarSystem(self.registry)
end

function Map:generateSolarSystems()
    for i=1, 32 do
        self:createSolarSystem()
    end
end

function Map:createFaction(factionType)
    return Faction(factionType)
end

function Map:generateFactions()
    local names = {}

    for i=0, 5 do
        self.factions[i*2+1] = self:createFaction('sovereign')
        self.factions[i*2+1]:generateName(names)
        names[i*2+1] = self.factions[i*2+1].name

        self.factions[i*2+2] = self:createFaction('pirate')
        self.factions[i*2+2]:generateName(names)
        names[i*2+2] = self.factions[i*2+2].name
    end

    for i, v in ipairs(self.factions) do
        print(v.name)
    end
end

function Map:enter(previous)
    if previous.newGame then
        self:newGame()
    end

    loveframes.SetState('map')
    --self.pie = Pie:new()
    -- self.drawpie = Pie:new()
end

function Map:newGame()
    self:generateSolarSystems()
    self.registry:emit('generatePlanets')
    self.registry:emit('generateNeutralFleets')
    --old code, need to correct compliance with standardized entity
    --structure
    --self:generateFactions()
    self.activeSystemId = 1
    self.activeSystem = self.children[self.activeSystemId]
    -- self.activeSystem:emit (
    --         'map_update_camera_state', self.camera
    --     )
    --self:emit('update_camera_state', self.camera)

    self.activeSystem:activate()
    self.activeSystem:createPlayer()
end

function Map:update(dt)
    --self.pie:attach()

    self.activeSystem = self.children[self.activeSystemId]

    if self.camera_locked then
        self.camera.grabbed = false


        self:cameraTweenToPosition (
                self.camera_locked_on.position.x,
                self.camera_locked_on.position.y,
                0.5
            )
        -- if self.camera.lookTween then
        --     timer.cancel(self.camera.lookTween)
        --     self.camera.lookTween = nil
        -- end

        -- self.camera.lookTween = timer.tween (
        --     3,
        --     self.camera,
        --     {
        --         x = self.camera_locked_on.position.x,
        --         y = self.camera_locked_on.position.y
        --     },
        --     'out-expo'
        -- )
    end

    if not self.interface_locked then
        if self.cameras.fg.grabbed then
            local xOrigin = self.cameras.fg.grabbedAt.x
            local yOrigin = self.cameras.fg.grabbedAt.y
            local xOffset = lm.getX() - xOrigin
            local yOffset = lm.getY() - yOrigin
            self.cameras.fg:move (
                -xOffset*(1/self.cameras.fg.scale),
                -yOffset*(1/self.cameras.fg.scale)
            )

            if self.cameras.fg.x > self.activeSystem.bump.maxDist then
                self.cameras.fg.x = self.activeSystem.bump.maxDist
            end

            if self.cameras.fg.x < -self.activeSystem.bump.maxDist then
                self.cameras.fg.x = -self.activeSystem.bump.maxDist
            end

            if self.cameras.fg.y > self.activeSystem.bump.maxDist then
                self.cameras.fg.y = self.activeSystem.bump.maxDist
            end

            if self.cameras.fg.y < -self.activeSystem.bump.maxDist then
                self.cameras.fg.y = -self.activeSystem.bump.maxDist
            end

            self.cameras.fg.grabbedAt.x = lm.getX()
            self.cameras.fg.grabbedAt.y = lm.getY()
        end
    end

    self:alignCameras()

    local dt = dt * self.timescale
    self.timeSinceUpdate = self.timeSinceUpdate + dt
    while self.timeSinceUpdate > self.fgTimePerFrame do
        self.timeSinceUpdate = self.timeSinceUpdate - self.fgTimePerFrame
        timer.update(self.fgTimePerFrame)

        self.bg2rot = self.bg2rot + 0.0025 * self.fgTimePerFrame
        self.bg3rot = self.bg3rot + 0.005 * self.fgTimePerFrame
        --self:emit('update_camera_state', self.camera)

        -- if not self.map_paused then
        --     for _, system in ipairs(self.children) do
        --         system:update(self.timePerFrame)
        --     end
        -- end
        self.activeSystem:update(self.fgTimePerFrame)
    end

    while self.timeSinceUpdate > self.bgTimePerFrame do
        for i, system in ipairs(self.children) do
            if i ~= self.activeSystemId then
                system:update(self.bgTimePerFrame)
            end
        end
    end

    self.mouseHoverTarget = nil

    local mx, my = self.cameras.fg:worldCoords(lm.getX(), lm.getY())
    local fgZLevel = self.cameras.fg.scale
    local qw = 32*1/fgZLevel
    local qh = qw

    local function filter(item)
        if item.tooltip_data then
            return true
        else
            return false
        end
    end

    local l, t, w, h = utils.createRectFromPoint(mx, my, qw, qh)
    local items, len = self.activeSystem:getColsByQueryRect (
        l, t, w, h, filter
    )

    if len > 0 then
        local min_dist = nil
        local closest_col = nil

        for _, item in ipairs(items) do
            local p1 = {mx, my}
            local p2 = {item.position.x, item.position.y}

            local dist = utils.dist(p1, p2)

            if min_dist then
                if dist < min_dist then
                    min_dist = dist
                    closest_col = item
                end
            else
                min_dist = dist
                closest_col = item
            end
        end

        closest_col.tooltip_data.hover = true
        closest_col.tooltip_data.visible = true

        self.mouseHoverTarget = closest_col
    end

    loveframes.update(dt)
    --self.pie:detach()
end

function Map:draw()
    --self.drawpie:attach()

    -- crt:draw (
    --     function()
    --         lg.setColor(255, 255, 255, 50)
    --         lg.draw(self.bg)
    --         lg.setColor(255, 255, 255, 5)
    --         lg.draw(self.bg1)
    --         lg.setColor(255, 255, 255, 255)
    --         self.camera:attach()
    --         lg.setColor(100, 255, 255, 255)
    --         lg.circle('fill', 0, 0, 7, 200)
    --         lg.setColor(255, 255, 255, 255)
    --         self.activeSystem:draw()
    --         self.camera.detach()
    --         lg.print(lt.getFPS()..' frames per second', 30, 30)
    --         blur:draw (
    --             function()
    --                 lg.setColor(255, 255, 255, 5)
    --                 lg.draw(self.bg1)
    --                 lg.setColor(255, 255, 255, 255)
    --                 self.camera:attach()
    --                 lg.setColor(100, 255, 255, 255)
    --                 lg.circle('fill', 0, 0, 7, 200)
    --                 lg.setColor(255, 255, 255, 255)
    --                 self.activeSystem:draw()
    --                 self.camera:detach()
    --                 lg.print(lt.getFPS()..' frames per second', 30, 30)
    --             end
    --         )
    --     end
    -- )

    --self.pie:attach()

    -- Attach/detach the background camera(s).
    -- Background layer 1.
    self.cameras.bg1:attach()
	lg.setColor(255, 255, 255, 255)
    lg.draw(self.bg, -self.bg:getWidth()/2, -self.bg:getHeight()/2)
    self.cameras.bg1:detach()
    -- Background layer 2.
    self.cameras.bg2:attach()
    lg.setColor(255, 255, 255, 150)
    lg.draw(self.bg2, 0, 0, self.bg2rot, 1, 1, 2048, 2048)
    lg.setColor(255, 255, 255, 255)
    self.cameras.bg2:detach()
    --Background layer 3.
    self.cameras.bg3:attach()
    lg.setColor(255, 255, 255, 120)
    lg.draw(self.bg3, 0, 0, self.bg3rot, 1, 1, 2048, 2048)
    lg.setColor(255, 255, 255, 255)
    self.cameras.bg3:detach()

    -- Attach/detach the foreground camera.
    self.cameras.fg:attach()
    self.activeSystem:draw()
    self.cameras.fg:detach()


    lg.print(lt.getFPS()..' frames per second', 30, 30)
    -- if self.timescale > 1 then
    --     lg.print('10x timescale', 30, 50)
    -- end
    -- lg.print(self.cameras.fg.scale, 30, 70)
    -- lg.print(self.cameras.bg3.scale, 30, 90)
    -- lg.print(self.cameras.bg2.scale, 30, 110)
    -- lg.print(self.cameras.bg1.scale, 30, 130)
    -- local x, y = self.camera:worldCoords(lm.getX(), lm.getY())
    -- lg.print (
    --     x..', '..y,
    --     30, 150
    -- )

    loveframes.draw()

    --self.pie:detach()
    --self.pie:draw()
    -- self.drawpie:detach()
end

--[[----------------------------------------------------------------------------
-- Tween the foreground camera's position.
--]]----------------------------------------------------------------------------
function Map:cameraTweenToPosition(x, y, duration, method)
    self:cameraCancelMoveTween()

    self.cameras.fg.moveTween = timer.tween (
        duration,
        self.cameras.fg,
        {x=x, y=y},
        method or 'out-quad'
    )
end

--[[----------------------------------------------------------------------------
-- Cancel the foreground camera's movement tween.
--]]----------------------------------------------------------------------------
function Map:cameraCancelMoveTween()
    if self.cameras.fg.moveTween then
        timer.cancel(self.cameras.fg.moveTween)
    end
end

--[[----------------------------------------------------------------------------
-- Tween the foreground camera's scale.
--]]----------------------------------------------------------------------------
function Map:cameraTweenToScale(scale, duration)
    self:cameraCancelScaleTween()

    self.cameras.fg.scaleTween = timer.tween (
        duration, self.cameras.fg, {scale=scale}, 'out-quad', nil, {0.1, 1}
    )
end

--[[----------------------------------------------------------------------------
-- Cancel the foreground camera's scale tween.
--]]----------------------------------------------------------------------------
function Map:cameraCancelScaleTween()
    if self.cameras.fg.scaleTween then
        timer.cancel(self.cameras.fg.scaleTween)
    end
end

--[[----------------------------------------------------------------------------
-- Get the appropriate positions of all cameras in the parallax space according
-- to the foreground camera.
--]]----------------------------------------------------------------------------
function Map:getScaledPositions()
    local ret = {}
    local fgCam = self.cameras.fg
    for key, camera in pairs(self.cameras) do
        local ratio = camera.ratio
        ret[key] = {}
        ret[key].x = fgCam.x*ratio
        ret[key].y = fgCam.y*ratio
    end
end

--[[----------------------------------------------------------------------------
-- Get the appropriate scales of all cameras in the parallax space according to
-- the foreground camera.
--]]----------------------------------------------------------------------------
function Map:getScaledScales()
    local ret = {}
    local fgCam = self.cameras.fg
    local distFrom1 = 1-fgCam.scale
    for key, camera in pairs(self.cameras) do
        local ratio = camera.ratio
        ret[key] = 1-distFrom1*ratio
    end
end

--[[----------------------------------------------------------------------------
-- Apply scaling to all cameras in the parallax space according to the state of
-- the foreground camera.
--]]----------------------------------------------------------------------------
function Map:alignCameras()
    local fgCam = self.cameras.fg
    local scaleDistFrom1 = 1-fgCam.scale
    for key, camera in pairs(self.cameras) do
        local ratio = camera.ratio
        local scaleRatio = camera.scaleRatio
        camera.x = fgCam.x*ratio
        camera.y = fgCam.y*ratio
        camera.scale = 1-scaleDistFrom1*scaleRatio
    end
end

--[[----------------------------------------------------------------------------
-- Love2D callback for keypresses.
--]]----------------------------------------------------------------------------
function Map:keypressed(key, isrepeat)
    --self.pie:keypressed(key, isrepeat)
    -- self.drawpie:keypressed(key, isrepeat)
    loveframes.keypressed(key, isrepeat)

	if key == 'space' then
        self.timescale = 4
	end

    if key == 'lshift' then
        self.modshift = true
    end

    if key == 'escape' then
        love.event.quit()
    end
end

--[[----------------------------------------------------------------------------
-- Love2D callback for key releases.
--]]----------------------------------------------------------------------------
function Map:keyreleased(key)
    loveframes.keyreleased(key)

	if key == 'space' then
		self.timescale = 1
	end

    if key == 'lshift' then
        self.modshift = false
    end

end

--[[----------------------------------------------------------------------------
-- Love2D callback for mouse presses.
--]]----------------------------------------------------------------------------
function Map:mousepressed(x, y, button)
    loveframes.mousepressed(x, y, button)

    if not self.map_paused then
        if button == 2 then
            self.cameras.fg.grabbed = true
            self.cameras.fg.grabbedAt = {
                x = x,
                y = y
            }

            if self.camera_locked then
                self.camera_locked = false
                self.camera_locked_on = nil

                self:cameraCancelMoveTween()
            end
        end

        if button == 1 then
            local mx, my = self.cameras.fg:worldCoords(x, y)
            local mht = self.mouseHoverTarget

            if self.modshift then
                if mht then
                    self.activeSystem:emit('add_player_target', mht)
                else
                    self.activeSystem:emit('add_player_destination', mx, my)
                end
            else
                if mht then
                    self.activeSystem:emit('set_player_target', mht)
                else
                    self.activeSystem:emit('set_player_destination', mx, my)
                end
            end
        end
    end
end

--[[----------------------------------------------------------------------------
-- Love2D callback for text input.
--]]----------------------------------------------------------------------------
function Map:textinput(text)
    loveframes.textinput(text)
end

function Map:mousereleased(x, y, button)
    loveframes.mousereleased(x, y, button)

    if button == 2 then
        self.cameras.fg.grabbed = false
    end
end

--[[----------------------------------------------------------------------------
-- Love2D callback for mousewheel movements.
--]]----------------------------------------------------------------------------
function Map:wheelmoved(x, y)
    loveframes.wheelmoved(x, y)

    if not self.map_paused then
        if y > 0 then
            --self.camera:zoom(0.9)
            -- if self.camera.zoomTween then
            --     timer.cancel(self.camera.zoomTween)
            -- end
            -- self.camera.zoomTween = timer.tween (
            --     0.5,
            --     self.camera,
            --     {scale = self.camera.scale * 0.5},
            --     'out-quart',
            --     function()
            --         self.activeSystem:emit (
            --             'camera_changed_zoom_level', self.camera.scale
            --         )
            --     end,
            --     {0.1, 1}
            -- )

            self:cameraTweenToScale(self.cameras.fg.scale * 0.5, 0.5)

            -- if self.camera.lookTween then
            --     timer.cancel(self.camera.lookTween)
            -- end

            -- local mx, my = self.camera:worldCoords(lm.getX(), lm.getY())
            -- self.camera.lookTween = timer.tween (
            --     5,
            --     self.camera,
            --     {x = mx, y = my},
            --     'out-quad'
            -- )
        end

        if y < 0 then
            -- if self.camera.zoomTween then
            --     timer.cancel(self.camera.zoomTween)
            -- end
            -- self.camera.zoomTween = timer.tween (
            --     0.5,
            --     self.camera,
            --     {scale = self.camera.scale  * 1.5},
            --     'out-quart',
            --     function()
            --         self.activeSystem:emit (
            --             'camera_changed_zoom_level', self.camera.scale
            --         )
            --     end,
            --     {0.1, 1}
            -- )

            self:cameraTweenToScale(self.cameras.fg.scale * 1.5, 0.5)

            -- if self.camera.lookTween then
            --     timer.cancel(self.camera.lookTween)
            -- end

            -- local mx, my = self.camera:worldCoords(lm.getX(), lm.getY())
            -- self.camera.lookTween = timer.tween (
            --     5,
            --     self.camera,
            --     {x = mx, y = my},
            --     'out-quad'
            -- )
        end
    end
end

return Map
