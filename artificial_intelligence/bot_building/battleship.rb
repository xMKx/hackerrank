def attack_adjacent(h_location, battlefield)
  row, col = h_location

  # Check if there are any connecting h-s
  [[-1, 0], [1, 0], [0, -1], [0, 1]].each do |direction|
    r, c = row + direction[0], col + direction[1]

    while r.between?(0, 9) && c.between?(0, 9)
      if battlefield[r][c] == '-'
        return [r, c]
      elsif battlefield[r][c] == 'h'
        r += direction[0]
        c += direction[1]
      else
        break
      end
    end
  end

  nil
end

def is_on_edge(row, col)
  if (row == 0 && col.between?(1, 8)) || (row == 9 && col.between?(1, 8)) ||
     (col == 0 && row.between?(1, 8)) || (col == 9 && row.between?(1, 8))
    return 1  # edge
  elsif (row == 0 && col == 0) || (row == 0 && col == 9) ||
        (row == 9 && col == 0) || (row == 9 && col == 9)
    return 2  # corner
  else
    return 0  # not on edge or corner
  end
end

def calculate_probability_density(battlefield, ship_sizes, hits)
  probability_grid = Array.new(10) { Array.new(10, 0) }
	
	shuffled_positions = (0...10).to_a.product((0...10).to_a).shuffle

  ship_sizes.each do |ship_size|
		 shuffled_positions.each do |position|
		 row, col = position
			valid_horizontal_placement = true
			valid_vertical_placement = true

			(0...ship_size).each do |offset|
				if row.between?(0, 9) && (col + offset).between?(0, 9)
					if hits.any? && !hits.include?([row, col + offset])
						valid_horizontal_placement = false
					end
					if battlefield[row][col + offset] != '-'
						valid_horizontal_placement = false
					end
					if is_on_edge(row, col + offset)
						# Checkers approach for the edges
						if row.even?
							probability_grid[row][col + offset] += 2 if (col + offset).even?
						else
							probability_grid[row][col + offset] += 2 if (col + offset).odd?
						end
					else
						probability_grid[row][col + offset] += 1
					end
				else
					valid_horizontal_placement = false
				end

				if (row + offset).between?(0, 9) && col.between?(0, 9)
					if hits.any? && !hits.include?([row + offset, col])
						valid_vertical_placement = false
					end
					if battlefield[row + offset][col] != '-'
						valid_vertical_placement = false
					end
					if is_on_edge(row + offset, col)
						# Checkers approach for the edges
						if col.even?
							probability_grid[row + offset][col] += 2 if (row + offset).even?
						else
							probability_grid[row + offset][col] += 2 if (row + offset).odd?
						end
					else
						probability_grid[row + offset][col] += 1
					end
				else
					valid_vertical_placement = false
				end
			end

			if valid_horizontal_placement
				(0...ship_size).each do |offset|
					probability_grid[row][col + offset] += 1
				end
			end

			if valid_vertical_placement
				(0...ship_size).each do |offset|
					probability_grid[row + offset][col] += 1
				end
			end
		end
  end

  probability_grid[0][0] += 3
  probability_grid[0][9] += 3
  probability_grid[9][0] += 3
  probability_grid[9][9] += 3

  probability_grid
end

def find_next_target(battlefield, remaining_ship_sizes)
  hits = []
  battlefield.each_with_index do |row, r|
    row.each_with_index do |cell, c|
      hits << [r, c] if cell == 'h'
    end
  end

  probability_grid = calculate_probability_density(battlefield, remaining_ship_sizes, hits)
  max_probability = probability_grid.map(&:max).max

  target_row, target_col = nil, nil
  max_probability_found = -1
  probability_grid.each_with_index do |row, r|
    row.each_with_index do |probability, c|
      if probability >= max_probability_found && battlefield[r][c] == '-'
        target_row, target_col = r, c
        max_probability_found = probability
      end
    end
  end

  [target_row, target_col]
end



# Add the remaining_ship_sizes parameter to the minimum_moves_to_sink_all_ships function
def minimum_moves_to_sink_all_ships(battlefield, remaining_ship_sizes)
  h_location = nil
  battlefield.each_with_index do |sublist, i|
    sublist.each_with_index do |element, j|
      if element == 'h'
        h_location = [i, j]
        break
      end
    end
    break if h_location
  end

  if !h_location.nil?
    attack = attack_adjacent(h_location, battlefield)
    return attack if attack
  end

  find_next_target(battlefield, remaining_ship_sizes)
end

def update_remaining_ship_sizes(battlefield)
  remaining_ship_sizes = [1, 1, 2, 2, 3, 4, 5]
  ship_sizes_count = Hash.new(0)

  # Count the number of 'd' characters in each ship
  battlefield.each_with_index do |row, r|
    row.each_with_index do |cell, c|
      if cell == 'd'
        # Check horizontal ships
        if c < 9 && battlefield[r][c + 1] == 'd'
          ship_size = 2
          while c + ship_size < 10 && battlefield[r][c + ship_size] == 'd'
            ship_size += 1
          end
          ship_sizes_count[ship_size] += 1

          # Mark the counted ship cells as visited
          (0...ship_size).each do |offset|
            battlefield[r][c + offset] = 'x'
          end
        # Check vertical ships
        elsif r < 9 && battlefield[r + 1][c] == 'd'
          ship_size = 2
          while r + ship_size < 10 && battlefield[r + ship_size][c] == 'd'
            ship_size += 1
          end
          ship_sizes_count[ship_size] += 1

          # Mark the counted ship cells as visited
          (0...ship_size).each do |offset|
            battlefield[r + offset][c] = 'x'
          end
        # Single-cell ships
        else
          ship_sizes_count[1] += 1
          battlefield[r][c] = 'x'
        end
      end
    end
  end

  # Update remaining_ship_sizes based on the counted ship sizes
  ship_sizes_count.each do |size, count|
    count.times { remaining_ship_sizes.delete_at(remaining_ship_sizes.index(size)) }
  end

  remaining_ship_sizes
end

def find_first_free_cell(battlefield)
  r,c = 0
  found = false
  battlefield.each_with_index do |sublist, i|
    sublist.each_with_index do |element, j|
      if element == '-'
        r = i
        c = j
        found = true
        break
      end
    end
    break if found
  end
  return r,c
end

def place_ships_randomly
  ship_quantities = { 1 => 2, 2 => 2, 3 => 1, 4 => 1, 5 => 1 }
  ship_coordinates = Hash.new { |h, k| h[k] = [] }

  ship_quantities.each do |ship_type, quantity|
    quantity.times do
      loop do
        row, col = rand(10), rand(10)
        direction = rand(2) # 0 for horizontal, 1 for vertical
				
        if direction == 0 && col + ship_type <= 10 ||
           direction == 1 && row + ship_type <= 10

          overlap = false
          (0...ship_type).each do |offset|
            current_coord = direction == 0 ? [row, col + offset] : [row + offset, col]
            ship_coordinates.each_value do |ship_coords|
							ship_coords.each do |coord_pair|
								coord_pair.each do |coord|
									if (coord[0] - current_coord[0]).abs <= 1 && (coord[1] - current_coord[1]).abs <= 1
										overlap = true
										break
									end
								end
								break if overlap
							end
							break if overlap
						end

            break if overlap
          end

          unless overlap
            start_coord = [row, col]
            end_coord = ship_type == 1 ? nil : (direction == 0 ? [row, col + ship_type - 1] : [row + ship_type - 1, col])
            ship_coordinates[ship_type] << [start_coord, end_coord].compact
            break
          end
        end
      end
    end
  end

  ship_coordinates
end


def print_ship_coordinates(ship_coordinates)
  ship_coordinates.sort.each do |ship_type, coordinates|
    coordinates.each do |coord_pair|
      if ship_type == 1
        puts "#{coord_pair[0].join(' ')}"
      else
        puts "#{coord_pair[0].join(' ')}:#{coord_pair[1].join(' ')}"
      end
    end
  end
end


n = gets.strip

if n == "INIT"
	ship_coordinates = place_ships_randomly
	print_ship_coordinates(ship_coordinates)
else

	battlefield = []
	n.to_i.times { battlefield << gets.chomp }

	battlefield.map! { |cell| cell.split('') }

	remaining_ship_sizes = update_remaining_ship_sizes(battlefield)

	attack_r, attack_c = minimum_moves_to_sink_all_ships(battlefield, remaining_ship_sizes)

	#attack_r, attack_c = find_first_free_cell(battlefield) if attack_r.nil?
			

	puts "#{attack_r} #{attack_c}"
end
