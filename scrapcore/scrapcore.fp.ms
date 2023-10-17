// @namespace ScrapCore.FP
// Utilites for deafling with functions
Fp = {}

// @public
// @template T, R
// Creates a variadic function, which accepts up to 31 arguments, and passes
// them as a list to provided handler, and returns a result
// @param {(List<T>)=>R} handler - actual function that handles arguments
// @returns {(...T)=>R} wrapped function
Fp.variadic = function(handler)
    func = function(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24, arg25, arg26, arg27, arg28, arg29, arg30, arg31)
        return handler([arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24, arg25, arg26, arg27, arg28, arg29, arg30, arg31])
    end function
    return @func
end function

// @public
// @template T, R
// Similar to {variadic}, but also accepts (and passes) a Self argument
// @param {string} handlerName - name of handler in {Self} object
// @returns {(Self, ...T)=>R} wrapped function
Fp.variadicSelf = function(handlerName)
    func = function(self, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24, arg25, arg26, arg27, arg28, arg29, arg30, arg31)
        f = self[handlerName]
        return f(self, [arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24, arg25, arg26, arg27, arg28, arg29, arg30, arg31])
    end function
    return @func
end function

return Fp