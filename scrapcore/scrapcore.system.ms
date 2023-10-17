qa = module.import("qa")

// Polyfills for ScrapCore.system present in embedded environment

// @namespace ScrapCore.System
System = {}

// @public
// Shortcut for qa.abort
// @param {string} message - error message
System.throw = function(message)
    pprint "An error was thrown! use `pprint stackTrace` to see a stacktrace" + char(10) + message
    exit
end function

// @public
// Throws an error about method not being implemented
// @param {string} methodName - name of the missing method
// @param {any} where - object containing the method
System.notImplemented = function(methodName, where)
    name = globals.mapName(where)
    if name == null then name = globals.mapName(where.__isa)
    if name == null then name = str(where)
    System.throw "Method " + methodName + " is not implemented in " + name
end function

// @public
// Truncates a number, discarding decimal part
// @param {number} num - number to truncate
// @returns {number} truncated number
System.trunc = function(num)
    if @num >= 0 then return floor(@num)
    return ceil(@num)
end function

System.into = function(scope)
    scope.trunc = @System.trunc
    scope.throw = @System.throw
    scope.system = System
end function

return System