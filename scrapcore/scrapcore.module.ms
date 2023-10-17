import "qa"

if globals.hasIndex("scrapcore.module") then
    qa.abort "Module module got imported directly, which should never happen after startup"
end if

nativeImport = @import

// @namespace ScrapCore.Module
// Module for manipulating modules
Module = {}
Module.moduleName = "_scrapcore.module.module_name"

Module.importStack = []
importStack = Module.importStack

Module.initializationMarker = {}
Module.initializationMarker._moduleInitMarker = function
end function

Module.begin = function
    mod = {}
    mod._name = Module.topName
    return mod
end function

// @public
// Returns a name of the top item from the import stack, which is likely to be
// a current module if invoked at top level of a file
Module.topName = function
    if Module.importStack.len == 0 then
        return "<root>"
    end if
    return Module.importStack[-1]
end function

// @public
// Checks if provided module is defined
// @param {moduleName} - module to checks
// @returns {boolean}
Module.isDefined = function(moduleName)
    return globals.hasIndex(@moduleName)
end function

// @public
// Checks if provided module is defined
// @param {moduleName} - module to checks
// @returns {boolean}
Module.resolve = function(moduleName)
    return globals[moduleName]
end function

// @public
// Main function to import modules
//
// Will abort execution if resolved module file does not define the module
// @param {string} moduleName - name of the module to import
// @returns Map
Module.import = function(moduleName)
    if not Module.isDefined(@moduleName) then
        Module.initializeModule @moduleName
    end if
    mod = Module.resolve(@moduleName)

    if refEquals(mod, @Module.initializationMarker) then
        qa.abort "Module " + moduleName + " is in process of initializing" +
          char(10) +
          "This issue might be caused by circular references in module imports. Run `module.importStack` to check import stack."
    end if
    return mod
end function

// @public
// Accessor to the native MiniMicro import function
Module.nativeImport = @nativeImport

// @public
// Function to lazily import modules
//
// Returns a function that imports a module when called
//
// Will abort execution if resolved module file does not define the module
// @param {string} moduleName - name of the module to import
// @returns ()=>Map
Module.importLazy = function(moduleName)
    cache = null
    func = function
        if cache == null then
            outer.cache = Module.import(moduleName)
        end if
        return cache
    end function
    return @func
end function

Module.assertFresh = function(moduleName)
    if not Module.isDefined(moduleName) then return
    qa.abort "Module " + moduleName + " is already initialized"
end function

// // @public
// // List of module resolvers
// //
// // When looking for a new module, system will go trough all resolvers in this
// // list, passing module name as an argument, and consider module as initialized
// // once one of the resolvers returns true
// // @type List<(string)=>boolean>
// Module.resolvers = []

// @internal
Module.initializeModule = function(moduleName)
    globals[moduleName] = @Module.initializationMarker
    Module.importStack.push moduleName

    nativeImport moduleName

    mod = locals[moduleName]

    if mod isa map and mod.hasIndex("exports") and not mod.hasIndex("_noExports") and mod.exports isa map and mod.exports.len > 0 then
        mod = mod.exports
    end if

    if mod isa map and not mod.hasIndex("_name") then
        mod._name = moduleName
    end if

    globals[moduleName] = mod

    Module.importStack.pop
end function


builtInLibraries = {}
sysLibFiles = file.children("/sys/lib")
for lib in sysLibFiles
    builtInLibraries[lib[:-3]] = true
end for

// @global
globals.module = function(moduleName = null)
    if moduleName == null then return Module
    return Module.import(moduleName)
end function

Module._name = "scrapcore.module"
globals["scrapcore.module"] = Module

return Module