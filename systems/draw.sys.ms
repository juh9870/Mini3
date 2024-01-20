hook locals
prelude locals
Pool = module("mini3.caching").Pool

cache = {}
globals.drawSysCache = cache


setup = function(_)
    World.addSerde "displayIndex", Serde.Number
    World.addSerde "sprites", Serde.Plain
end function

worldInit = function(world)
    // print "initializing world for sprites"
    world.displayIndex = 4
    // @type {Map<string, SpriteMarker>} Persistant sprites, never released automagically
    world.sprites = {}
    defaultMarker = function
        return {} // assigned at `get` location
    end function
    world._spritesMarkerPool = Pool.make(@defaultMarker)
end function

step = function(world)
    handles = []
    frameSprites = world.sprites.values
    frameSprites.sort "z"
    for sprite in frameSprites
        if not cache.hasIndex(sprite.image) then
            cache[sprite.image] = []
        end if

        cached = cache[sprite.image]
        handle = cached.pop
        if handle == null then
            handle = new Sprite
            handle.image = file.loadImage(sprite.image)
            handle.cacheKey = sprite.image
        end if

        handle.x = sprite.x
        handle.y = sprite.y
        handle.scale = sprite.scale
        handle.rotation = sprite.rotation
        handle.tint = sprite.tint
        handles.push handle
    end for

    display(world.displayIndex).sprites = handles

    for handle in handles
        cache[handle.cacheKey].push handle
    end for
    // exit
end function