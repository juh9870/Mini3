// @namespace mini3.Loop
// Module containing system Loop and its utilites
hook locals

// @typedef {(string|(World)=>void|List<SystemLike>)} SystemLike - Something that can work as a system

module.import("scrapcore.oop").into locals
module.import("scrapcore.system").into locals
Fp = module.import("scrapcore.fp")

Loop = extends(ClassHolder, "Loop")

Loop.make = function(self, condition = null)
    loop = super.make
    loop._condition = condition
    return loop
end function

Loop.class._ctor = function
    super._ctor
    self._step = []
    self._beforeReload = []
    self._afterReload = []
    self._worldInit = []
    self._stateEnter = []
    self._stateExit = []
    self._condition = null
end function

Loop.class._step = null
Loop.class._beforeReload = null
Loop.class._afterReload = null
Loop.class._worldInit = null
Loop.class._stateEnter = null
Loop.class._stateExit = null
Loop.class._condition = null

// @public
// Adds a range of systems to run in the loop
// @param {...SystemLike} systems - systems to run under the condition
Loop.class.add = Fp.variadicSelf("_add")

Loop.class._add = function(self, system)
    if system isa list then
        // print "adding a list system, " + system.len + " items"
        for sys in system
            if sys == null then continue
            self._add @sys
        end for
    else if system isa string then
        // print "adding a string system " + system
        self._add module(system)
    else if system isa funcRef then
        self._step.push {"step": @system}
    else if system isa map then
        // print "adding a map system with name " + mapName(system)
        // Loop step
        if system.hasIndex("step") then
            self._step.push system
        end if
        // World initialization handler
        if system.hasIndex("worldInit") then
            self._worldInit.push system
        end if
        // Reload handlers
        if system.hasIndex("beforeReload") then
            self._beforeReload.push system
        end if
        if system.hasIndex("afterReload") then
            self._afterReload.push system
        end if
        // State change handlers
        if system.hasIndex("stateEnter") then
            self._stateEnter.push system
        end if
        if system.hasIndex("stateExit") then
            self._stateExit.push system
        end if
    else
        throw "Only strings, lists or functions or maps can be added as a system"
    end if
end function

runMany = function(key)
    fn = function(self, world)
        if self._condition != null and not self._condition(world) then
            return
        end if
        systems = self["_" + key]
        // print "Running " + key + " callback on " + systems.len + " systems"
        for sys in systems
            // print mapName(sys)
            sys[key] world
        end for
    end function
    return @fn
end function

Loop.class.step = runMany("step")
Loop.class.worldInit = runMany("worldInit")
Loop.class.beforeReload = runMany("beforeReload")
Loop.class.afterReload = runMany("afterReload")
Loop.class.stateEnter = runMany("stateEnter")
Loop.class.stateExit = runMany("stateExit")

_runIf = function(args)
    condition = args[0]
    systems = args[1:]
    loop = Loop.make(@condition)
    loop._add args
    return loop
end function

// @public
// Creates a loop that only runs if some condition is satified
// @param {(World)=>boolean} condition - condition under which the system is ran
// @param {...SystemLike} systems - systems to run under the condition
runIf = Fp.variadic(@_runIf)

// @public
// Creates a predicate that checks for world being in a specific state
// @param {(World)=>boolean} condition - condition under which the system is ran
// @param {...SystemLike} systems - systems to run under the condition
inState = function(state)
    fn = function(world)
        return world.state == state
    end function
    return fn
end function

export "Loop"
export "runIf"
export "inState"