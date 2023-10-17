hook locals
require "allTweeners", from("mini3.tweener")

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