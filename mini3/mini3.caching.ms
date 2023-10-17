hook locals
require "extends", "ClassHolder", from("scrapcore.oop")
require "throw", from("scrapcore.system")

// #region Pool

Pool = extends(ClassHolder, "Pool")

Pool.make = function(self, inator)
    pool = super.make
    if inator == null then
        inator = function
            return {}
        end function
    else if not @inator isa funcRef then
        throw "Pool must be constructed with a function inator, but got a value instead. Did you forget to use ""@""?"
    end if
    pool._inator = @inator
    return pool
end function

Pool.class._ctor = function
    self._inator = null
    self._pool = []
end function

Pool.class._inator = null
Pool.class._pool = null

Pool.class.get = function(self)
    item = self._pool.pop
    if item != null then return item
    return self._inator
end function

Pool.class.release = function(self, item)
    self._pool.push item
end function

Pool.class.releaseMany = function(self, items)
    self._pool += items
end function

// #end region

// #region Cache

// Cache = extends(ClassHolder, "Cache")

// #end region

export "Pool"