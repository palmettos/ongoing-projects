local class = require 'libs.hump.class'

local utils = {}

--------------------------------------------------------------------------------
-- utility classes
--------------------------------------------------------------------------------

utils.graph2d = class {}

function utils.graph2d:init()
    self.nodes = {}
    -- basically defaultdict(dict) in python
    self.edges = setmetatable (
        {},
        {
            __index = function(t, k)
                t[k] = {}
                return t[k]
            end
        }
    )
end

function utils.graph2d:addNode(node)
    if not utils.contains(self.nodes, node) then
        self.nodes[#self.nodes+1] = node
    end
end

function utils.graph2d:addEdge(from, to)
    -- this method is slightly faster than table.insert :(
    self.edges[from][#self.edges[from]+1] = to
    self.edges[to][#self.edges[to]+1]     = from
end

function utils.graph2d:gen2dNodesAndEdges(rows, cols)
    for i in utils.grange(rows) do
        for j in utils.grange(cols) do
            self:addNode(tostring(i)..', '..tostring(j))
        end
    end

    for pi, i in utils.pairwise(utils.range(rows)) do
        for j in utils.grange(cols) do
            local from = tostring(i)..', '..tostring(j)
            local to   = tostring(pi)..', '..tostring(j)
            self:addEdge(from, to)
        end
    end

    for i in utils.grange(rows) do
        for pj, j in utils.pairwise(utils.range(cols)) do
            local from = tostring(i)..', '..tostring(j)
            local to   = tostring(i)..', '..tostring(pj)
            self:addEdge(from, to)
        end
    end
end

-- uses dijkstra's algorithm to return all shortest paths to and from all nodes
function utils.graph2d:generatePaths()
    local paths = {}
    for _, currentNode in ipairs(self.nodes) do
        local visited = {[currentNode] = 0}
        local path = {}

        local nodes = {}
        for _, v in ipairs(self.nodes) do
            nodes[#nodes+1] = v
        end

        while #nodes > 0 do
            local minNode = nil
            for _, node in ipairs(nodes) do
                if visited[node] then
                    if not minNode then
                        minNode = node
                    elseif visited[node] < visited[minNode] then
                        minNode = node
                    end
                end
            end

            if not minNode then
                break
            end

            utils.removeValue(nodes, minNode)
            local cw = visited[minNode]

            for _, edge in ipairs(self.edges[minNode]) do
                local w = cw + 1
                if (not visited[edge]) or (w < visited[edge]) then
                    visited[edge] = w
                    path[edge] = minNode
                end
            end
        end
        paths[currentNode] = path
    end
    self.paths = paths
end


utils.deque = class {}

function utils.deque:init()
    self.head = 1
    self.tail = 0
    self.contents = {}
end

function utils.deque:pushLeft(value)
    self.contents[self.tail] = value
    self.tail = self.tail - 1
end

function utils.deque:pushRight(value)
    self.contents[self.head] = value
    self.head = self.head + 1   
end

function utils.deque:popLeft()
    if self.contents[self.tail+1] then
        self.tail = self.tail + 1
        if self.tail >= self.head then
            print('self.tail collided with self.head')
            self.head = self.tail + 1
        end
        local ret = self.contents[self.tail]
        self.contents[self.tail] = nil
        return ret
    end
    return nil
end

function utils.deque:popRight()
    if self.contents[self.head-1] then
        self.head = self.head - 1
        if self.head <= self.tail then
            print('self.head collided with self.tail')
            self.tail = self.head - 1
        end
        local ret = self.contents[self.head]
        self.contents[self.head] = nil
        return ret
    end
    return nil
end

function utils.deque:peakLeft()
    return self.contents[self.tail+1]
end

function utils.deque:peakRight()
    return self.contents[self.head-1]
end

function utils.deque:len()
    return self.head-1-self.tail
end

--------------------------------------------------------------------------------
-- utility functions
--------------------------------------------------------------------------------

function utils.range(n)
    local ret = {}
    for i=1, n do
        ret[#ret+1] = i
    end
    return ret
end

function utils.grange(n)
    local i = 1
    return function()
        if i <= n then
            i = i + 1
            return i - 1
        end
    end
end

-- adapted from python's itertools.tee
function utils.tee(t, n)
    local n = n or 2
    local pos = 1
    
    local deques = {}
    for i=1, n do
        deques[i] = utils.deque()
    end

    local gen = function(mydeque)
        return function()
            if mydeque:len() < 1 then
                local new = t[pos]
                pos = pos + 1
                for _, deque in ipairs(deques) do
                    deque:pushRight(new)
                end
            end
            return mydeque:popLeft()
        end
    end

    local ret = {}
    for _, d in ipairs(deques) do
        ret[#ret+1] = gen(d)
    end
    return ret
end

-- adapted from python's built-in zip
-- zip{{1, 2, 3}, {3, 4, 5}} --> {1, 3}, {2, 4}, {3, 5}
function utils.zip(generators)
    return function()
        local res = {}
        for _, generator in ipairs(generators) do
            local ele = generator()
            if not ele then
                return nil
            end
            res[#res+1] = ele
        end
        return res[1], res[2]
    end
end

-- adapted from python's itertools recipes
function utils.pairwise(iterable)
    local t = utils.tee(iterable)
    t[2]()
    return utils.zip({t[1], t[2]})
end

function utils.removeValue(t, value)
    for i, v in ipairs(t) do
        if value == v then
            table.remove(t, i)
        end
    end
end

function utils.contains(t, value)
    for i, v in ipairs(t) do
        if value == v then
            return true
        end
    end
    return false
end

function utils.choice(t)
    return t[rand(1, #t)]
end

-- booleans to true or false
-- all true values to true and all false values to false
function utils.b2tf(v)
    return v and true or false
end

-- true/false to int
-- return 1 for true, 0 for false
-- ex: a = 10 * tftoi(dist({1, 1}, {2, 2}) > 1)
function b2i(bool)
    if bool then
        return 1
    end
    return 0
end

function utils.dist(pair1, pair2)
    return math.sqrt((pair2[1]-pair1[1])^2 + (pair2[2]-pair1[2])^2)
end

--[[----------------------------------------------------------------------------
-- Creates a rect from a coordinate.
--]]----------------------------------------------------------------------------
function utils.createRectFromPoint(x, y, w, h)
    return x-w/2, y-h/2, w, h
end

return utils