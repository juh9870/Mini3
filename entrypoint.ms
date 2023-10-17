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

require "Loop", from("mini3.loop")

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

if not globals.hasIndex("_world") then
    globals._world = {}
    loop.worldInit globals._world
    print "world initialized!"
    loop.stateEnter globals._world
else
    print "Hot reload detected, running after-reload hooks!"
    loop.afterReload globals._world
    print "Hot reload complete!"
end if

while true
    // if key.released("space") then
    //     print "Space got released"
    // end if

    loop.step globals._world
    yield
    if globals._world._wantHotReload then break
end while

if globals._world._wipeWorld then
    globals.remove "_world"
end if

// #end region