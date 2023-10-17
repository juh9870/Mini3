hook locals

require "ClassHolder", "extends", from("scrapcore.oop")
require "throw", from("scrapcore.system")
ease = module("mini3.easing")

defaultTweeners = function
    return {}
end function

// #region Tweener

Tweener = extends(ClassHolder, "Tweener")

Tweener.updateValues = function(self, world, tweened, progress)
    self.notImplemented "updateValues"
end function

Tweener.onComplete = function(self, world, tweened)
end function

Tweener.onBegin = function(self, world, tweened)
end function

Tweener.update = function(self, world, tweened)
    elapsed = world.now - tweened.startTime
    if elapsed < 0 then
        if tweened.running then
            throw "Tweener is running with negative elapsed time, did world time gone backwards?"
        end if
        return
    end if
    if tweened.done then
        throw "Tweener is updated after its done"
    end if

    // it's better to skip this frame ahead and finish one frame early
    // if doing one more frame would result in lots of overshoot
    if (tweened.duration - elapsed) < world.frameTime / 2 then
        elapsed = tweened.duration
    end if

    if not tweened.running then
        tweened.running = true
        self.onBegin world, tweened
    end if

    if elapsed >= tweened.duration then
        self.updateValues world, tweened, 1
        self.onComplete world, tweened
        tweened.done = true
    else
        easing = ease[tweened.easing]
        progress = easing(elapsed / tweened.duration)
        self.updateValues world, tweened, progress
    end if
end function

Tweener.makeTweened = function(world, tweenerId, duration, easing = null)
    tweened = {
      "startTime": world.now,
      "tweenerId": tweenerId,
      "duration": duration,
      "running": false,
      "done": false,
    }
    if @easing == null then
        tweened.easing = "linear"
    else
        if not ease.hasIndex(easing) then
            throw "Easing `{0}` is not defined".fill([easing])
        end if
        tweened.easing = easing
    end if
    return tweened
end function

// #end region

// #region MoveTweener

MoveTweener = extends(Tweener, "MoveTweener")

MoveTweener.updateValues = function(self, world, tweened, progress)
    target = world.sprites[tweened.spriteId]
    ox = tweened.originPosition[0]
    oy = tweened.originPosition[1]

    dx = tweened.targetPosition[0] - ox
    dy = tweened.targetPosition[1] - oy

    target.x = ox + dx * progress
    target.y = oy + dy * progress
end function

// #end region

// Creates a tweener that moves sprite from one position on screen to another
// @param {World} world - Game world
// @param {string} spriteId - Id of affected sprite
// @param {number} duration - Duration of the animation
// @param {Vec2} targetPosition - target position
// @param {Vec2} [originPosition] - origin of movement. Defaults to sprite current position
// @param {Easing} [easing] - tween easing, defaults to linear
move = function(world, spriteId, duration, targetPosition, originPosition = null, easing = null)
    if not world.sprites.hasIndex(spriteId) then
        throw "Sprite with id """ + spriteId + """ is not found"
    end if
    tween = Tweener.makeTweened(world, "move", duration, easing)
    tween.spriteId = spriteId
    tween.targetPosition = targetPosition
    if originPosition == null then
        sprite = world.sprites[spriteId]
        tween.originPosition = [sprite.x, sprite.y]
    else
        tween.originPosition = originPosition
    end if
    world.tweens.push tween
    return tween
end function


allTweeners = {
  "move": MoveTweener,
}

export "move"

export "Tweener"
export "allTweeners"