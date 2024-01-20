hook locals

module("scrapcore.oop").into locals
Serde = module("scrapcore.serde")

// @typedef {Map} SpriteMarker
SpriteMarker = extends(ClassHolder, "Mini3.SpriteMarker")
SpriteMarker._ctor = function
    self.id = null
    self.image = null
    self.x = 0
    self.y = 0
    self.z = 0
    self.scale = 1
    self.rotation = 0
end function

Serde.register SpriteMarker, "Mini3.SpriteMarker", {
  "id": Serde.String,
  "image": Serde.String,
  "x": Serde.Number,
  "y": Serde.Number,
  "z": Serde.Number,
  "scale": Serde.Number,
  "rotation": Serde.Number,
}

SpriteMarker.makeSerde = function
    return super.make
end function
// Makes a new sprite handle
// @param {string} id - id of the sprite marker
// @param {string} image - path to the image to draw
// @param {number} [imageW] - Image width. Used for fitting sprite inside the provided rect
// @param {number} [imageH] - Image height. Used for fitting sprite inside the provided rect
// @param {number} [rect] - Rect to fit the sprite into
SpriteMarker.make = function(world, id, image, imageW = null, imageH = null, rect = null)
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
    if imageW != null then
        sprite.fit imageW, imageH, rect
    end if
    return sprite
end function

SpriteMarker.get = function(world, id)
    return world.sprites[id]
end function

// Scales and moves the sprite to fit inside a given rect, filling it
// @param {number} [imageW] - Image width
// @param {number} [imageH] - Image height
// @param {number} [rect] - Rect to fit the sprite into
SpriteMarker.class.fit = function(self, imageW, imageH, rect)
    self.x = (@rect.right + @rect.left) / 2
    self.y = (@rect.top + @rect.bottom) / 2
    width = @rect.right - @rect.left
    height = @rect.top - @rect.bottom
    scaleX = @width / @imageW
    scaleY = @height / @imageH
    if @scaleX == @scaleY then
        self.scale = @scaleX
    else
        self.scale = [@scaleX, @scaleY]
    end if
end function

export "SpriteMarker"