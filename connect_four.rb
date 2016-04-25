module ConnectFour
  
  # Represents a player info
  Player = Struct.new(:name, :color, :score)

  # Represents a Connect Four board
  class Board 
    # offsets for winning configurations
	WIN_CONFIGS_OFFSETS  = [ [[0, 0], [0, 1], [0, 2], [0, 3]],    # horizontal offset
	                                           [[0, 0], [1, 0], [2, 0], [3, 0]],    # vertical offset
											   [[0, 0], [1, 1], [2, 2], [3, 3]],    # upward diagonal offset
											   [[0, 0], [-1, 1], [-2, 2], [-3, 3]] # downward diagonal offset
											 ]
  
    attr_reader :rows, :cols
  
    def initialize(rows = 6, cols = 7, grid = nil)
	  @rows = rows
	  @cols = cols
	  @grid = grid.nil? ? Array.new(@cols) {[]} : grid
	end
	
	# Clear the board
	def clear
	  @grid.each { |col| col.clear }
	end
	
	# Check for the availability of a column
	def is_available?(pos)
	  col = to_col(pos)
	  return false if col.nil? || @grid[col].length >= @rows
	  true
	end
	
	# Set a colored disk in the given position
	def set_disk(pos, disk)
	  col = to_col(pos)
	  return false if col.nil? || @grid[col].length >= @rows
	  @grid[col] << disk
	  true
	end
	
	# Detect whether or not the board is empty
	def is_empty?
	  @grid.all? { |col| col.empty? }
	end
	
	# Detect whether or not the board is full
	def is_full?
	  @grid.all? { |col| col.length == @rows }
	end
	
	# Check for a winning condition
	def is_winner?(disk)
	  (0...@rows).each do |row|
	    (0...@cols).each do |col|
		  result = 
		    WIN_CONFIGS_OFFSETS.any? do |offset|
		      positions = offset.map { |pos| [row + pos[0], col + pos[1]] }
		      colors = positions.collect { |pos| ((0...@rows).include?(pos[0]) && (0...@cols).include?(pos[1])) ? @grid[pos[1]][pos[0]] : nil }
		      colors.count(disk) == 4
		    end
		  return true if result
		end
	  end
	  false
	end
	
	def print_board
	  col_separator, row_separator, row_tab = '|', '---+---+---+---+---+---+---', '  '
	  	  
	  label_for_disk = lambda do |row, col|
	    ' ' + (@grid[col][row].nil? ? ' ' : @grid[col][row].to_s) + ' '
	  end
	  
	  row_for_display = 
	    lambda{|row| row_tab + ((0...@cols).collect { |col| label_for_disk.call(row, col) }).join(col_separator)}
				
	  rows_for_display = (0...@rows).reverse_each.collect(&row_for_display)
	  
	  label_row = row_tab + (1..7).to_a.map { |label| ' ' + label.to_s + ' ' }.join(col_separator)
	  
	  puts
	  puts rows_for_display.join("\n  " + row_separator + "\n")
	  puts row_tab + row_separator + "\n"
	  puts label_row
	  puts "\n\n"
	  puts ('-' * 30)
	  puts "Each mark means:\n" \
           "  R: a red colored disk\n" \
		   "  Y: a yellow colored disk"
	  puts
	  
	end
	
	private
	
	# Translate a position between from [1 - cols] to a [0..cols -1] index
	def to_col(pos)
	  (1..@cols).include?(pos) ? pos - 1 : nil
	end
	
  end  
  
end

# Implements the game's logic
class CFGame
  
  def initialize
    @players = [Player.new("Player 1", :R, 0), Player.new("Player 2", :Y, 0)]
	@board = Board.new
	@cur_player = nil
	@rounds = 0
  end
  
  # Start playing the game
  def play
    @players.each { |player| player.score = 0 }
	  
	loop do
	  @board.clear
      @cur_player = @players[0]
	  @rounds += 1
		
	  print "\n******************* Connect Four ********************"
	  puts "\n#{@players[0].name} will play with #{@players[0].color}; #{@players[1].name} will play with #{@players[1].color}\n\n"
	  @board.print_board  
	    
	  loop do
        position = prompt_movement
	    @board.set_disk(position, @cur_player.color)
		@board.print_board  
		  
		result = 
		  if @board.is_winner?(@cur_player.color)
		    @cur_player.score += 1
		    puts "\n#{@cur_player.name} wins!!"
			true
		  elsif @board.is_full?
		    puts "\nThe game ended in a tie!"
			true
	    end
		  
		break if result
		swap_players
      end
		
	  break if prompt_quit
	end
	  
	print_final_score
  end
  
  private
  
  # Ask for a player's movement
  def prompt_movement
    mov = 0
	loop do
	  print "\n#{@cur_player.name}, choose your movement (1-7): "
	  mov = gets.chomp.to_i
	  if (1..7).include? mov
	    break if @board.is_available? mov
		  puts "That column is totally full! Try other choice..."  
	  else
		puts "Invalid choice! Try again.."  
	  end
	end
	mov  
  end
  
  # Ask for quitting the game
  def prompt_quit
    ans = ''
	loop do
	  print "\nDo you want to play another round (Y/N)? "
	  ans = gets.chomp.upcase
	  break if ['Y', 'N'].include? ans
	  puts "Invalid answer! Try again..."
	end
	ans == 'N'
  end
  
  def print_final_score
    puts "\n***** GAME OVER *****"
	puts "\nScores:"
	puts "\nRounds played: #{@rounds}"
	  
	acum_scores = 
	  @players.reduce(0) do |acum, player|
	    puts "#{player.name}: #{player.score} win#{player.score == 1 ? '' : 's'}\n"
		acum += player.score
	  end	  
	  
	puts "Tied games: #{@rounds - acum_scores}"
	puts "\n\n"
  end
  
  # Select the next player
  def swap_players
    @cur_player = @players.find { |player| player != @cur_player }
  end
end


