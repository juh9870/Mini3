step = function(world)
    if world.hasIndex("_debug") then
        k = key.get
        if k == "q" then
            print "Exiting debugger"
            world.remove "_debug"
        else
            print "Debugger step"
        end if
    else if key.released ("f") then
        print "Debugger activated"
        world._debug = "held"
    end if
end function