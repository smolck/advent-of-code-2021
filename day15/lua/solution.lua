local function read_nodes_from_file_contents(file_contents)
    local nodes = {}
    local row_ = 0
    local line_length = -1

    for _, line in ipairs(file_contents) do
      for i = 1, #line do
        if line_length == -1 then
          line_length = #line
        end

        local c = line:sub(i, i)

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

    return { nodes = nodes, line_length = line_length }
end

local function distance_to_end(row, col, end_node)
  return math.abs(end_node.col - col) + math.abs(end_node.row - row)
  --return math.pow(end_node.col - col, 2) + math.pow(end_node.row - row, 2)
end

local function neighbors_of(row, col)
  local neighbors = {}
  neighbors[0] = { row = row - 1, col = col } -- above

  neighbors[1] = { row = row, col = col - 1 } -- left
  neighbors[2] = { row = row, col = col + 1 } -- right

  neighbors[3] = { row = row + 1, col = col } -- below

  return neighbors
end

local function astar(nodes, line_length)
  local node_current = nodes[0]

  node_current.local_goal = 0
  node_current.global_goal = distance_to_end(node_current.row, node_current.col, nodes[#nodes])

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

      local possibly_lower_goal = node_current.local_goal + neighbor.risk + distance_to_end(node_current.row, node_current.col, neighbor)

      if possibly_lower_goal < neighbor.local_goal then
        neighbor.parent = node_current
        neighbor.local_goal = possibly_lower_goal

        neighbor.global_goal = neighbor.local_goal + distance_to_end(neighbor.row, neighbor.col, nodes[#nodes])
      end

      ::continue::
    end
  end
end

local function count_path_risk(nodes)
    local path_risk_sum = 0 - nodes[0].risk
    local node_current = nodes[#nodes]

    while node_current ~= nil do
      path_risk_sum = path_risk_sum + node_current.risk
      node_current = node_current.parent
    end

    return path_risk_sum
end

local file_contents1 = vim.fn.readfile('input.txt')
local nodes_partone = read_nodes_from_file_contents(file_contents1)
astar(nodes_partone.nodes, nodes_partone.line_length)

local risk = count_path_risk(nodes_partone.nodes)
print("Answer to part one (total risk): " .. tostring(risk))

local function read_nodes_from_file_contents_full(file_contents, iteration)
    local nodes = {}
    local row_ = 0
    local line_length = -1

    local str = ""

    for _, line in ipairs(file_contents) do
      local line_risks = {}
      local current_risks = {}

      for i = 1, #line do
        if line_length == -1 then
          line_length = #line * 5
        end

        local c = line:sub(i, i)
        c = (tonumber(c) + iteration > 9) and ((tonumber(c) + iteration) - 9) or (tonumber(c) + iteration)

        line_risks[#line_risks + 1] = (c + 1 > 9) and 1 or (c + 1)

        nodes[(row_ * line_length) + (i - 1)] = {
          col = i - 1,
          row = iteration == 0 and row_ or row_ + (iteration * 10),
          visited = false,
          risk = c,

          global_goal = math.huge,
          local_goal = math.huge,

          parent = nil,
        }
        current_risks[#current_risks+1] = c
      end

      local i2 = 1
      for i = #line + 1, line_length do
        nodes[(row_ * line_length) + (i - 1)] = {
          col = i - 1,
          row = iteration == 0 and row_ or row_ + (iteration * 10),
          visited = false,
          risk = line_risks[i2],

          global_goal = math.huge,
          local_goal = math.huge,

          parent = nil,
        }
        current_risks[#current_risks+1] = line_risks[i2]

        line_risks[i2] = (line_risks[i2] + 1 > 9) and 1 or line_risks[i2] + 1

        i2 = i2 + 1
        if i2 % (#line_risks + 1) == 0 then
            i2 = 1
        end
      end

      str = str .. table.concat(current_risks, '') .. '\n'
      row_ = row_ + 1
    end

    -- print("    ")
    return { nodes = nodes, line_length = line_length, str = str }
end

local function combine(tbl1, tbl2)
    for i = 0, #tbl2 do
        tbl1[#tbl1 + 1] = tbl2[i]
    end
end

local file_contents2 = vim.fn.readfile('example-input.txt')
local nodes_parttwo = read_nodes_from_file_contents_full(file_contents2, 0)
local line_length = nodes_parttwo.line_length
local str = nodes_parttwo.str

str = str .. (read_nodes_from_file_contents_full(file_contents2, 1).str)
str = str .. (read_nodes_from_file_contents_full(file_contents2, 2).str)
str = str .. (read_nodes_from_file_contents_full(file_contents2, 3).str)
str = str .. (read_nodes_from_file_contents_full(file_contents2, 4).str)

vim.fn.writefile(vim.split(str, '\n'), 'full-example-input-generated.txt')
-- local nodes_actually = read_nodes_from_file_contents(vim.fn.readfile('seans-input.txt'))
-- astar(nodes_actually.nodes, nodes_actually.line_length)
-- 
-- local risk = count_path_risk(nodes_actually.nodes)
-- print("Answer to part two (total risk): " .. tostring(risk))

-- print(str)

-- combine(nodes_parttwo.nodes, read_nodes_from_file_contents_full(file_contents, 1).nodes)
-- combine(nodes_parttwo.nodes, read_nodes_from_file_contents_full(file_contents, 2).nodes)
-- combine(nodes_parttwo.nodes, read_nodes_from_file_contents_full(file_contents, 3).nodes)
-- combine(nodes_parttwo.nodes, read_nodes_from_file_contents_full(file_contents, 4).nodes)

-- print(vim.inspect(nodes_parttwo.nodes[#nodes_parttwo.nodes - 1]))
-- astar(nodes_parttwo.nodes, line_length)
-- local risk = count_path_risk(nodes_parttwo.nodes)
-- print("Answer to part two (total risk): " .. tostring(risk))

-- local line = ""
-- for i = 10 * line_length, (nodes_parttwo.line_length - 1) * 10 do
--     line = line .. tostring(nodes_parttwo.nodes[i].risk)
-- end
-- 
-- print(nodes_parttwo.line_length)
-- print(line)
-- print("11637517422274862853338597396444961841755517295286")
