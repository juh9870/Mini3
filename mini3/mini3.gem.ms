hook locals

require "makeSprite", from("mini3.sprite")
module("scrapcore.oop").into locals
Serde = module("scrapcore.serde")

Gem = extends(ClassHolder, "Mini3.Gem")
Gem._ctor = function(self)
    self.type = null
    self.id = null
    self.pos = null
end function

Serde.register Gem, "Mini3.Gem", {
  "type": Serde.Plain,
  "id": Serde.String,
  "pos": Serde.Number,
}

// Creates a new gem
// @param {any} type - Gem type. Depends on a solver
// @param {number} pos - Gem position on a board
Gem.make = function(self, board, type, pos)
    gem = super.make
    id = board.id + ".gems.gem_" + board.gemIdCounter
    board.gemIdCounter += 1
    gem.type = @type
    gem.id = @id
    gem.pos = @pos
    return gem
end function

Gem.class.sprite = function(self, world, board)
    sprite = makeSprite(world, self.id, "/sys/pics/Block.png")
    sprite.tint = @self.type
    sprite.scale = @board.tileSize / 64
    return sprite
end function

colors = [color.red, color.green, color.blue, color.yellow, color.orange]
Gem.randomType = function
    return colors[floor(rnd * colors.len)]
end function

export "Gem"