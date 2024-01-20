hook locals
prelude locals

Board = module("mini3.gridBoard").GridBoard

W = PixelDisplay.width
H = PixelDisplay.height
EDGE = (W - H) / 2

setup = function(_)
    World.addSerde "boardGemIdCounter", Serde.Number
    World.addSerde "boards", Serde.List.make(Board)
end function

worldInit = function(world)
    world.boardGemIdCounter = 0
    world.boards = []
end function

stateEnter = function(world)
    screen = Rect.make(0, 0, W, H)
    leftPanel = screen.cutLeft(EDGE)
    rightPanel = screen.cutRight(EDGE)

    board = Board.make("board_1", screen, 10, 10, color.red)
    board.populate
    world.boards.push board

    duration = board.animateBoardFallIn(world)
    print "Fade in animation took " + duration + " seconds"

    leftBlock = SpriteMarker.make(world, "left_block", "/sys/pics/Block.png", 64, 64, leftPanel)
    rightBlock = SpriteMarker.make(world, "right_block", "/sys/pics/Block.png", 64, 64, rightPanel)
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