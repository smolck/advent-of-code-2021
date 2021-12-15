file = File.new("input.txt")
content = file.gets_to_end
file.close

class Position
  property x, y

  def initialize(@x : Int32, @y : Int32)
  end

  def clone()
    return Position.new(self.x, self.y)
  end
end

class Fold
  property around, is_x

  def initialize(@around : Int32, @is_x : Bool)
  end
end

dim_x = 0
dim_y = 0

positions = [] of Position
folds = [] of Fold

content.split('\n').each do |line|
  if line == ""
    next
  elsif !line.includes?(",")
    id, val = line.split()[2].split("=")
    folds << Fold.new(val.to_i, id == "x")

    next
  end

  x, y = line.split(',').map() { |x| x.to_i }
  positions << Position.new(x, y)

  if x > dim_x
    dim_x = x
  end

  if y > dim_y
    dim_y = y
  end
end

dim_y_copy = dim_y.clone
dim_x_copy = dim_x.clone
positions_copy = positions.clone

folds.each do |fold|
  needs_name = fold.is_x ? dim_x - fold.around : dim_y - fold.around

  if fold.is_x
    i = 0
    while i < positions.size
      if positions[i].x > fold.around
        positions[i].x = needs_name - (positions[i].x - fold.around)
      end

      if positions[i].x == fold.around
        positions.delete_at(i)
      end

      i += 1
    end

    dim_x = fold.around
  else
    i = 0

    while i < positions.size
      if positions[i].y > fold.around
        positions[i].y = needs_name - (positions[i].y - fold.around)
      end

      if positions[i].y == fold.around
        positions.delete_at(i)
      end

      i += 1
    end

    dim_y = fold.around
  end

  positions = positions.uniq() { |s| [s.x, s.y] }

  break
end

puts "Part one: #{positions.size}"

dim_y = dim_y_copy + 1
dim_x = dim_x_copy + 1
positions = positions_copy

array = Array(Array(String)).new(dim_y, Array.new(dim_x, "."))
array.each_with_index do |_, idx|
  array[idx] = array[idx].clone
end

positions.each do |p|
  array[p.y][p.x] = "#"
end

folds.each do |fold|
  if fold.is_x
    i = fold.around + 1
    other = fold.around - 1

    row = 0
    while row < array.size
      n = 0
      array[row][fold.around + 1..].reverse.each do |c|
        if c == "#"
          array[row][n] = "#"
        end

        n += 1
      end

      array[row] = array[row][0..fold.around - 1]
      row += 1
    end
  else
    i = fold.around + 1
    other = fold.around - 1

    while i < array.size
      array[i].each_with_index do |c, index|
        if c == "#"
          array[other][index] = "#"
        end
      end

      other -= 1
      i += 1
    end

    array = array[0..fold.around - 1]
  end
end

array.each do |line|
  puts line.join("")
end
