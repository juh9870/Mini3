hook locals

require "makeSprite", "getSprite", "fitSprite", from("mini3.sprite")
cut = module("mini3.rectcut")
tween = module("mini3.tweener")
ease = module("mini3.easing")
gems = module("mini3.gems")
gridBoard = module("mini3.gridBoard")
World = module("mini3.world").World
Serde = module("scrapcore.serde")

export "makeSprite"
export "getSprite"
export "cut"
export "tween"
export "ease"
export "gems"
export "World"
export "Serde"
exports.grid = gridBoard

into = function(scope)
    scope.cut = @cut
    scope.getSprite = @getSprite
    scope.makeSprite = @makeSprite
    scope.fitSprite = @fitSprite
    scope.tween = @tween
    scope.ease = @ease
    scope.gems = @gems
    scope.grid = @gridBoard
    scope.World = @World
    scope.Serde = @Serde

    require "min", "max", from("mathUtil").into(scope)
end function

export "into"