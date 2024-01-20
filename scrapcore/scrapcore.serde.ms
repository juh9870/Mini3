hook locals
require "ClassHolder", "extends", "Trait", "assertTypeImplements", "assertImplements", from("scrapcore.oop")

Serde = extends(Trait, "Serde", true)
Serde.methods = {}
Serde.statics = {}

// @typedef {Map<String, PlainData> | List<PlainData> | number | string | null} PlainData - plain data that can be safely serialized
//
// Valid types:
//
// - {Map<string, PlainData>} - maps with {string} keys and {PlainData} values. Other key types are NOT supported.
//
// - {List<PlainData>} - lists of {PlainData} values
//
// - {number} - plain numbers (and booleans)
//
// - {string} - plain strings
//
// Functions are NOT supported

// @public
// Serializes the provided class instance into a {PlainData}
// @param {Self.class} - instance of this class
// @returns {PlainData} - serialized data
Serde.statics.serialize = function(self, instance)
    self.notImplemented "serialize"
end function

// @public
// Deserializes provided {PlainData} into the instance of this class
// @param {PlainData} data - serialized data
// @returns {Self.class} - instance of this class
Serde.statics.deserialize = function(self, data)
    self.notImplemented "deserialize"
end function

// @internal
// Map of serializable class names
// @type {Map<string, Serde>}
Serde.classNames = {}

// @public
// Registers the provided type to the serialization system, optionally
// generating default ser/de implementation
// @param {ClassHolder} ty - type to register
// @param {string} serializedTypeName - unique serialized name of the class
// @param {Map<string, Serde>} [members] - optional map of `member name <->
// corresponding serializer`, for automatic serialization and deserialization.
// Class must have a `make` or `makeSerde` factory that can be called with no
// arguments in order for deserialization to work properly. Providing this
// argument will override existing serialization and deserialization methods
Serde.register = function(ty, serializedTypeName, members = null)
    Serde.classNames[@serializedTypeName] = @ty
    ty[@Serde.typeNameMarker] = serializedTypeName
    if @members != null then
        for memberTy in members.values
            assertTypeImplements memberTy, Serde
        end for
        ty[@Serde.membersIndex] = members
        ty.serialize = Serde.membersSerialize(ty, serializedTypeName)
        ty.deserialize = Serde.membersDeserialize(ty, serializedTypeName)
        if not ty.hasIndex("makeSerde") then
            ty.makeSerde = @ty.make
        end if
    end if
    Serde.impl @ty
end function

Serde.membersSerialize = function(ty, typeName)
    fn = function(self, instance)
        ser = {
          "_serdeTypeName": outer.typeName,
        }
        pprint {"@self._serdeMembers": @self._serdeMembers}
        for idx in self._serdeMembers.indexes
            serTy = (@self._serdeMembers)[@idx]
            ser[@idx] = serTy.serialize(instance[@idx])
        end for
        return ser
    end function
    return @fn
end function

Serde.membersDeserialize = function(ty, typeName)
    fn = function(self, data)
        instance = ty.makeSerde
        for idx in self._serdeMembers.indexes
            serTy = (@self._serdeMembers)[@idx]
            instance[@idx] = serTy.deserialize(data[@idx])
        end for
        return instance
    end function
    return @fn
end function

Serde.typeNameMarker = "_serdeTypeName"
Serde.membersIndex = "_serdeMembers"

// region List

Serde.List = {"cache": {}}
Serde.List.make = function(itemType)
    assertTypeImplements itemType, Serde
    typeName = itemType[@Serde.typeNameMarker]
    if Serde.List.cache.hasIndex(itemType) then
        return Serde.List.cache[itemType]
    end if
    serde = extends(ClassHolder, "Serde.List<" + scrapcore.display(itemType.class) + ">")

    serde.serialize = function(self, instance)
        ser = []
        for value in @instance
            ser.push outer.itemType.serialize(@value)
        end for
        return ser
    end function

    serde.deserialize = function(self, data)
        deser = []
        for value in @data
            deser.push outer.itemType.deserialize(@value)
        end for
        return deser
    end function

    Serde.register serde, serde.class._name

    Serde.List.cache[itemType] = serde
    return serde
end function

// end region

// region Map

Serde.Map = {"cache": {}}
Serde.Map.make = function(itemType)
    assertTypeImplements itemType, Serde
    typeName = itemType[@Serde.typeNameMarker]
    if Serde.Map.cache.hasIndex(typeName) then
        return Serde.Map.cache[typeName]
    end if
    serde = extends(ClassHolder, "Serde.Map<" + scrapcore.display(itemType.class) + ">")

    serde.serialize = function(self, instance)
        ser = {}
        for k in instance.indexes
            ser[@k] = outer.itemType.serialize(instance[@k])
        end for
        return ser
    end function

    serde.deserialize = function(self, data)
        deser = {}
        for value in data.indexes
            deser[@k] outer.itemType.deserialize(data[@k])
        end for
        return deser
    end function

    Serde.register serde, serde.class._name

    Serde.Map.cache[typeName] = serde
    return serde
end function

// end region

// region ImplSerde

Serde.ImplSerde = extends(ClassHolder, "Serde.ImplSerde")
Serde.ImplSerde.serialize = function(self, instance)
    assertImplements instance, Serde
    return instance.getType.serialize(instance)
end function
Serde.ImplSerde.deserialize = function(self, data)
    return Serde.classNames[data._serdeTypeName].deserialize(data)
end function
Serde.register Serde.ImplSerde, "Serde.ImplSerde"

// end region

// region primitives

Serde.Number = extends(ClassHolder, "Serde.Number")
Serde.Number.serialize = function(self, instance)
    return instance
end function
Serde.Number.deserialize = function(self, data)
    return data
end function
Serde.register Serde.Number, "Serde.Number"

Serde.Boolean = Serde.Number

Serde.String = extends(ClassHolder, "Serde.String")
Serde.String.serialize = function(self, instance)
    return instance
end function
Serde.String.deserialize = function(self, data)
    return data
end function
Serde.register Serde.String, "Serde.String"

Serde.Plain = extends(ClassHolder, "Serde.Plain")
Serde.Plain.serialize = function(self, instance)
    return instance
end function
Serde.Plain.deserialize = function(self, data)
    return data
end function
Serde.register Serde.Plain, "Serde.Plain"

// end region

return Serde