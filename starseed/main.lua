loveframes = require 'libs.loveframes'
inspect    = require 'libs.inspect.inspect'
gs         = require 'libs.hump.gamestate'
tiny       = require 'libs.tiny-ecs.tiny'
vec        = require 'libs.hump.vector'
signal     = require 'libs.hump.signal'
camera     = require 'libs.hump.camera'
timer      = require 'libs.hump.timer'
class      = require 'libs.hump.class'
bump       = require 'libs.bump.bump'
shine      = require 'libs.shine'
sti        = require 'libs.sti'
utils      = require 'src.utils'

math.randomseed(os.time())

-- local fpsLimit = 60

rand = math.random
sin  = math.sin
cos  = math.cos
pi   = math.pi

lx = love.math
lm = love.mouse
la = love.audio
lt = love.timer
lw = love.window
lp = love.physics
lk = love.keyboard
lg = love.graphics
lf = love.filesystem

blur = shine.boxblur()
--crt           = shine.crt()
scan = shine.scanlines()
local vignette  = shine.vignette()

scan.pixel_size = 3
scan.opacity    = 0.3

crt = scan:chain(vignette)--:chain(crt)

local Menu = require 'src.states.menu' (
    -- init arguments here
)
local Map  = require 'src.states.map' (
    -- init arguments here
)

function love.load()
    --set to rough to save the frames
    lg.setLineStyle('smooth')
    gs.registerEvents()
    gs.switch(Menu)
    gs.push(Map)
end

-- function love.run()
 
--     if love.math then
--         love.math.setRandomSeed(os.time())
--     end
 
--     if love.load then love.load(arg) end
 
--     -- We don't want the first frame's dt to include time taken by love.load.
--     if love.timer then love.timer.step() end
 
--     local dt = 0
 
--     -- Main loop time.
--     while true do
--         -- Process events.
--         if love.event then
--             love.event.pump()
--             for name, a,b,c,d,e,f in love.event.poll() do
--                 if name == "quit" then
--                     if not love.quit or not love.quit() then
--                         return a
--                     end
--                 end
--                 love.handlers[name](a,b,c,d,e,f)
--             end
--         end
 
--         -- Update dt, as we'll be passing it to update
--         if love.timer then
--             love.timer.step()
--             dt = love.timer.getDelta()
--         end
 
--         -- Call update and draw
--         if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
 
--         if love.graphics and love.graphics.isActive() then
--             love.graphics.clear(love.graphics.getBackgroundColor())
--             love.graphics.origin()
--             if love.draw then love.draw() end
--             love.graphics.present()
--         end
 
--         if love.timer then love.timer.sleep(1/fpsLimit) end
--     end
 
-- end