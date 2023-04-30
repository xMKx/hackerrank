require 'set'

def get_visible_maze(player_id)
  input = []
  3.times { input << gets.chomp }
  input
end

def next_move(player_id, visible_maze, current_position, moves)
  # Check for exit in adjacent cells
  adjacent_directions = {
    "UP" => [-1, 0],
    "DOWN" => [1, 0],
    "LEFT" => [0, -1],
    "RIGHT" => [0, 1],
  }

  exit_direction = adjacent_directions.find do |direction, (dx, dy)|
    row, col = current_position[0] + dx, current_position[1] + dy
    row >= 0 && col >= 0 && row < visible_maze.size && col < visible_maze[0].size && visible_maze[row][col] == 'e'
  end
  return exit_direction.first unless exit_direction.nil?

  # Check for exit in diagonal cells
  diagonal_directions = {
    "TOP_LEFT" => [-1, -1],
    "TOP_RIGHT" => [-1, 1],
    "BOTTOM_LEFT" => [1, -1],
    "BOTTOM_RIGHT" => [1, 1],
  }

  diagonal_exit = diagonal_directions.find do |direction, (dx, dy)|
    row, col = current_position[0] + dx, current_position[1] + dy
    row >= 0 && col >= 0 && row < visible_maze.size && col < visible_maze[0].size && visible_maze[row][col] == 'e'
  end

  unless diagonal_exit.nil?
    diagonal_direction, (exit_row, exit_col) = diagonal_exit
    case diagonal_direction
    when "TOP_LEFT"
      return "LEFT" if visible_maze[current_position[0] - 1][current_position[1]] == "#"
      return "UP"
    when "TOP_RIGHT"
      return "RIGHT" if visible_maze[current_position[0] - 1][current_position[1]] == "#"
      return "UP"
    when "BOTTOM_LEFT"
      return "LEFT" if visible_maze[current_position[0] + 1][current_position[1]] == "#"
      return "DOWN"
    when "BOTTOM_RIGHT"
      return "RIGHT" if visible_maze[current_position[0] + 1][current_position[1]] == "#"
      return "DOWN"
    end
  end

  # Hampton hedge maze method (left, forward, right)
  if visible_maze[current_position[0]][current_position[1] - 1] != "#" && visible_maze[current_position[0] + 1][current_position[1] - 1] == "#"
    return "LEFT"
  elsif visible_maze[current_position[0] - 1][current_position[1]] != "#"
    return "UP"
  elsif visible_maze[current_position[0]][current_position[1] + 1] != "#"
    return "RIGHT"
  else
    return "DOWN"
  end
end



player_id = gets.chomp.to_i
visible_maze = get_visible_maze(player_id)

current_position = [1, 1]

moves = {
  "UP" => [-1, 0],
  "DOWN" => [1, 0],
  "LEFT" => [0, -1],
  "RIGHT" => [0, 1],
}

next_direction = next_move(player_id, visible_maze, current_position, moves)

new_position = [current_position[0] + moves[next_direction][0], current_position[1] + moves[next_direction][1]]

puts next_direction
