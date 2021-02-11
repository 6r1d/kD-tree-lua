-- Binary heap implementation from:
-- http://eloquentjavascript.net/appendix2.html
-- Currently untested.

local BinaryHeap = {
    content = nil,
    scoreFunction = nil
}

function BinaryHeap:new(o, scoreFunction)
   o = o or {}
   setmetatable(o, self)
   -- https://www.lua.org/pil/13.4.1.html
   self.__index = self
   self.content = {}
   self.scoreFunction = scoreFunction
   return o
end

function BinaryHeap:push(element)
    -- Add the new element to the end of the array.
    -- Alternative: foo[#foo+1]="bar"
    table.insert(self.content, element)
    -- Allow it to bubble up.
    self:bubbleUp(#self.content - 1)
end

function BinaryHeap:pop()
    -- Store the first element so we can return it later.
    local result = self.content[1]
    -- Get the element at the end of the array
    -- https://www.lua.org/pil/19.2.html
    local array_last = table.remove(self.content)
    -- If there are any elements left, put the end element at the
    -- start, and let it sink down.
    if #self.content > 0 then
       self.content[1] = array_last
       self.sinkDown(0)
    end
    return result
end

function BinaryHeap:peek()
    return self.content[1]
end

function BinaryHeap:remove(node)
    local len = #self.content
    -- To remove a value, we must search through the array to find it.
    for i=0, len, 1 do
        if (self.content[i] == node) then
            -- When it is found, the process seen in 'pop' is repeated
            -- to fill up the hole.
            local ct_end = table.remove(self.content)
            if i ~= len - 1 then
                self.content[i] = ct_end
                if (self.scoreFunction(ct_end) < self.scoreFunction(node)) then
                    self.bubbleUp(i)
                else
                    self.sinkDown(i)
                end
            end
            return
        end
    end
    print("Node not found.")
end

function BinaryHeap:size()
    return #self.content
end

function BinaryHeap:bubbleUp(n)
    -- Fetch the element that has to be moved.
    local element = self.content[n]
    -- When at 0, an element can not go up any further.
    while (n > 0) do
        -- Compute the parent element's index, and fetch it.
        local parentN = math.floor((n + 1) / 2) - 1
        local parent = self.content[parentN]
        -- Swap the elements if the parent is greater.
        if (self.scoreFunction(element) < self.scoreFunction(parent)) then
            self.content[parentN] = element
            self.content[n] = parent
            -- Update 'n' to continue at the new position.
            n = parentN
        else
            -- Found a parent that is less, no need to move it further.
            break
        end
    end
end

function BinaryHeap:sinkDown(n)
    -- Look up the target element and its score.
    local length = #self.content
    local element = self.content[n]
    local elemScore = self.scoreFunction(element)
    local child1Score
    local child2Score

    while true do
        -- Compute the indices of the child elements.
        local child2N = (n + 1) * 2
        local child1N = child2N - 1
        -- This is used to store the new position of the element, if any.
        local swap = nil
        -- If the first child exists (is inside the array)...
        if child1N < length then
            -- Look it up and compute its score.
            local child1 = self.content[child1N]
            child1Score = self.scoreFunction(child1)
            -- If the score is less than our element's, we need to swap.
            if child1Score < elemScore then
                swap = child1N
            end
        end
        -- Do the same checks for the other child.
        if child2N < length then
            local child2 = self.content[child2N]
            child2Score = self.scoreFunction(child2)
            local chkScore
            if swap == nil then
                chkScore = elemScore
            else
                chkScore = child1Score
            end
            if child2Score < chkScore then
                swap = child2N
            end
        end
        if swap ~= nil then
            -- If the element needs to be moved, swap it, and continue.
            self.content[n] = self.content[swap]
            self.content[swap] = element
            n = swap
        else
            -- Otherwise, we are done.
            break
        end
    end
end

-------------------------------------------------------
-- An implementation of kD-Tree node
-------------------------------------------------------

local Node = {
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

-------------------------------------
-- kDTree
-------------------------------------

local KD_tree = {
    metric = nil,
    dimensions = nil,
    root = nil
}

local function buildTree(dimensions, points, depth, parent)
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
            return a[dimensions[dim]] < b[dimensions[dim]]
        end
    )
    --
    median = math.floor(#points / 2)
    node = Node:new(nil, points[median], dim, parent)
    node.left = buildTree(dimensions, points.slice(0, median), depth + 1, node)
    node.right = buildTree(dimensions, points.slice(median + 1), depth + 1, node)
    --
    return node
end

-- kD-Tree instancing
function KD_tree:new(points, metric, dimensions)
    self.metric = metric
    self.dimensions = dimensions
    -- if (!Array.isArray(points)) loadTree(points, metric, dimensions);
    -- else
    self.root = buildTree(dimensions, points, 0, nil)
end

function KD_tree:innerSearch(node, parent, point)
    if node == nil then
       return parent
    end
    local dimension = self.dimensions[node.dimension]
    if point[dimension] < node.obj[dimension] then
       return self.innerSearch(node.left, node)
    else
       return self.innerSearch(node.right, node)
    end
end

function KD_tree:insertToTree(point)
    local insertPosition = self.innerSearch(self.root, nil, point)
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
function KD_tree:nodeSearch(node, point)
    if node == nil then
        return nil
    end

    if node.obj == point then
        return node
    end

    local dimension = self.dimensions[node.dimension]

    if (point[dimension] < node.obj[dimension]) then
        return self.nodeSearch(node.left, point)
    else
        return self.nodeSearch(node.right, point)
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

    dimension = self.dimensions[dim]
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

function KD_tree:balanceFactor()
    -- A height function from balanceFactor
    local function bf_height(node)
        if node == nil then
            return 0
        end
        return math.max(bf_height(node.left), bf_height(node.right)) + 1
    end

    -- A count function from balanceFactor
    local function bf_count(node)
        if node == nil then
            return 0
        end
        return bf_count(node.left) + bf_count(node.right) + 1
    end

    return bf_height(self.root) / (math.log(bf_count(self.root)) / math.log(2))
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
        nextNode = self.findMax(node.left, node.dimension)
    else
        nextNode = self.findMin(node.right, node.dimension)
    end

    nextObj = nextNode.obj
    self.removeNode(nextNode)
    node.obj = nextObj
end

function KD_tree:remove(point)
    local node = self.nodeSearch(self.root, point)
    if node == nil then
        return
    end
    self.removeNode(node)
end

-- Previously a part of nearestSearch
local saveNode = function(node, distance, maxNodes, bestNodes)
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

    for dim_idx=0, #self.dimensions, 1 do
        if dim_idx == node.dimension then
            linearPoint[self.dimensions[dim_idx]] = point[self.dimensions[dim_idx]]
        else
            linearPoint[self.dimensions[dim_idx]] = node.obj[self.dimensions[dim_idx]]
        end
    end

    linearDistance = self.metric(linearPoint, node.obj)

    if node.children_nil() then
        if bestNodes.size() < maxNodes or ownDistance < bestNodes.peek()[1] then
            self.saveNode(node, ownDistance, maxNodes, bestNodes)
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
local score_fn = function(e)
    return -e[1]
end

-- Was called treeNearest in JS version
function KD_tree:nearest(point, maxNodes, maxDistance)
    local result
    local bestNodes

    bestNodes = BinaryHeap:new(nil, score_fn)

    if maxDistance then
        for _=0, maxNodes, 1 do
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

return KD_tree
