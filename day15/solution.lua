local nodes = {}

local row_ = 0
local total_risk = 0
local line_length = -1

for _, line in ipairs(vim.fn.readfile('example-input.txt')) do
  for i = 1, #line do
    if line_length == -1 then
      line_length = #line
    end

    local c = line:sub(i, i)

    total_risk = total_risk + tonumber(c)

    nodes[(row_ * line_length) + (i - 1)] = {
      col = i - 1,
      row = row_,
      visited = false,
      risk = tonumber(c),

      global_goal = math.huge,
      local_goal = math.huge,

      parent = nil,
    }
  end

  row_ = row_ + 1
end

local function distance_to_end(row, col)
  local end_node = nodes[#nodes]
  return math.abs(end_node.col - col) + math.abs(end_node.row - row)
end

local function neighbors_of(row, col)
  local neighbors = {}
  neighbors[0] = { row = row - 1, col = col } -- above

  neighbors[1] = { row = row, col = col - 1 } -- left
  neighbors[2] = { row = row, col = col + 1 } -- right

  neighbors[3] = { row = row + 1, col = col } -- below

  return neighbors
end

local function astar()
  local node_current = nodes[0]

  node_current.local_goal = node_current.risk
  node_current.global_goal = distance_to_end(node_current.row, node_current.col)

  local not_tested = { node_current }
  local i = 0
  while vim.tbl_isempty(not_tested) ~= 1 do
    not_tested = vim.tbl_filter(function(x)
      return not x.visited
    end, not_tested)

    table.sort(not_tested, function(x, y)
      return x.global_goal < y.global_goal
    end)

    i = i + 1
    if #not_tested == 0 then
      break
    end

    node_current = not_tested[1]
    node_current.visited = true

    local neighbors_positions = neighbors_of(node_current.row, node_current.col)

    for _, pos in ipairs(neighbors_positions) do
      if pos.row < 0 or pos.row > (#nodes / line_length) or pos.col < 0 or pos.col > line_length - 1 then
        goto continue
      end

      local neighbor = nodes[pos.row * line_length + pos.col]

      if not neighbor.visited then
        not_tested[#not_tested + 1] = neighbor
      end

      local possibly_lower_goal = node_current.local_goal + neighbor.risk

      if possibly_lower_goal < neighbor.local_goal then
        neighbor.parent = node_current
        neighbor.local_goal = possibly_lower_goal

        neighbor.global_goal = neighbor.local_goal + distance_to_end(neighbor.row, neighbor.col)
      end

      ::continue::
    end
  end
end

astar()

local path_distance = 0
local path_risk_sum = 0 - nodes[0].risk
local node_current = nodes[#nodes]

while node_current ~= nil do
  -- print(node_current.row, node_current.col, node_current.risk)
  path_risk_sum = path_risk_sum + node_current.risk
  node_current = node_current.parent
  path_distance = path_distance + 1
end
print("path risk sum", path_risk_sum)
print ("path distance", path_distance)
