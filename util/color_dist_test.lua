dofile('color_distance.lua')

local a = {
    red = 127,
    green = 127,
    blue = 127
}

local b = {
    red = 0,
    green = 255,
    blue = 159
}

print(color_distance(a, b))
