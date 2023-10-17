hook locals

cut = module("mini3.rectcut")
gems = module("mini3.gems")
tween = module("mini3.tweener")
ease = module("mini3.easing")
require "min", from("mathUtil")

pos = function(board, pos)
    x = pos % board.w
    y = floor(pos / board.w)
    return [
      ((x + 0.5) * board.tileSize) + board.rect.left,
      ((y + 0.5) * board.tileSize) + board.rect.bottom,
    ]
end function

init = function(rect, width, height, gemType)
    availableW = cut.width(rect)
    availableH = cut.height(rect)
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

    cut.left rect, ox
    cut.right rect, ox
    cut.top rect, oy
    cut.bottom rect, oy

    board = {
      "w": width,
      "h": height,
      "gems": [],
      "rect": rect,
      "tileSize": tileSize,
    }
    for y in range(0, board.h - 1)
        for x in range(0, board.w - 1)
            gem = gems.make(gemType(board.gems.len), board.gems.len)
            board.gems.push gem
        end for
    end for

    return board
end function

snapSprites = function(world, board)
    for y in range(0, board.h - 1)
        for x in range(0, board.w - 1)
            pos = y * board.w + x
            sprite = gems.sprite(world, board, pos)

            spritePos = outer.pos(board, pos)
            sprite.x = spritePos[0]
            sprite.y = spritePos[1]
        end for
    end for
end function

animateBoardFallIn = function(world, board)
    startY = PixelDisplay.height + board.tileSize
    previousRowEnd = 0
    trueRowEnd = 0
    for y in range(0, board.h - 1)
        rowProgress = ((y + 1) / board.h)
        rowDuration = ((1 - rowProgress / 2) ^ 1.2) / 1.1
        for x in range(0, board.w - 1)
            pos = y * board.w + x
            gem = board.gems[pos]
            sprite = gems.sprite(world, board, pos)
            spritePos = outer.pos(board, pos)
            sprite.x = spritePos[0]
            sprite.y = spritePos[1]
            dy = startY - sprite.y
            tweened = tween.move(world, gem.id, rowDuration, [sprite.x, sprite.y], [sprite.x, startY], "easeOutBounce")
            tweened.startTime += previousRowEnd + (x / board.w) * rowDuration
            sprite.y = startY
        end for
        previousRowEnd += rowDuration * ease.easeOutCubic(rowProgress / 2)
        trueRowEnd = previousRowEnd + rowDuration
    end for
    return trueRowEnd
end function

export "pos"
export "init"
export "snapSprites"
export "animateBoardFallIn"