// @namespace ScrapCore.OOP
OOP = {}

implementationToken = function(type)
    return "_implements@" + type.class.name + ";" + type._classId
end function

implements = function(class, type)
    typeClass = type.class
    token = implementationToken(type)
    while true
        if (@class).hasIndex(@token) or refEquals(@class, @typeClass) then return true
        if not (@class).hasIndex("__isa") then return false
        class = @(@class).__isa
    end while
end function

// @class
// Base class for the whole ScrapCore OOP system
ClassHolder = {"_classId": 0}
ClassHolder.class = {"_classId": 0}
ClassHolder.nextId = 1

// @constructor
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

AutoMixin.apply = function(self, class)
    if implements(class, self) then
        system.reportError "Class " + class.class._name + " or one of its parents already implements AutoMixin " + self.class.name
    end if
    self.applyOverrides target.class
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

OOP.ClassHolder = @ClassHolder
OOP.Mixin = @Mixin
OOP.AutoMixin = @AutoMixin
OOP.extends = @extends
OOP.implementationToken = @implementationToken
OOP.implements = @implements

// @public
OOP.into = function(scope)
    scope.ClassHolder = @OOP.ClassHolder
    scope.Mixin = @OOP.Mixin
    scope.AutoMixin = @OOP.AutoMixin
    scope.extends = @OOP.extends
    scope.implements = @OOP.implements
    return OOP
end function

return OOP