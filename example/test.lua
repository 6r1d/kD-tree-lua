local TCls = {prop = nil}

function TCls:new(o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   self.prop = 123
   return o
end

function TCls:pp()
    print(self.prop)
end

local tc = TCls:new(nil)
tc:pp()
