MONTE_CARLO_TRIAL = 25

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

  # Evaluate each possible move and choose the one with the best score
  scores = []
  groups.each do |group|
    sim_grid = simulateMove(grid, group)
    score = evaluate(x, y, color, sim_grid)
    scores << [score, group]
  end

  # Order the moves by score and take the top 10%
  scores.sort_by! { |s| -s[0] }
  num_moves = (scores.size * 0.1).ceil
  top_moves = scores.take(num_moves).map { |s| s[1] }

  # Run simulations in parallel and choose the best move
  best_score = -Float::INFINITY
  best_move = nil
  top_moves.each do |move|
    sim_grid = simulateMove(grid, move)
    score = monteCarlo(sim_grid, color, MONTE_CARLO_TRIAL)
    if score > best_score
      best_score = score
      best_move = move
    end
  end

  # Return the first non-empty cell if no groups were found
  best_move ||= [[0, 0]]
  puts "#{best_move.first[0]} #{best_move.first[1]}"
end

def monteCarlo(grid, color, num_trials)
  # Simulate the specified number of trials and keep track of the score for each
  scores = []
  (0...num_trials).each do
    sim_grid = Marshal.load(Marshal.dump(grid))
    sim_color = color
    trial_score = 0
    while groupsExist?(sim_grid)
      move = simulateRandomMove(sim_grid, sim_color)
      break if move.nil? # Exit the loop if no valid move is found

      sim_grid = simulateMove(sim_grid, move)
      sim_color = sim_color == 'r' ? 'g' : 'r'
      trial_score += move.size - 1 # Add the score for removing the group
    end
    scores << trial_score
  end

  # Return the average score
  scores.sum / scores.size.to_f
end


def simulateRandomMove(grid, color)
  # Create a copy of the grid
  sim_grid = grid.map(&:dup)

  # Determine all groups of connected cells
  groups = find_groups(sim_grid.size, sim_grid[0].size, sim_grid)

  # Shuffle the groups randomly
  groups.shuffle!

  # Select the first group that can be removed without breaking any other groups
  groups.each do |group|
    # Simulate removing the group from the grid
    group.each { |cell| sim_grid[cell[0]][cell[1]] = '-' }

    # Check if the move breaks any other groups
    visited = Array.new(sim_grid.size) { Array.new(sim_grid[0].size, false) }
    groups_exist = groupsExist?(sim_grid)

    # If the move doesn't break any other groups, return the move
    if groups_exist
      return group
    end

    # Otherwise, undo the move and continue to the next group
    group.each { |cell| sim_grid[cell[0]][cell[1]] = grid[cell[0]][cell[1]] }
  end

  # If no valid move was found, return nil
  nil
end




def simulateRandomGame(x, y, color, grid)
  # Play a random game from the given position
  current_color = color
  max_moves = x * y
  num_moves = 0
  while !game_over?(x, y, grid) && num_moves < max_moves
    groups = find_groups(x, y, grid)
    if groups.any? { |group| group.size >= 2 && group[0][0] == 0 && group[0][1] == 0 }
      best_move = [[0, 0]]
    else
      best_move = groups.max_by { |group| group.size } || [[0, 0]]
    end
    sim_grid = simulateMove(grid, best_move)
    current_color = (current_color == 'r' ? 'g' : 'r')
    num_moves += 1
  end
  evaluate(x, y, color, grid)
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
  return grid if move.nil? || move.empty?

  sim_grid = Marshal.load(Marshal.dump(grid))
  color = sim_grid[move[0][0]][move[0][1]]
  sim_grid[move[0][0]][move[0][1]] = '-'
  move[1..-1].each do |cell|
    sim_grid[cell[0]][cell[1]] = color
  end
  sim_grid
end


x,y,color = gets.strip.split.map { |i| i.to_i }
color = color.to_i
colors = ['r', 'g', 'b', 'y', 'p', 'o', 'v']
color = colors[color - 1]
grid = Array.new(x)

(0...x).each do |i|
    grid[i] = gets.strip
end

nextMove(x, y, color, grid)