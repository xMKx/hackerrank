#!/usr/bin/ruby

def compare_and_update_boards(current_board, new_board, posr, posc)
  result = current_board
  #result.each {|row| row.gsub!(/b/, '-')}
  (0...5).each do |i|
      (0...5).each do |j|
          result[i][j] = new_board[i][j] if current_board[i][j] == 'o' || current_board[i][j] == 'b'
          result[i][j] = new_board[i][j] if current_board[i][j] == 'd' && new_board[i][j] != 'o'
      end
  end
  result
end

def manhattan_distance(x1, y1, x2, y2)
  (x1 - x2).abs + (y1 - y2).abs
end

def next_move posr, posc, board
    move = ""
    bot_pos = [posr, posc]
    dirty_cell_pos = nil
    moves = ["UP", "RIGHT", "LEFT", "DOWN"]
    
    # Look for visible dirty cells
    min_distance = Float::INFINITY
    (0...5).each do |i|
      (0...5).each do |j|
        if board[i][j] == "d"
          distance = manhattan_distance(bot_pos[0], bot_pos[1], i, j)
          if distance < min_distance
            min_distance = distance
            dirty_cell_pos = [i, j]
          end
        end
      end
    end
    
    # If no visible dirty cell, move in circles
    if dirty_cell_pos.nil?
      if bot_pos == [1,1]
        move = "DOWN"
      elsif bot_pos == [3,1]
        move = "RIGHT"
      elsif bot_pos == [3,3]
        move = "UP"
      elsif bot_pos == [1,3]
        move = "LEFT"
      elsif bot_pos == [2,1]
        move = "DOWN"
      elsif bot_pos == [3,2]
        move = "RIGHT"
      elsif bot_pos == [2,3]
        move = "UP"
      elsif bot_pos == [1,2]
        move = "LEFT"
      else
        dirty_cell_pos = [2,2]
      end
    end
    
    # Move towards the nearest dirty cell
    if move == ""
      move = "CLEAN" if dirty_cell_pos == bot_pos
      move = "UP" if bot_pos[0] > dirty_cell_pos[0]
      move = "DOWN" if bot_pos[0] < dirty_cell_pos[0]
      move = "LEFT" if bot_pos[1] > dirty_cell_pos[1]
      move = "RIGHT" if bot_pos[1] < dirty_cell_pos[1]

    end
    
    
    
    move
end

pos = gets.split.map {|i| i.to_i}
board = Array.new(5)

(0...5).each do |i|
    board[i] = gets.strip
end

board_file = "board.txt"

board_from_file = File.read(board_file).split("\n") if File.exist?(board_file)

if board_from_file.nil?
    File.write(board_file, board.join("\n"))
    board_from_file = board
else
    board_from_file = compare_and_update_boards(board_from_file, board, pos[0], pos[1])
    File.write(board_file, board_from_file.join("\n"))
end


puts next_move pos[0], pos[1], board_from_file
