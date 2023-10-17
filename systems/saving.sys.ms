hook locals
require "save", "load", from("mini3.saving")
json = module("json")

step = function(world)
    if key.released("[") then
        save world
    end if
    if key.released("]") then
        load world
    end if
end function