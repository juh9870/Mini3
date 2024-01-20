hook locals
prelude locals

TIMESTEP = 1 / 60 // Ideal fixed timestep

lastTime = 0

setup = function(_)
    World.addSerde "now", Serde.Number
    World.addSerde "frameTime", Serde.Number
end function

worldInit = function(world)
    world.now = 0
    world.frameTime = 0
end function

_timeReset = function(world)
    outer.lastTime = time
end function

afterReload = @_timeReset
stateEnter = @_timeReset

step = function(world)
    dt = time - lastTime
    outer.lastTime = time
    if dt > 1 / 30 then
        dt = 1 / 30
    end if
    world.now += dt
    world.frameTime = dt
end function