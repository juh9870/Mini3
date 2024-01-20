hook locals
prelude locals
require "allTweeners", from("mini3.tweener")

setup = function(_)
    World.addSerde "tweens", Serde.Plain
end function

worldInit = function(world)
    world.tweens = []
end function

step = function(world)
    keep = []
    for tween in world.tweens
        tweener = allTweeners[tween.tweenerId]
        tweener.update world, tween
        if not tween.done then
            keep.push tween
        end if
    end for
    world.tweens = keep
end function