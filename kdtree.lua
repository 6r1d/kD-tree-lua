dofile('binary_heap.lua')
dofile('node.lua')

KD_tree = {
    metric = nil,
    dimensions = nil,
    root = nil
}

function buildTree(points, dimensions, depth, parent)
    local dim = depth % #dimensions
    local median
    local node
    -- 
    if points.length == 0 then
        return null
    end
    if points.length == 1 then
        return Node:new(nil, points[0], dim, parent)
    end
    -- 
    table.sort(
        points,
        function(a, b)
            -- TODO Just an untested assumption
            return a[dimensions[dim]] < b[dimensions[dim]]
        end
    )
    -- 
    median = math.floor(points.length / 2)
    node = Node:new(nil, points[median], dim, parent)
    node.left = buildTree(points.slice(0, median), depth + 1, node)
    node.right = buildTree(points.slice(median + 1), depth + 1, node)
    -- 
    return node
end

-- kD-Tree instancing
function KD_tree:new(points, metric, dimensions)
    this.metric = metric
    this.dimensions = dimensions
    this.root = buildTree(points, dimensions, 0, null)
end
