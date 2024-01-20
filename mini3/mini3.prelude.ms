hook locals

require "SpriteMarker", from("mini3.sprite")
Rect = module("mini3.rectcut").Rect
tween = module("mini3.tweener")
ease = module("mini3.easing")
Gem = module("mini3.gem").Gem
gridBoard = module("mini3.gridBoard")
World = module("mini3.world").World
Serde = module("scrapcore.serde")

export "SpriteMarker"
export "Rect"
export "tween"
export "ease"
export "Gem"
export "World"
export "Serde"

into = function(scope)
    scope.Rect = @Rect
    scope.SpriteMarker = @SpriteMarker
    scope.tween = @tween
    scope.ease = @ease
    scope.Gem = @Gem
    scope.World = @World
    scope.Serde = @Serde

    require "min", "max", from("mathUtil").into(scope)
end function

export "into"