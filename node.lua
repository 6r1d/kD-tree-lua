-- This file contains an implementation of kD-Tree node

Node = {
    obj = nil,
    left = nil,
    right = nil,
    parent = nil,
    dimension = nil
}

function Node:new(o, obj, dimension, parent)
   o = o or {}
   setmetatable(o, self)
   -- https://www.lua.org/pil/13.4.1.html
   self.__index = self
   this.obj = obj
   this.left = nil
   this.right = nil
   this.parent = parent
   this.dimension = dimension
   return o
end
