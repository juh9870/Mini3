// @namespace ScrapCore.OOP
ProblemModule = {}

module.import("scrapcore.oop").into locals

ProblemModule.Problem = extends(ClassHolder, "Problem")

ProblemModule.Problem.make = function(self, isError)
    problem = super.make
    problem.isError = isError
    return problem
end function

ProblemModule.Problem.class.toString = function(self)
    self.notImplemented "toString"
end function

return ProblemModule