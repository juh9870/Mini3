// @namespace ScrapCore.OOP
Benchmark = {}

module.import("scrapcore.oop").into locals
module.import("scrapcore.system").into locals
module.import "stringUtil"

Benchmark.bench = function(timeLimit, func)
    sw = Benchmark.Stopwatch.make
    while sw.elapsed < timeLimit
        sw.tic
        func
        sw.toc
    end while
    return sw
end function

// @class
// Benchmark runner
Benchmark.Stopwatch = extends(ClassHolder, "Benchmark.Stopwatch")
Benchmark.Stopwatch.class._ctor = function
    self.elapsed = 0
    self.lastTic = null
    self.runs = []
    self.runsCount = 0
    self.min = 1e308
    self.max = -1e308
    self.average = 0
end function

Benchmark.Stopwatch.class.tic = function(self)
    self.lastTic = time
end function

Benchmark.Stopwatch.class.toc = function(self)
    now = time
    tic = self.lastTic
    if tic == null then
        throw "Runner.toc was called before callind Runner.tic"
    end if
    timeSpent = now - tic
    if timeSpent < self.min then self.min = timeSpent
    if timeSpent > self.max then self.max = timeSpent
    self.runs.push timeSpent
    self.elapsed = self.elapsed + timeSpent
    self.runsCount = self.runs.len
    self.average = self.elapsed / self.runsCount
    self.lastTic = null
end function

formatStr = "Time elapsed: {elapsed}" + char(10) +
  "Runs count: {runsCount}" + char(10) +
  "Fastest run: {min}" + char(10) +
  "Slowest run: {max}" + char(10) +
  "Average run: {average}" + char(10)

Benchmark.Stopwatch.class.toString = function(self)
    return formatStr.fill(self)
end function

Benchmark.into = function(scope)
    scope.bench = @Benchmark.bench
    scope.Stopwatch = @Benchmark.Stopwatch
end function

return Benchmark