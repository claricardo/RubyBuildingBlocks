# TicTacToe module
# Contains classes that implement a Tic-Tac-Toe game.
#
# Usage from irb:
# 1. $LOAD_PATH << "absolute_path_to_the_directory_containig_this_file"
# 2. require 'tic_tac_toe.rb'
# 3. include TicTacToe
# 4. TTTGame.new.play
# 
# Enjoy it!
module TicTacToe

  # Represents a player info
  Player = Struct.new(:name, :mark, :score)
  
  # Represents a Tic-Tac-Toe board
  class Board
    # Winning configurations
	WIN_CONFIGS = [[1, 2, 3], [4, 5, 6], [7, 8, 9], 
				   [1, 4, 7], [2, 5, 8], [3, 6, 9],
				   [1, 5, 9], [3, 5, 7]]
	
	attr_reader :rows, :cols
	
	def initialize(rows = 3, cols = 3, grid = nil)
	  @rows = rows
	  @cols = cols
	  @grid = grid.nil? ? init_grid : grid
	end
    
	# Set a mark in the given position
	def set_mark(pos, mark)
	  row, col = to_row_col(pos)
	  return if row.nil? || col.nil?
	  @grid[row][col] = mark
	end
	
	# Check for the availability of a cell
	def is_cell_available?(pos)
	  row, col = to_row_col(pos)
	  return false if row.nil? || col.nil?
	  @grid[row][col].empty?
	end
	
	# Detect whether or not the board is empty
	def is_empty?
	  @grid.flatten.all? { |elem| elem.empty? }
	end
	
	# Detect whether or not the board is full
	def is_full?
	  @grid.flatten.all? { |elem| !elem.empty? }
	end
	
	# Check for a winning condition
	def is_winner?(mark)
	  WIN_CONFIGS.any? do |line|
	    line.all? do |elem|
		  row, col = to_row_col(elem)
		  @grid[row][col] == mark unless (row.nil? || col.nil?)
		end
	  end
	end
	
	def print_board
	  col_separator, row_separator, row_tab = '|', '---+---+---', '  '
	  row_positions = [[1,2,3], [4,5,6], [7,8,9]]
	  
	  label_for_position = lambda do |position| 
	    row, col = to_row_col(position)
		' ' + (@grid[row][col].empty? ? position : @grid[row][col]).to_s + ' '
	  end
	  
      row_for_display = lambda{|row| row_tab + row.map(&label_for_position).join(col_separator)}
      
      rows_for_display = row_positions.map(&row_for_display)
	  puts
	  puts rows_for_display.join("\n  " + row_separator + "\n")
	  puts
	end
  
    # Clear the board
    def clear
	  @grid.each do |row| 
	    row.map! { |col| col = '' }
	  end 
	end
  
    private
	
	def init_grid
	  @grid = Array.new(@rows, [])
	  @grid.map! {|row| Array.new(@cols, '')}
	end
	
	# Translate a cell position between from [1 - 9] to a [row][col] index
	def to_row_col(pos)
	  row = (pos - 1) / @cols
	  row = ((0...@rows).include? row) ? row : nil 
	  col = (pos - 1) % @cols
	  col = ((0...@cols).include? col) ? col : nil
	  [row, col]
	end
  end
  
  # Implements the game's logic
  class TTTGame
	
	def initialize
	  @players = [Player.new("Player 1", :X, 0), Player.new("Player 2", :O, 0)]
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
		
		print "\n******************* Tic-Tac-Toe ********************"
	    puts "\n#{@players[0].name} will play with #{@players[0].mark}; #{@players[1].name} will play with #{@players[1].mark}\n\n"
		@board.print_board  
	    
		loop do
          position = prompt_movement
	      @board.set_mark(position, @cur_player.mark)
		  @board.print_board  
		  
		  result = 
		    if @board.is_winner?(@cur_player.mark)
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
	    print "\n#{@cur_player.name}, choose your movement (1-9): "
	    mov = gets.chomp.to_i
		if (1..9).include? mov
		  break if @board.is_cell_available? mov
		  puts "That cell is already taken! Try other choice..."  
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
end

