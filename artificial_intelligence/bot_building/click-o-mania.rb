#!/bin/ruby

def nextMove(x, y, color, grid)
  # Find all groups of connected cells
  groups = []
  visited = Array.new(x) { Array.new(y, false) }
  (0...x).each do |i|
    (0...y).each do |j|
      next if visited[i][j] || grid[i][j] == '-'
      group = findGroup(i, j, grid, visited)
      groups << group if group.size >= 2
    end
  end
  
  puts "Found groups: #{groups}"
  
  # Score each group and choose the best one
  best_score = -1
  best_group = nil
  groups.each do |group|
    score = scoreGroup(group, grid)
    puts "Group #{group} score: #{score}"
    if score > best_score
      best_score = score
      best_group = group
    end
  end

  puts "Best group: #{best_group} score: #{best_score}"
  
  # If there are no groups, return the first non-empty cell
  if best_group.nil?
    (0...x).each do |i|
      (0...y).each do |j|
        if grid[i][j] != '-'
          puts "#{i} #{j}"
          return
        end
      end
    end
  end
  
  # Return any cell in the best group
  puts "#{best_group.first[0]} #{best_group.first[1]}"
end

def findGroup(i, j, grid, visited)
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

def scoreGroup(group, grid)
  sim_grid = grid.map(&:dup)
  group.each { |cell| sim_grid[cell[0]][cell[1]] = '-' }
  sim_grid = simulateFalling(sim_grid)
  empty_spaces = sim_grid.flatten.count('-')
  empty_spaces_proportion = empty_spaces.to_f / (grid.size * grid[0].size)
  group.size * (1.0 - empty_spaces_proportion)
end

def simulateFalling(grid)
  # Move blocks down to fill empty spaces
  (0...grid[0].size).each do |j|
    (0...grid.size).reverse_each do |i|
      next if grid[i][j] != '-'
      k = i
      while k >= 0 && grid[k][j] == '-'
        k -= 1
      end
      if k >= 0
        grid[i][j] = grid[k][j]
        grid[k][j] = '-'
      end
    end
  end

  # Remove empty columns by sliding succeeding columns left
  empty_column_count = 0
  (0...grid[0].size).each do |j|
    if grid.all? { |row| row[j] == '-' }
      empty_column_count += 1
    else
      if empty_column_count > 0
        (0...grid.size).each do |i|
          grid[i][j - empty_column_count] = grid[i][j]
          grid[i][j] = '-'
        end
      end
    end
  end

  grid
end





x,y,k = gets.strip.split.map { |i| i.to_i }

grid = Array.new(x)

(0...x).each do |i|
    grid[i] = gets.strip
end

nextMove(x, y, k, grid)
