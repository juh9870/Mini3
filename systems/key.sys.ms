heldKeys = {}
key.released = function(keyName = "space")
    if key.pressed(keyName) then
        heldKeys[keyName] = true
        return false
    end if
    return heldKeys.hasIndex(keyName)
end function

step = function(world)
    for k in heldKeys.indexes
        if not key.pressed(k) then
            heldKeys.remove k
        end if
    end for
end function