hook locals

module.import("scrapcore.oop").into locals
Serde = module("scrapcore.serde")

World = extends(ClassHolder, "World")

World.addSerde = function(key, type)
    pprint "Adding world serde key " + key
    oop.assertTypeImplements type, Serde
    World[@Serde.membersIndex][@key] = @type
end function

Serde.register World, "Mini3.World", {}

export "World"