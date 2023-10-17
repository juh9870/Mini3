hook locals
prelude locals

W = PixelDisplay.width
H = PixelDisplay.height
EDGE = (W - H) / 2

worldInit = function(world)
    world.boardGemIdCounter = 0
end function

stateEnter = function(world)
    screen = cut.make(0, 0, W, H)
    leftPanel = cut.left(screen, EDGE)
    rightPanel = cut.right(screen, EDGE)

    world.board = grid.init(screen, 10, 10)
    board = world.board

    duration = grid.animateBoardFallIn(world, board)
    print "Fade in animation took " + duration + " seconds"

    leftBlock = makeSprite(world, "left_block", "/sys/pics/Block.png", 64, 64, leftPanel)
    rightBlock = makeSprite(world, "right_block", "/sys/pics/Block.png", 64, 64, rightPanel)
end function

step = function(world)
    // if world.hasIndex("boardReady") then return
    // world.boardReady = true
    // pprint leftPanel
    // pprint rightPanel
    // pprint screen
    // board = makeSprite(world, "board", "/sys/pics/blockTiles.png", 128, 128, screen)
    // board world, screen, 8, 8
end function