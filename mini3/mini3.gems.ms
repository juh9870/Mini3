hook locals

require "makeSprite", from("mini3.sprite")

boardGemIdCounter = 0

// Creates a new gem
// @param {World} world - Game world
// @param {any} type - Gem type. Depends on a solver
// @param {number} pos - Gem position on a board
make = function(type, pos)
    id = "board.gems.gem_" + outer.boardGemIdCounter
    outer.boardGemIdCounter += 1
    gem = {
      "type": type,
      "id": id,
      "pos": pos,
    }
    return gem
end function

sprite = function(world, board, pos)
    gem = board.gems[pos]
    sprite = makeSprite(world, gem.id, "/sys/pics/Block.png")
    sprite.tint = gem.type
    sprite.scale = board.tileSize / 64
    return sprite
end function

colors = [color.red, color.green, color.blue, color.yellow, color.orange]
randomType = function
    return colors[floor(rnd * colors.len)]
end function

export "make"
export "sprite"
export "randomType"