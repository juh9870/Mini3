hook locals
// require "draw", from("mini3.sprite")
// require "moveTowardsXY", from("mathUtil")

worldInit = function(world)
    world._wantHotReload = false
    world._wipeWorld = false
end function

afterReload = function(world)
    world._wantHotReload = false
    world._wipeWorld = false
end function

step = function(world)
    if key.released("r") then
        display(3).clear
        world._wantHotReload = true
        if key.pressed("left shift") then
            world._wipeWorld = true
        end if
    end if
end function