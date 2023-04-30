#!/usr/bin/ruby
def manhattan_distance(x1, y1, x2, y2)
  (x1 - x2).abs + (y1 - y2).abs
end

def next_move posr, posc, dimh, dimw, board
  move = ""
    bot_pos = [posr, posc]
    dirty_cell_pos = nil

    closest_cell = nil
    min_distance = Float::INFINITY
    (0...dimh).each do |i|
      (0...dimw).each do |j|
        if board[i][j] == "d"
          distance = manhattan_distance(bot_pos[0], bot_pos[1], i, j)
          if distance < min_distance
            min_distance = distance
            closest_cell = [i, j]
          end
        end
      end
    end
    dirty_cell_pos = closest_cell
    
    move = "CLEAN" if dirty_cell_pos == bot_pos
    move = "UP" if bot_pos[0] > dirty_cell_pos[0]
    move = "DOWN" if bot_pos[0] < dirty_cell_pos[0]
    move = "LEFT" if bot_pos[1] > dirty_cell_pos[1]
    move = "RIGHT" if bot_pos[1] < dirty_cell_pos[1]
    move
end

pos = gets.split.map {|i| i.to_i}
dim = gets.split.map {|i| i.to_i}
board = Array.new(dim[0])

(0...dim[0]).each do |i|
    board[i] = gets.strip
end

puts next_move pos[0], pos[1], dim[0], dim[1], board
