-- Binary heap implementation from:
-- http://eloquentjavascript.net/appendix2.html
-- Translated to Lua by 6r1d.
-- Currently untested.

BinaryHeap = {
    content = nil,
    scoreFunction = nil
}

function BinaryHeap:new(o, scoreFunction)
   o = o or {}
   setmetatable(o, self)
   -- https://www.lua.org/pil/13.4.1.html
   self.__index = self
   self.content = {};
   self.scoreFunction = scoreFunction;
   return o
end

function BinaryHeap:push(element)
    -- Add the new element to the end of the array.
    -- Alternative: foo[#foo+1]="bar"
    table.insert(self.content, element)
    -- Allow it to bubble up.
    self:bubbleUp(#self.content - 1);
end

function BinaryHeap:pop()
    -- Store the first element so we can return it later.
    local result = self.content[0]
    -- Get the element at the end of the array
    -- https://www.lua.org/pil/19.2.html
    -- TODO table.remove(a) or table.remove(a, 1)?
    local array_last = table.remove(self.content)
    -- If there are any elements left, put the end element at the
    -- start, and let it sink down.
    if (#self.content > 0) then
       self.content[0] = array_last
       self.sinkDown(0)
    end
    return result
end

function BinaryHeap:peek()
    return self.content[0]
end

function BinaryHeap:remove(node)
    local len = #self.content
    -- To remove a value, we must search through the array to find it.
    for i=0, len, 1 do
        if (this.content[i] == node) then
            -- When it is found, the process seen in 'pop' is repeated
            -- to fill up the hole.
            local ct_end = table.remove(self.content)
            if i ~= len - 1 then
                self.content[i] = ct_end
                if (self.scoreFunction(ct_end) < this.scoreFunction(node)) then
                    this.bubbleUp(i)
                else
                    self.sinkDown(i)
                end
            end
            return
        end
    end
    print("Node not found.");
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

    while true do
        -- Compute the indices of the child elements.
        local child2N = (n + 1) * 2
        local child1N = child2N - 1
        -- This is used to store the new position of the element, if any.
        local swap = null
        -- If the first child exists (is inside the array)...
        if (child1N < length) then
            -- Look it up and compute its score.
            local child1 = this.content[child1N]
            local child1Score = this.scoreFunction(child1)
            -- If the score is less than our element's, we need to swap.
            if child1Score < elemScore then
                swap = child1N
            end
        end
        -- Do the same checks for the other child.
        if (child2N < length) then
            local child2 = self.content[child2N]
            local child2Score = self.scoreFunction(child2)
            local chkScore
            if swap == null then
                chkScore = elemScore
            else
                chkScore = child1Score
            end
            if child2Score < chkScore then
                swap = child2N
            end
        end
        -- If the element needs to be moved, swap it, and continue.
        if swap ~= null then
            this.content[n] = this.content[swap]
            this.content[swap] = element
                n = swap
        -- Otherwise, we are done.
        else
            break
        end
    end
end
