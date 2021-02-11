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
    if #points == 0 then
        return nil
    end
    if #points == 1 then
        return Node:new(nil, points[1], dim, parent)
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
    median = math.floor(#points / 2)
    node = Node:new(nil, points[median], dim, parent)
    node.left = buildTree(points.slice(0, median), depth + 1, node)
    node.right = buildTree(points.slice(median + 1), depth + 1, node)
    --
    return node
end

function KD_tree:insertToTree(point)
    function innerSearch(node, parent)
        if node == nil then
            return parent
        end

        local dimension = self.dimensions[node.dimension]
        if point[dimension] < node.obj[dimension] then
            return innerSearch(node.left, node)
        else
            return innerSearch(node.right, node)
        end
    end

    local insertPosition = innerSearch(self.root, nil)
    local newNode
    local dimension

    if insertPosition == nil then
        self.root = Node:new(nil, point, 0, nil)
        return
    end

    newNode = Node:new(nil, point, (insertPosition.dimension + 1) % #self.dimensions, insertPosition)
    dimension = self.dimensions[insertPosition.dimension]

    if (point[dimension] < insertPosition.obj[dimension]) then
        insertPosition.left = newNode
    else
        insertPosition.right = newNode
    end
end

-- Previously a part of a KD_tree:remove method
function KD_tree:treeNodeSearch(node)
    if node == nil then
        return nil
    end

    if node.obj == point then
        return node
    end

    local dimension = self.dimensions[node.dimension]

    if (point[dimension] < node.obj[dimension]) then
        return nodeSearch(self.dimensions, node.left, node)
    else
        return nodeSearch(self.dimensions, node.right, node)
    end
end

-- Previously a part of a KD_tree:remove method
function KD_tree:findMax(node, dim)
    local dimension
    local own
    local left
    local right
    local max

    if node == nil then
        return nil
    end

    dimension = tree.dimensions[dim]
    if node.dimension == dim then
        if node.right ~= nil then
            return self.findMax(node.right, dim)
        end
        return node
    end

    own = node.obj[dimension]
    left = self.findMax(node.left, dim)
    right = self.findMax(node.right, dim)
    max = node

    if left ~= nil and left.obj[dimension] > own then
        max = left
    end

    if right ~= nil and right.obj[dimension] > max.obj[dimension] then
        max = right
    end
    return max
end

-- Previously a part of a KD_tree:remove method
function KD_tree:findMin(node, dim)
    local dimension
    local own
    local left
    local right
    local min

    if node == nil then
        return nil
    end

    dimension = self.dimensions[dim]

    if node.dimension == dim then
        if node.left ~= nil then
            return self.findMin(node.left, dim)
        end
        return node
    end

    own = node.obj[dimension]
    left = self.findMin(node.left, dim)
    right = self.findMin(node.right, dim)
    min = node

    if left ~= nil and left.obj[dimension] < own then
        min = left
    end
    if right ~= nil and right.obj[dimension] < min.obj[dimension] then
        min = right
    end
    return min
end

function KD_tree:balanceFactor(node)
    function height(node)
        if node == nil then
            return 0
        end
        return math.max(height(node.left), height(node.right)) + 1
    end

    function count(node)
        if node == nil then
            return 0
        end
        return count(node.left) + count(node.right) + 1
    end

    return height(self.root) / (math.log(count(self.root)) / math.log(2))
end

-- Previously a part of a KD_tree:remove method
function KD_tree:removeNode(dimensions, node)
    local nextNode
    local nextObj
    local pDimension

    if node.children_nil() then
        if node.parent_nil() then
            self.root = nil
            return
        end

        pDimension = dimensions[node.parent.dimension]

        if node.obj[pDimension] < node.parent.obj[pDimension] then
            node.parent.left = nil
        else
            node.parent.right = nil
        end
        return
    end

    if node.left ~= nil then
        nextNode = findMax(node.left, node.dimension)
    else
        nextNode = findMin(node.right, node.dimension)
    end

    nextObj = nextNode.obj
    removeNode(nextNode)
    node.obj = nextObj
end

function KD_tree:treeRemoveNode(point)
    local node = nodeSearch(dimensions, self.root)
    if node == nil then
        return
    end
    self.removeNode(node)
end

-- Previously a part of nearestSearch
function saveNode(node, distance, maxNodes, bestNodes)
    bestNodes.push({node, distance})
    if bestNodes.size() > maxNodes then
        bestNodes.pop()
    end
end

-- TODO I put these arguments in that order while
-- hating the heavily folded structure of this code. Rearrange. Rearrange hard.
function KD_tree:nearestSearch(node, point, bestNodes, maxNodes)
    local bestChild
    local dimension = self.dimensions[node.dimension]
    local ownDistance = self.metric(point, node.obj)
    local linearPoint = {}
    local linearDistance
    local otherChild
    local i

    for i=0, #self.dimensions, 1 do
        if i == node.dimension then
            linearPoint[self.dimensions[i]] = point[self.dimensions[i]]
        else
            linearPoint[self.dimensions[i]] = node.obj[self.dimensions[i]]
        end
    end

    linearDistance = self.metric(linearPoint, node.obj)

    if node.children_nil() then
        if bestNodes.size() < maxNodes or ownDistance < bestNodes.peek()[1] then
            saveNode(node, ownDistance, maxNodes, bestNodes)
        end
        return
    end

    if node.right == nil then
        bestChild = node.left
    elseif node.left == nil then
        bestChild = node.right
    else
        if point[dimension] < node.obj[dimension] then
            bestChild = node.left
        else
            bestChild = node.right
        end
    end

    self.nearestSearch(bestChild, point, bestNodes, maxNodes)

    if bestNodes.size() < maxNodes or ownDistance < bestNodes.peek()[1] then
        saveNode(node, ownDistance, maxNodes, bestNodes)
    end

    if bestNodes.size() < maxNodes or math.abs(linearDistance) < bestNodes.peek()[1] then
        if bestChild == node.left then
            otherChild = node.right
        else
            otherChild = node.left
        end
        if otherChild ~= nil then
            self.nearestSearch(otherChild, point, bestNodes, maxNodes)
        end
    end
end

-- A score function for a binary heap in
-- kDTree's "nearest" method implementation.
function score_fn(e)
    return -e[1]
end

-- Was called treeNearest in JS version
function KD_tree:nearest(point, maxNodes, maxDistance)
    local i
    local result
    local bestNodes

    bestNodes = BinaryHeap:new(nil, score_fn)

    if maxDistance then
        for i=0, maxNodes, 1 do
            bestNodes.push({nil, maxDistance})
        end
    end

    self.nearestSearch(self.root, point, bestNodes, maxNodes);

    result = {}

    for i=0, maxNodes, 1 do
        if bestNodes.content[i][1] then
            result.insert({bestNodes.content[i][1].obj, bestNodes.content[i][1]})
        end
    end
    return result
end

-- kD-Tree instancing
function KD_tree:new(points, metric, dimensions)
    self.metric = metric
    self.dimensions = dimensions
    self.root = buildTree(points, dimensions, 0, nil)
end
