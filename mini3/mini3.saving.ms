hook locals
prelude locals

savePath = "/usr/world_save.json"

save = function(world, path = null)
    if path == null then path = savePath
    print "Saving the world"
    start = time

    savedWorld = World.serialize(world)

    text = json.toJSON(savedWorld)
    file.writeLines savePath, [text]
    print "World saved in " + (time - start) + " seconds"
end function

load = function(world, path = null)
    if path == null then path = savePath
    print "Loading the world"
    start = time
    f = file.open(savePath, "r")
    text = f.read
    oldWorld = World.deserialize(json.parse(text))

    for k in oldWorld.indexes
        world[k] = oldWorld[k]
    end for
    print "World loaded in " + (time - start) + " seconds"
end function

export "save"
export "load"