exports = {}

Core = module.import("scrapcore")
module.import("scrapcore.oop").into locals
module.import("scrapcore.system").into locals

// #region As

As = extends(ClassHolder, "As")
exports.As = As

As.make = function(self, original, alias)
    as = super.make
    as.original = @original
    as.alias = @alias
    return @as
end function

As.class._ctor = function
    super._ctor
    self.original = null
    self.alias = null
end function

As.class.original = null
As.class.alias = null

string.as = function(self, alias)
    return As.make(@self, @alias)
end function

map.as = function(self, alias)
    return As.make(@self, @alias)
end function

number.as = function(self, alias)
    return As.make(@self, @alias)
end function

funcRef.as = function(self, alias)
    return As.make(@self, @alias)
end function

list.as = function(self, alias)
    return As.make(@self, @alias)
end function

// #end region

// #region From

From = extends(ClassHolder, "From")
exports.From = From

From.make = function(self, source)
    from = super.make
    from.source = source
    return from
end function

From.class._ctor = function(self)
    super._ctor
    self.source = null
    self.target = null
end function

From.class.into = function(self, target)
    self.target = target
    return self
end function

From.class.source = null
From.class.target = null

// #end region

// #region Require

// @typedef {(string|As|List<Argument>)} Argument - Import argument

// @internal
// Parses arguments, writing imports and alliases into `selfWrites`
// @param {List<Argument>} arguments - list of arguments to parse
// @param {Map<string,string>} selfWrites - map of aliases
// @returns {(From|null)} - import source
parseArguments = function(arguments, selfWrites)
    for arg in arguments
        // String argument is 1:1 mapping
        if arg isa string then
            selfWrites[arg] = arg
            continue
        end if

        // As argument is aliased mapping
        if arg isa As.class then
            selfWrites[arg.alias] = arg.original
            continue
        end if

        // Argment can be a list of arguments
        if arg isa list then
            source = parseArguments(arg, selfWrites)
            if source != null then return source
            continue
        end if

        // From means we have finished our arguments parsing
        if arg isa From.class then return arg
    end for

    throw "require was called without from() argument"
end function

resolveSource = function(from)
    if from isa string then return module.import(from)
    if from isa map then return from
    throw "Invalid from() target: " + str(from)
end function

throwDuplicateKey = function(key)
    throw "Key """ + key + """ already exists in target map"
end function

copyOver = function(from, to, mapping, fromTarget = null)
    for key in mapping.indexes
        if to.hasIndex(key) then throwDuplicateKey(key)
        originalKey = mapping[key]
        to[key] = @from[originalKey]
    end for
    if fromTarget != null then
        if to.hasIndex(fromTarget) then throwDuplicateKey(fromTarget)
        to[fromTarget] = from
    end if
end function

exports.requireFunc = function(scope, lazy, moduleAccess, args)
    if args[0] == null and @moduleAccess != null then return moduleAccess

    selfWrites = {}
    resultWrite = null
    from = parseArguments(args, selfWrites)
    if from == null then
        throw "Can't determine import target, did you use forget to wrap import target in ""from""?"
    end if
    source = from.source
    target = from.target

    if target == null then target = scope
    if not (target isa map) then
        throw "Invalid require target"
    end if

    if source isa As.class then
        resultWrite = source.alias
        source = source.original
    end if

    // map source can't be lazy
    if source isa map then lazy = false

    if not lazy then
        obj = resolveSource(source)
        copyOver obj, target, selfWrites, resultWrite
        return obj
    end if

    lazyData = null

    lazyFetcher = function
        if lazyData != null then return lazyData
        outer.lazyData = resolveSource(source)
        return lazyData
    end function

    lazyKeyFetcher = function(key)
        reqOuter = outer
        fetcher = function(self)
            obj = reqOuter.lazyFetcher
            originalKey = reqOuter.selfWrites[key]
            self[key] = @obj[originalKey]
        end function
    end function

    lazySource = {}
    for key in selfWrites.indexes
        lazySource[key] = lazyKeyFetcher(key)
    end for

    copyOver lazySource, target, selfWrites, null
    if resultWrite != null then
        if to.hasIndex(resultWrite) then throwDuplicateKey(resultWrite)
        target.setByLazy resultWrite, @lazyFetcher
    end if

    return @lazyFetcher
end function

// #end region

// #region Exports

exports.export = function(scope, target)
    if target isa As.class then
        // Alias
        scope.exports[target.alias] = @target.original
    else if target isa string then
        // Local export
        if not scope.hasIndex(target) then
            throw "Can't export '" + target + "', member with such name is not found in scope"
        end if
        scope.exports[target] = @scope[target]
    else
        throw "Invalid export parameter: expected scope member name, or As alias"
    end if
end function

// #end region

// #region Hooks

installHooks = function(scope)
    req = outer
    hooksRequire = {}
    scope.exports = {}

    // TODO: Require docs
    scope.require = function(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24, arg25, arg26, arg27, arg28, arg29, arg30, arg31)
        return req.exports.requireFunc(scope, false, hooksRequire, [@arg0, @arg1, @arg2, @arg3, @arg4, @arg5, @arg6, @arg7, @arg8, @arg9, @arg10, @arg11, @arg12, @arg13, @arg14, @arg15, @arg16, @arg17, @arg18, @arg19, @arg20, @arg21, @arg22, @arg23, @arg24, @arg25, @arg26, @arg27, @arg28, @arg29, @arg30, @arg31])
    end function

    hooksRequire.lazy = function(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24, arg25, arg26, arg27, arg28, arg29, arg30, arg31)
        return req.exports.requireFunc(scope, true, null, [@arg0, @arg1, @arg2, @arg3, @arg4, @arg5, @arg6, @arg7, @arg8, @arg9, @arg10, @arg11, @arg12, @arg13, @arg14, @arg15, @arg16, @arg17, @arg18, @arg19, @arg20, @arg21, @arg22, @arg23, @arg24, @arg25, @arg26, @arg27, @arg28, @arg29, @arg30, @arg31])
    end function

    scope.from = function(source)
        return req.exports.From.make(source)
    end function

    // @global locals.declare
    // Exports
    scope.export = function(nameOrMap)
        return req.exports.export(scope, nameOrMap)
    end function
end function

Core.hookInstallers.push @installHooks

// #end region

return exports