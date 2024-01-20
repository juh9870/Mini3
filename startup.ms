globals.rerun = function
    if not _sourceFile then
        _printMark "No source file loaded; `load` or `save` something first."
        return
    end if
    sourceFile = _sourceFile
    globals.reset
    if sourceFile != null then
        load sourceFile
        run
    end if
end function

globals.hot = function(entrypoint = "entrypoint")
    while true
        hotr entrypoint
    end while
end function

globals.hotr = function(entrypoint = "entrypoint")
    if globals.hasIndex("beforeReload") then
        globals.beforeReload
    end if
    globals.reset
    run = import(entrypoint)
    run
end function

globals.resetw = function
    globals.reset
    globals.remove "_world"
end function

globals._savedGlobals.rerun = @rerun
globals._savedGlobals.hot = @hot
globals._savedGlobals.hotr = @hotr
globals._savedGlobals.resetw = @resetw