hook locals

// @typedef {Map} SpriteMarker
// @property {string} id - id of the sprite marker
// @property {string} image - path to the image to draw
// @property {number} x - x coordinate of a sprite
// @property {number} y - y coordinate of a sprite
// @property {number} z - z order of a sprite
// @property {number} scale - z order of a sprite
// @property {number} rotation - rotation a sprite in degrees

makeSprite = function(world, id, image, spriteW = null, spriteH = null, rect = null)
    sprite = null
    if world.sprites.hasIndex(id) then
        sprite = world.sprites[id]
    else
        sprite = world._spritesMarkerPool.get
    end if
    sprite.id = id
    sprite.image = image
    sprite.rotation = 0
    sprite.scale = 1
    sprite.x = 0
    sprite.y = 0
    sprite.z = 0
    sprite.tint = color.white
    world.sprites[id] = sprite
    if spriteW != null then
        fitSprite sprite, spriteW, spriteH, rect
    end if
    return sprite
end function

getSprite = function(world, id)
    return world.sprites[id]
end function

fitSprite = function(sprite, spriteW, spriteH, rect)
    sprite.x = (rect.right + rect.left) / 2
    sprite.y = (rect.top + rect.bottom) / 2
    width = rect.right - rect.left
    height = rect.top - rect.bottom
    scaleX = width / spriteW
    scaleY = height / spriteH
    if scaleX == scaleY then
        sprite.scale = scaleX
    else
        sprite.scale = [scaleX, scaleY]
    end if
end function

export "makeSprite"
export "getSprite"
export "fitSprite"