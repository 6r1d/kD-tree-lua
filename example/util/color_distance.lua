-- A color distance function ported from kdTree.js demo.
-- Essentially, it tells how different the colors are.
-- Demo's one was based on a color distance from
-- http://www.compuphase.com/cmetric.htm
--
-- `col_a` and `col_b` arguments accept Lua tables with color ranges from 0 to 255 like
-- { red = 127, green = 127, blue = 127 }

function color_distance(col_a, col_b)
    local dr = col_a.red - col_b.red
    local dg = col_a.green - col_b.green
    local db = col_a.blue - col_b.blue
    local red_mean = (col_a.red + col_b.red) / 2
    return (2 + red_mean / 256) * dr * dr + 4 * dg * dg + (2 + (255 - red_mean) / 256) * db * db;
end
