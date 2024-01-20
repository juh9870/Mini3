run = function
    env.importPaths.push "./systems"
    env.importPaths.push "./scrapcore"
    env.importPaths.push "./mini3"
    import "scrapcore"

    scrapcore.banImport
    hook locals

    module("scrapcore.system").into globals
    module "stringUtil" // side-effects

    globals.prelude = function(scope)
        prelude = module("mini3.prelude")
        prelude.into scope
    end function

    globals.oop = module("scrapcore.oop")
    Serde = module("scrapcore.serde")

    require "Loop", from("mini3.loop")
    require "World", from("mini3.world")

    globals.loop = Loop.make

    // Saving as the very first system, then time system
    loop.add "saving.sys", "debug.sys", "time.sys"

    loop.add "match3_screen.sys"

    // Technical systems
    loop.add "tween.sys", "draw.sys", "hot.sys", "key.sys"

    // #region Loop hooks

    globals.beforeReload = function
        loop.beforeReload
    end function

    globals.afterReload = function
        import "entrypoint"
    end function

    loop.setup
    if not globals.hasIndex("_world") then
        globals._world = World.make
        loop.worldInit globals._world
        print "world initialized!"
        loop.stateEnter globals._world
    else
        globals._world = World.deserialize(globals._world)
        print "Hot reload detected, running after-reload hooks!"
        loop.afterReload globals._world
        print "Hot reload complete!"
    end if

    while true
        loop.step globals._world
        yield
        if globals._world._wantHotReload then break
    end while

    if globals._world._wipeWorld then
        globals.remove "_world"
    else
        globals._world = World.serialize(globals._world)
    end if

    // #end region
end function
return run