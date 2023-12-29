// Module module is essential for the whole system to function
import "scrapcore.module"

system = module.import("scrapcore.system")
oop = module.import("scrapcore.oop").into(locals)

// @namespace ScrapCore
Core = {}
Core._name = "scrapcore"

Core.nativeImport = @import
globals._nativeImport = @Core.nativeImport

// @public
Core.banImport = function
    throw = @system.throw
    globals.import = function(_)
        throw "Usage of import is not allowed"
    end function
end function

display = function(value)
    if @value isa string then return """" + @value + """"
    if value == null then return "null"
    return rawDisplay(@value)
end function

rawObjectDisplay = function(obj, name = "", ignore = null, skipIsa = false)
    if ignore == null then ignore = {}
    s = ""
    for e in @obj
        if ignore.hasIndex(e.key) then continue
        if e.key == "__isa" and skipIsa then continue
        s = @s + printf(@(@e).key) + ": " + printf(@(@e).value) + ", "
    end for
    if s == "" then return "{}"
    return @name + "{" + (@s)[:-2] + "}"
end function

rawDisplay = function(obj)
    if @obj isa map then
        // First we are checking for the top-level `_name`
        if (@obj).hasIndex("_name") then return (@obj)._name
        // Then checks for `toString` in self and a parent
        if (@obj).hasIndex("toString") then return (@obj).toString
        if (@obj).hasIndex("__isa") and (@obj).__isa.hasIndex("toString") then return (@obj).toString
        // `ClassHolder` classes should always have toString implemented
        if @obj isa ClassHolder.class then return (@obj).toString
        // Next, global mapName check
        name = globals.mapName(@obj)
        if @name != null then return @name
        // Finally, just print the object
        return rawObjectDisplay(@obj)
    else if @obj isa list then
        if (@obj).len == 0 then return "[]"
        s = ""
        for e in @obj
            s = @s + display(@e) + ", "
        end for
        return "[" + (@s)[:-2] + "]"
    end if
    return str(@obj)
end function

map.setByLazy = function(self, key, provider)
    self[key] = function
        self[key] = provider
        return self[key]
    end function
end function

// @private
requireLazy = function(key, moduleName)
    Core.setByLazy key, module.importLazy(moduleName)
end function

Core.autoHooks = {}
Core.hookInstallers = []

// @global
// Method for installing hooks
//
// This method should be called on top of each file that wishes to use
// ScrapCore functionality
//
// If `moduleName` parameter is passed, it automatically declares current file
// as a module.
//
// These two code snipsets are identical:
// ```
// hook locals
// declare "name"
// ```
// ```
// hook locals, "name"
// ```
//
// @example
// hook(locals)
// @params {Map} scope - scope to hook into
// @returns null
globals.hook = function(scope)
    for k in Core.autoHooks.indexes
        scope[k] = Core.autoHooks[k]
    end for

    for installer in Core.hookInstallers
        installer scope
    end for
end function

Core.display = @display
Core.rawObjectDisplay = @rawObjectDisplay
Core.rawDisplay = @rawDisplay
requireLazy "oop", "scrapcore.oop"
requireLazy "benchmark", "scrapcore.benchmark"
requireLazy "problem", "scrapcore.problem"
requireLazy "system", "scrapcore.system"
requireLazy "require", "scrapcore.require"

globals.scrapcore = Core;

// Require needs to be imported to get properly hooked
module.import "scrapcore.require"

return Core