hook locals

cut = module("mini3.rectcut")
gems = module("mini3.gems")
tween = module("mini3.tweener")
ease = module("mini3.easing")
module("scrapcore.oop").into locals
Serde = module("scrapcore.serde")
require "min", from("mathUtil")
require "Rect", from("mini3.rectcut")

GridBoard = extends(ClassHolder, "Mini3.GridBoard")
GridBoard.class._ctor = function(self)
    self.w = null
    self.h = null
    self.gems = null
    self.rect = null
    self.tileSize = null
end function

Serde.register GridBoard, "Mini3.GridBoard", {
  "w": Serde.Number,
  "h": Serde.Number,
  "gems": Serde.List.make(Serde.Plain),
  "rect": Rect,
  "tileSize": Serde.Number,
}

GridBoard.makeSerde = function
    return super.make
end function

GridBoard.make = function(self, rect, width, height, gemType)
    board = super.make
    availableW = rect.width()
    availableH = rect.height()
    tileW = availableW / width
    tileH = availableH / height
    tileSize = min(tileW, tileH)

    if gemType == null then
        rand = @gems.randomType
        gemType = function(pos)
            return outer.rand
        end function
    end if

    boardW = tileSize * width
    boardH = tileSize * height

    ox = (availableW - boardW) / 2
    oy = (availableH - boardH) / 2

    rect.cutLeft ox
    rect.cutRight ox
    rect.cutTop oy
    rect.cutBottom oy

    board.w = width
    board.h = height
    board.gems = []
    board.rect = rect
    board.tileSize = tileSize

    for y in range(0, board.h - 1)
        for x in range(0, board.w - 1)
            gem = gems.make(gemType(board.gems.len), board.gems.len)
            board.gems.push gem
        end for
    end for

    return board
end function

GridBoard.class.pos = function(self, pos)
    x = @pos % @self.w
    y = floor(@pos / @self.w)
    return [
      ((@x + 0.5) * @self.tileSize) + @self.rect.left,
      ((@y + 0.5) * @self.tileSize) + @self.rect.bottom,
    ]
end function

GridBoard.class.snapSprites = function(self, world)
    for y in range(0, @self.h - 1)
        for x in range(0, @self.w - 1)
            pos = @y * @self.w + @x
            sprite = gems.sprite(world, self, @pos)

            spritePos = self.pos(@pos)
            sprite.x = (@spritePos)[0]
            sprite.y = (@spritePos)[1]
        end for
    end for
end function

GridBoard.class.animateBoardFallIn = function(self, world)
    startY = PixelDisplay.height + @self.tileSize
    previousRowEnd = 0
    trueRowEnd = 0
    for y in range(0, @self.h - 1)
        rowProgress = ((@y + 1) / @self.h)
        rowDuration = ((1 - @rowProgress / 2) ^ 1.2) / 1.1
        for x in range(0, @self.w - 1)
            pos = @y * @self.w + @x
            gem = @self.gems[@pos]
            sprite = gems.sprite(@world, @self, @pos)
            spritePos = self.pos(@pos)
            sprite.x = (@spritePos)[0]
            sprite.y = (@spritePos)[1]
            dy = @startY - @sprite.y
            tweened = tween.move(@world, @gem.id, @rowDuration, [@sprite.x, @sprite.y], [@sprite.x, @startY], "easeOutBounce")
            tweened.startTime += @previousRowEnd + (@x / @self.w) * @rowDuration
            sprite.y = @startY
        end for
        previousRowEnd += @rowDuration * ease.easeOutCubic(@rowProgress / 2)
        trueRowEnd = @previousRowEnd + @rowDuration
    end for
    return @trueRowEnd
end function

export "GridBoard"