def nextMove(x, y, color, grid)
  # Find all groups of connected cells
  groups = []
  visited = Array.new(x) { Array.new(y, false) }
  (0...x).each do |i|
    (0...y).each do |j|
      next if visited[i][j] || grid[i][j] == '-'
      group = find_group(i, j, grid, visited)
      groups << group if group.size >= 2
    end
  end
  
  # If there are no groups, return the first non-empty cell
  if groups.empty?
    (0...x).each do |i|
      (0...y).each do |j|
        if grid[i][j] != '-'
          puts "#{i} #{j}"
          return
        end
      end
    end
  end

  # Define a recursive function to compute the Minimax score
  def minimax(grid, depth, color, x, y)
    # Check if we have reached the maximum depth or the game is over
    if depth.zero? || !groupsExist?(grid)
      return scoreGrid(grid, color)
    end

    # Determine the possible moves for the current player
    moves = []
    visited = Array.new(x) { Array.new(y, false) }
    (0...x).each do |i|
      (0...y).each do |j|
        next if visited[i][j] || grid[i][j] != color
        group = find_group(i, j, grid, visited)
        if group.size >= 2
          moves << group
        end
      end
    end

    # Evaluate each possible move and return the best score
    if color == 'r'
      best_score = -Float::INFINITY
      moves.each do |move|
        sim_grid = simulateMove(grid, move)
        score = minimax(sim_grid, depth - 1, 'g', x, y)
        best_score = [best_score, score].max
      end
    else
      best_score = Float::INFINITY
      moves.each do |move|
        sim_grid = simulateMove(grid, move)
        score = minimax(sim_grid, depth - 1, 'r', x, y)
        best_score = [best_score, score].min
      end
    end
    best_score
  end

   # Evaluate each possible move and choose the one with the best Minimax score
  if color == 'r'
    best_score = -Float::INFINITY
    best_move = nil
    groups.each do |group|
      sim_grid = simulateMove(grid, group)
      score = minimax(sim_grid, 3, 'g', x, y)
      if score > best_score
        best_score = score
        best_move = group
      end
    end
  else
    best_score = Float::INFINITY
    best_move = nil
    groups.each do |group|
      sim_grid = simulateMove(grid, group)
      score = minimax(sim_grid, 3, 'r', x, y)
      if score < best_score
        best_score = score
        best_move = group
      end
    end
  end

  # Return the first non-empty cell if no groups were found
  best_move ||= [[0, 0]]
  puts "#{best_move.first[0]} #{best_move.first[1]}"
end

def groupsExist?(grid)
  visited = Array.new(grid.size) { Array.new(grid[0].size, false) }
  (0...grid.size).each do |i|
    (0...grid[0].size).each do |j|
      next if visited[i][j] || grid[i][j] == '-'
      group = find_group(i, j, grid, visited)
      return true if group.size >= 2
    end
  end
  false
end


def game_over?(x, y, grid)
  # The game is over if there are no more groups of two or more cells
  groups = find_groups(x, y, grid)
  groups.all? { |group| group.size < 2 }
end

def evaluate(x, y, color, grid)
  # Calculate the score based on the number of cells and the number of groups
  groups = find_groups(x, y, grid)
  group_score = groups.count { |group| group.size >= 2 }
  cell_score = grid.flatten.count(color)
  group_score * 10 + cell_score
end

def find_groups(x, y, grid)
  # Find all groups of connected cells
  groups = []
  visited = Array.new(x) { Array.new(y, false) }
  (0...x).each do |i|
    (0...y).each do |j|
      next if visited[i][j] || grid[i][j] == '-'
      group = find_group(i, j, grid, visited)
      groups << group if group.size >= 2
    end
  end
  groups
end

def find_group(i, j, grid, visited)
  stack = [[i, j]]
  color = grid[i][j]
  group = []
  while stack.any?
    i, j = stack.pop
    next if i < 0 || j < 0 || i >= grid.size || j >= grid[0].size
    next if visited[i][j] || grid[i][j] != color
    visited[i][j] = true
    group << [i, j]
    stack << [i - 1, j]
    stack << [i + 1, j]
    stack << [i, j - 1]
    stack << [i, j + 1]
  end
  group
end

def simulateMove(grid, move)
  sim_grid = Marshal.load(Marshal.dump(grid))
  color = sim_grid[move[0][0]][move[0][1]]
  sim_grid[move[0][0]][move[0][1]] = '-'
  move[1..-1].each do |cell|
    sim_grid[cell[0]][cell[1]] = color
  end
  sim_grid
end

x,y,k = gets.strip.split.map { |i| i.to_i }

grid = Array.new(x)

(0...x).each do |i|
    grid[i] = gets.strip
end

nextMove(x, y, k, grid)