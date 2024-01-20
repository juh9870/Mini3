hook locals

require "makeSprite", "getSprite", "fitSprite", from("mini3.sprite")
Rect = module("mini3.rectcut").Rect
tween = module("mini3.tweener")
ease = module("mini3.easing")
Gem = module("mini3.gem").Gem
gridBoard = module("mini3.gridBoard")
World = module("mini3.world").World
Serde = module("scrapcore.serde")

export "makeSprite"
export "getSprite"
export "Rect"
export "tween"
export "ease"
export "Gem"
export "World"
export "Serde"

into = function(scope)
    scope.Rect = @Rect
    scope.getSprite = @getSprite
    scope.makeSprite = @makeSprite
    scope.fitSprite = @fitSprite
    scope.tween = @tween
    scope.ease = @ease
    scope.Gem = @Gem
    scope.World = @World
    scope.Serde = @Serde

    require "min", "max", from("mathUtil").into(scope)
end function

export "into"