hook locals

savePath = "/usr/world_save.json"

save = function(world, path = null)
    if path == null then path = savePath
    print "Saving the world"
    start = time

    savedWorld = {}
    for k in world.indexes
        if k[0] == "_" then continue
        savedWorld[k] = world[k]
    end for

    text = json.toJSON(savedWorld)
    // f = file.open(savePath, "rw+")
    file.writeLines savePath, [text]
    print "World saved in " + (time - start) + " seconds"
end function

load = function(world, path = null)
    if path == null then path = savePath
    print "Loading the world"
    start = time
    f = file.open(savePath, "r")
    text = f.read
    oldWorld = json.parse(text)
    for k in world.indexes
        if k[0] == "_" then continue
        world.remove k
    end for

    for k in oldWorld.indexes
        world[k] = oldWorld[k]
    end for
    print "World loaded in " + (time - start) + " seconds"
end function

export "save"
export "load"