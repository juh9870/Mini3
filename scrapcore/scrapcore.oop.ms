// @namespace ScrapCore.OOP
OOP = {}

implementationToken = function(type)
    return "_implements@" + type.class._name + ";" + type._classId
end function

implements = function(class, type)
    return typeImplements(class.getType, @type)
end function

typeImplements = function(ty, implType)
    token = implementationToken(implType)

    while true
        if (@ty).hasIndex(@token) or refEquals(@ty, @implType) then return true
        if not (@ty).hasIndex("__isa") then return false
        ty = @(@ty).__isa
    end while
end function

assertImplements = function(class, type)
    if not implements(class, type) then
        system.throw "Assertion failed: class " + class._name + " does not implement " + type.class._name
    end if
end function

assertTypeImplements = function(ty, implType)
    if not typeImplements(ty, implType) then
        system.throw "Assertion failed: class " + ty.class._name + " does not implement " + implType.class._name
    end if
end function

// @class
// Base class for the whole ScrapCore OOP system
ClassHolder = {"_classId": 0}
ClassHolder.class = {"_classId": 0}
ClassHolder.nextId = 1

// @constructor
// This should populate class instance with all required fields, but not
// neccesarily with valid values, those should be populated in `make`
ClassHolder.class._ctor = function(self)
end function

// @public
// Converts class to its {string} representation
ClassHolder.class.toString = function(self)
    return self._name
end function

// @public
// Gets the Type from the given class
ClassHolder.class.getType = function(self)
    self.notImplemented "getType"
end function

// @public
// Main builder for the class
ClassHolder.make = function(self)
    result = new (@self.class)
    result._ctor
    return @result
end function

// @protected
// Shortcut for {ScrapCore.Core.System.notImplemented}
// @param {methodName} - name of the problematic method
ClassHolder.class.notImplemented = function(self, methodName)
    system.notImplemented methodName, self
end function

// @public
// Extends the provided class
extends = function(parent, className, preventDefaultMixin = false)
    class = new parent
    class._classId = ClassHolder.nextId
    ClassHolder.nextId = ClassHolder.nextId + 1
    class._name = "Static@" + className
    class.class = new parent.class
    class.class._classId = class._classId
    class.class._name = className
    class.class._ctor = function(self)
        super._ctor
    end function
    class.class.getType = function
        return class
    end function
    if not preventDefaultMixin and parent.hasIndex("_extenderMixin") and parent._extenderMixin isa Mixin then
        parent._extenderMixin.apply class
    end if
    return class
end function

// @class
// Base class for all the mixin stuff
//
// Mixins are classes that modify other classes, directly injecting functionality
Mixin = extends(ClassHolder, "Mixin", true)

// @public
// Applies current mixin to the provided class
// @param {ClassHolder} class - class to modify
Mixin.apply = function(class)
    system.notImplemented apply, self
end function

// @internal
Mixin.identifierCounter = 0

// @public
// Method for generating identifiers for mixin usage
// @param {string} name - name of the identifier
Mixin.identifier = function(name = "unnamed")
    Mixin.identifierCounter = Mixin.identifierCounter + 1
    return "_trait@" + name + ":" + self.class._name + ";" + Mixin.identifierCounter
end function

// @class
// Mixin class that automatically injects all of its class methods and fields
// into objects
//
// This is a shallow copy
AutoMixin = extends(Mixin, "AutoMixin", true)

// @internal
// Map of keys that are banned from automatic copying
AutoMixin.bannedKeys = {"__isa": true}

// @internal
// Map of overrides names
AutoMixin.overrides = null

// @internal
AutoMixin.generateKeys = function(self)
    if self.hasIndex("overrides") then return
    self.overrides = {}
    for key in self.class
        identifier = self.identifier(key)
        self.overrides[key] = identifier
    end for
end function

AutoMixin.apply = function(self, ty)
    if implements(ty, self) then
        system.throw "Class " + ty.class._name + " or one of its parents already implements AutoMixin " + self.class._name
    end if
    self.applyOverrides ty.class
    ty[implementationToken(self)] = true
end function

// @internal
// Applies overrides to the target
// @param {ClassHolder.class} target - target to apply mixin to
AutoMixin.applyOverrides = function(self, target)
    self.generateKeys
    for key in self.class
        if AutoMixin.bannedKeys.hasIndex(key) then continue
        overrideKey = self.overrides[key]
        target[overrideKey] = @target[key]
        target[key] = @self.class[key]
    end for
end function

// @class
// Basis of the Trait system
Trait = extends(ClassHolder, "Trait", true)

Trait.badImpl = function(self, ty, msg)
    system.throw "Incorrect implementation of trait " + self.class._name + " for type " + ty._name + " - " + msg
end function

// @public
// Copies over all methods from the provided map into the provided class
// @param {ClassHolder.class} class - class to insert methods into
// @param {Map<string, funcRef>} - methods to insert into class
Trait.applyDefaultMethods = function(class, methods)
    for k in methods.indexes
        if class.hasIndex(@k) then
            continue
        end if
        class[@k] = methods[@k]
    end for
end function

// @protected
// Applies default methods to the target type and its class
// @type {(ClassHolder) => void}
Trait.applyDefaults = null

// @protected
// Methods that are required to be implemented by the class instances
// @type {Map<string, funcRef> | null}
Trait.members = null

// @protected
// Static methods that are required to be implemented by the class type
// @type {Map<string, funcRef> | null}
Trait.statics = null

// @public
// Marks target type as implementing this trait
//
// Target type must already implement all trait methods with the EXACT
// signature, including parameter names and default values
//
// @param {ClassHolder} ty - type to implement trait for
Trait.impl = function(self, ty)
    typeClass = ty.class

    if implements(ty.class, self) then
        system.throw "Class " + ty.class._name + " or one of its parents already implements Trait " + self.class._name
    end if

    if @self.applyDefaults != null then
        self.applyDefaults @ty
    end if

    members = self.members
    if @members != null then
        for idx in members.indexes
            traitFunc = members[@idx]

            if not @traitFunc isa funcRef then
                system.throw "Trait " + self.class._name + " contains non-function member at index `" + @idx + "`"
            end if

            if not typeClass.hasIndex(@ids) then
                self.badImpl typeClass, "member `" + @idx + "` is missing"
            end if

            classFunc = typeClass[@idx]

            if not @classFunc isa funcRef then
                self.badImpl typeClass, "member `" + @idx + "` is not a function"
            end if

            traitFuncSignature = str(@traitFunc)
            classFuncSignature = str(@classFunc)

            if @traitFuncSignature != @classFuncSignature then
                self.badImpl typeClass, "incompatible method signatures for `" + @idx + "`, required " + @traitFuncSignature + " but found " + classFuncSignature
            end if
        end for
    end if

    statics = self.statics
    if @statics != null then
        for idx in statics.indexes
            traitFunc = statics[@idx]

            if not @traitFunc isa funcRef then
                system.throw "Trait " + self._name + " contains non-function member at index `" + @idx + "`"
            end if

            if not ty.hasIndex(@idx) then
                self.badImpl ty, "member `" + @idx + "` is missing"
            end if

            staticFunc = ty[@idx]

            if not @staticFunc isa funcRef then
                self.badImpl ty, "member `" + @idx + "` is not a function"
            end if

            traitFuncSignature = str(@traitFunc)
            staticFuncSignature = str(@staticFunc)

            if @traitFuncSignature != @staticFuncSignature then
                self.badImpl ty, "incompatible method signatures for `" + @idx + "`, required " + @traitFuncSignature + " but found " + staticFuncSignature
            end if
        end for
    end if

    token = implementationToken(self)

    ty[token] = true
end function


OOP.ClassHolder = @ClassHolder
OOP.Trait = @Trait
OOP.Mixin = @Mixin
OOP.AutoMixin = @AutoMixin
OOP.extends = @extends
OOP.implementationToken = @implementationToken
OOP.implements = @implements
OOP.typeImplements = @typeImplements
OOP.assertImplements = @assertImplements
OOP.assertTypeImplements = @assertTypeImplements

// @public
OOP.into = function(scope)
    scope.ClassHolder = @OOP.ClassHolder
    scope.Mixin = @OOP.Mixin
    scope.extends = @OOP.extends
    scope.implements = @OOP.implements
    scope.assertImplements = @OOP.assertImplements
    scope.assertTypeImplements = @OOP.assertTypeImplements
    return OOP
end function

return OOP