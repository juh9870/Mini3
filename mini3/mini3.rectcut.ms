hook locals
require "extends", "ClassHolder", from("scrapcore.oop")
require "Pool", from("mini3.caching")

// Y
// ^
// |
// o - > X
// RectCut for UI needs
//
// Must NOT be stored in a world

rectCache = Pool.make

// Order is X,Y,X,Y
makeRect = function(left, bottom, right, top)
    rect = rectCache.get
    rect.left = left
    rect.top = top
    rect.right = right
    rect.bottom = bottom
    return rect
end function

dropRect = function(rect)
    rectCache.release rect
end function

cutTop = function(rect, amount)
    top = rect.top
    rect.top -= amount
    return makeRect(rect.left, rect.top, rect.right, top)
end function

cutRight = function(rect, amount)
    right = rect.right
    rect.right -= amount
    return makeRect(rect.right, rect.bottom, right, rect.top)
end function

cutBottom = function(rect, amount)
    bottom = rect.bottom
    rect.bottom += amount
    return makeRect(rect.left, bottom, rect.right, rect.bottom)
end function

cutLeft = function(rect, amount)
    left = rect.left
    rect.left += amount
    return makeRect(left, rect.bottom, rect.left, rect.top)
end function

width = function(rect)
    return rect.right - rect.left
end function

height = function(rect)
    return rect.top - rect.bottom
end function

export (@makeRect).as("make")
export (@dropRect).as("drop")
export (@cutTop).as("top")
export (@cutRight).as("right")
export (@cutBottom).as("bottom")
export (@cutLeft).as("left")
export "width"
export "height"