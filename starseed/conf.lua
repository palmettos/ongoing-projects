function love.conf(t)
    t.window.width          = 1440
    t.window.height         = 900
    t.window.borderless     = false
    t.window.fullscreen     = false
    t.window.fullscreentype = 'desktop'
    t.window.vsync          = false
    --t.console               = true
    t.msaa                  = 8
    t.modules.joystick      = false

    io.stdout:setvbuf('no')
end