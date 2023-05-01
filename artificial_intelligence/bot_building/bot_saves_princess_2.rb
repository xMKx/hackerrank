#!/bin/ruby

def manhattan_distance(x1, y1, x2, y2)
  (x1 - x2).abs + (y1 - y2).abs
end

def next_move(m, board, posr, posc)
    move = ""
    bot_pos = [posr, posc]
    princess_pos = nil

    closest_cell = nil
    min_distance = Float::INFINITY
    (0...m).each do |i|
      (0...m).each do |j|
        if board[i][j] == "p"
          distance = manhattan_distance(bot_pos[0], bot_pos[1], i, j)
          if distance < min_distance
            min_distance = distance
            closest_cell = [i, j]
          end
        end
      end
    end
    princess_pos = closest_cell

    move = "UP" if bot_pos[0] > princess_pos[0]
    move = "DOWN" if bot_pos[0] < princess_pos[0]
    move = "LEFT" if bot_pos[1] > princess_pos[1]
    move = "RIGHT" if bot_pos[1] < princess_pos[1]
    puts move
end

m = gets.to_i
r,c = gets.split.map {|i| i.to_i }

grid = Array.new(m)

(0...m).each do |i|
    grid[i] = gets.strip
end

next_move(m,grid,r,c)
