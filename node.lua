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
   self.obj = obj
   self.left = nil
   self.right = nil
   self.parent = parent
   self.dimension = dimension
   return o
end

function Node:parent_nil()
   return self.parent == nil
end

-- Both left and right tree children are unset
function Node:children_nil()
   return self.right == nil and self.left == nil
end
