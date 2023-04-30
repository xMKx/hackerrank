#!/bin/ruby

def displayPathtoPrincess(n,grid)
   bot_pos = [n/2, n/2] # start at center of grid
  princess_pos = nil

  # find princess position
  (0...n).each do |i|
    (0...n).each do |j|
      if grid[i][j] == 'p'
        princess_pos = [i, j]
        break
      end
    end
    break if princess_pos
  end

  # calculate moves to reach princess
  moves = []
  while bot_pos != princess_pos
    if bot_pos[0] > princess_pos[0]
      bot_pos[0] -= 1
      moves << 'UP'
    elsif bot_pos[0] < princess_pos[0]
      bot_pos[0] += 1
      moves << 'DOWN'
    end

    if bot_pos[1] > princess_pos[1]
      bot_pos[1] -= 1
      moves << 'LEFT'
    elsif bot_pos[1] < princess_pos[1]
      bot_pos[1] += 1
      moves << 'RIGHT'
    end
  end

  # print moves
  puts moves.join("\n")
end

m = gets.to_i

grid = Array.new(m)

(0...m).each do |i|
    grid[i] = gets.strip
end

displayPathtoPrincess(m,grid)
