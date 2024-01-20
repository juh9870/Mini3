hook locals
require "extends", "ClassHolder", from("scrapcore.oop")
require "Pool", from("mini3.caching")
Serde = module("scrapcore.serde")

// Y
// ^
// |
// o - > X
// RectCut for UI needs
Rect = extends(ClassHolder, "Mini3.Rect")
Rect._ctor = function
    self.left = null
    self.top = null
    self.right = null
    self.bottom = null
end function

Serde.register Rect, "Mini3.Rect", {
  "left": Serde.Number,
  "bottom": Serde.Number,
  "right": Serde.Number,
  "top": Serde.Number,
}

// Order is X,Y,X,Y
Rect.make = function(left, bottom, right, top)
    rect = super.make
    rect.left = left
    rect.top = top
    rect.right = right
    rect.bottom = bottom
    return rect
end function

Rect.class.cutTop = function(self, amount)
    top = @self.top
    self.top -= @amount
    return Rect.make(@self.left, @self.top, @self.right, @top)
end function

Rect.class.cutRight = function(self, amount)
    right = @self.right
    @self.right -= amount
    return Rect.make(@self.right, @self.bottom, right, @self.top)
end function

Rect.class.cutBottom = function(self, amount)
    bottom = @self.bottom
    @self.bottom += amount
    return Rect.make(@self.left, bottom, @self.right, @self.bottom)
end function

Rect.class.cutLeft = function(self, amount)
    left = @self.left
    @self.left += amount
    return Rect.make(left, @self.bottom, @self.left, @self.top)
end function

Rect.class.width = function(self)
    return @self.right - @self.left
end function

Rect.class.height = function(self)
    return @self.top - @self.bottom
end function

export "Rect"