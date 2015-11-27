# Mastermind module
# Contains classes that implement a Mastermind game.
#
# Usage from irb:
# 1. $LOAD_PATH << "absolute_path_to_the_directory_containig_this_file"
# 2. require 'mastermind.rb'
# 3. include Mastermind
# 4. MMGame.new.play
# 
# Enjoy it!
module Mastermind

  # Represents a row of colored pegs (code pegs)
  class CodePegsRow
    # Code pegs symbols and associated color names
	@@color_symbols = 
	  {:R => "Red", :Y => "Yellow", :M => "Magenta", 
	   :G => "Green", :O => "Orange", :T => "Turquoise"}
	
    def initialize(size = 4)
	  @row = Array.new(size)
	end
	
	# Set a row of code pegs from other CodePegsRow object
	def set_pegs_from_row(other_row)
	  if other_row.is_a?(Array)
	    @row.replace(other_row)
      else		
		@row.replace(other_row.row)
	  end
	end
	
	# Set a row of pegs from a row expressed as a string
	def set_pegs_from_str(pegs_str)
	  @row.replace(pegs_str.split(//).map do |peg| 
	    @@color_symbols.include?(peg.to_sym) ? peg.to_sym : nil 
	  end)
	end
	
	# Compare to other row (represented as a CodePegsRow object) and produce a set of key pegs
	def compare_to_row(other_row)
	  temp_rows = @row.zip(other_row.is_a?(Array) ? other_row : other_row.row)
	  
	  # Detect code pegs of correct colors placed at correct positions ("B" key pegs)
	  temp_array = 
	    temp_rows.reduce([]) do |arr, pegs|
		  next arr if pegs[0] != pegs[1]
		  pegs[0] = nil
		  pegs[1] = nil
		  arr << :B
	    end
	  
	  temp_rows.keep_if { |pegs| pegs.count(nil) == 0 }
	  
	  # Detect code pegs of correct colors but at wrong positions ("W" key pegs)
	  temp_rows.reduce(temp_array) do |arr, pegs|
	    res = temp_rows.rassoc(pegs[0])
		next arr if res.nil?
		res[1] = nil
		arr << :W
	  end
	  
	  result = KeyPegsSet.new
	  result.add_black_pegs(temp_array.count(:B))
	  result.add_white_pegs(temp_array.count(:W))
	  result
	end
	
	# Compare to other row (represented as a string) and produce a set of key pegs
	def compare_to_str(pegs_str)
	  compare_to_row(pegs_str.split(//).map! { |peg| peg.to_sym })
	end
	
	# Detect whether or not the row is empty
	def is_empty?
	  @row.all? { |peg| peg.nil? }
	end
	
	# Clear the row
	def clear
	  @row.map! { |peg| peg = nil }
	end
	
	def size
	  @row.size
	end
	
	# Return the color symbols available for code pegs
	def self.color_symbols
	  @@color_symbols
	end
	
	def to_s
	  @row.join
	end
	
	protected
	
	attr_reader :row
  end
  
  # Represents a set of black/white pegs (key pegs)
  class KeyPegsSet    
    # Key pegs symbols and associated color names
	@@color_symbols = {:B => "Black", :W => "White"}
  
    def initialize
	  @set = Hash.new(0)
	  @@color_symbols.keys.each { |color| @set[color] = 0 }
	end
	
	# Add B/W pegs to the key pegs set
	def add_pegs(color, number = 1)
	  return if !@set.include?(color) || !((1..4).include? number)
	  @set[color] += number
	end
	
	# Add B (black) pegs to the set
	def add_black_pegs(number = 1)
	  add_pegs(:B, number)
	end
	
	# Add W (white) pegs to the set
	def add_white_pegs(number = 1)
	  add_pegs(:W, number)
	end
	
	# Detect whether or not the set is empty
	def is_empty?(color)
	  return true if !@set.include?(color)
	  @set[color] == 0
	end
	
	# Clear the set
	def clear
	  @set.each_key { |color| @set[color] = 0 }
	end
	
	# Return the color symbols available for key pegs
	def self.color_symbols
	  @@color_symbols
	end
	
	def to_s
	  @set.keys.reduce("") { |str, color| str << color.to_s * @set[color] }
	end
	
	protected
	
	attr_reader :set
  end
  
  # Represents a Mastermind board
  class Board
    MAX_ROWS = 12
  
	def initialize(num_rows = MAX_ROWS)
	  @num_rows = [8, 10, MAX_ROWS].include?(num_rows) ? num_rows : MAX_ROWS
	  @rows_played = []
	  @secret_code_row = CodePegsRow.new
	end
    
	# Set the secret code row from a CodePegsRow object
	def set_secret_code_row(code_row)
	  @secret_code_row.set_pegs_from_row(code_row)
	end
	
	# Return the secret code
	def get_secret_code
	  @secret_code_row.to_s
	end
	
	# Store a guess in the rows played log
	def set_guess_row(pegs_row)
	  @rows_played << [pegs_row.to_s, get_row_feedback(pegs_row)]
	end
	
	# Return the last row played stored in the log
	def get_last_guess_row
	  @rows_played[-1]
	end
	
	# Check for a winning condition
	def is_winner?
	  @rows_played[-1][1] == (:B.to_s) * (@rows_played[-1][0].size)
	end
	
	# Detect whether or not the board is empty
	def is_empty?
	  @rows_played.empty?
    end
	
	# Detect whether or not the board is full
	def is_full?
	  @rows_played.size == @num_rows
	end
	
	def print_board(show_code = false)
	  col_separator, row_separator, row_tab = '|', '------+--------+--------', '  '
	  
	  label_for_guess = lambda do |elem|
        row_tab + elem.to_s + row_tab
	  end
	  
      row_for_display = 
	    lambda{|row, idx| row_tab + ([sprintf("%2d",(idx + 1))] + row).map(&label_for_guess).join(col_separator)}
			    
	  puts 
	  puts (row_tab * 2)+ ('-' * 20)
      puts (row_tab * 3) + "Secret Code: #{show_code ? @secret_code_row.to_s : '?' * @secret_code_row.size}"
	  puts (row_tab * 2) + ('-' * 20)
	  puts (row_tab * 2) + ["Row", "Code", " Keys"].join(row_tab * 2) 
	   
      rows_for_display = @rows_played.each_with_index.map(&row_for_display)
	  puts
	  puts rows_for_display.join("\n  " + row_separator + "\n")
	  puts "\n\n"
	  puts ('-' * 34)
	  puts "Each key peg means:\n" \
           "  B: a code peg is correct in both color and position\n" \
		   "  W: a code peg has only the right color"
	  puts
	end
  
    # Clear the board
    def clear
	  @rows_played.clear
	  @secret_code_row.clear
	end
  
    private
	
	# Obtain the feedback for a guess row
	def get_row_feedback(pegs_row)
	  @secret_code_row.compare_to_row(pegs_row).to_s
	end
  end
  
  # Represents a player info
  class Player
    attr_reader :name
	attr_accessor :score
  
    def initialize(name = "None")
	  @name = name
	  @score = {:codebreaker => 0, :codemaker => 0}
	end
	
	def reset_score
	  @score[:codebreaker] = 0
	  @score[:codemaker] = 0
	end
  
    # Set a secret code row
    def get_secret_code; end
	
	# Make a guess row
	def make_guess; end
	
	def clear_guess_codes; end
  end
  
  # Represents a human player
  class HumanPlayer < Player
    def initialize(name = "Person")
	  super(name)
	end
	
	def get_secret_code(size = 4)  
	  puts "\n*** Input the secret code row ***"
	  prompt_code(size).split(//).map { |peg| peg.to_sym }
	end
	
	def make_guess(last_row)
	  puts "\n*** Make a guess ***"
	  prompt_code(last_row[0].size)
	end
	
	private
	
	# Ask for a code row
	def prompt_code(size)
	  colors = CodePegsRow.color_symbols.map { |color| color.join('=') }.join(', ')
	  puts "Enter a row of #{size} letters corresponding to each color peg;"
      puts "repeated colors are allowed (i.e., RGMY, TOTR)"
	  puts "Available colors: #{colors}"
	  puts
	  
	  code = ''
	  loop do
	    print "#{@name}, set your code: "
	    code = gets.upcase.chomp
		break if validate_code(code, size)
		puts "Invalid choice! Try again.."  
		puts
	  end
	  code
	end
	
	def validate_code(code, size) 
	  return false if code.size != size
	  code.split(//).reduce(true) { |value, peg| value &= CodePegsRow.color_symbols.include?(peg.to_sym) }
	end
  end
  
  # Represents a computer player
  class ComputerPlayer < Player
    @@full_rows_set = CodePegsRow::color_symbols.keys.repeated_permutation(4).to_a
  
    def initialize(name = "Computer")
	  super(name)
	  init_codes_ws
	  @guess_strategy = method(:smart_strategy)  # use a smart guessing strategy
	end
	
	def get_secret_code(size = 4)  
	  code = []
	  size.times { |_| code << CodePegsRow::color_symbols.keys.shuffle.sample }
	  code
	end
	
	def make_guess(last_row)   
	  @guess_strategy.call(last_row)  # calls the selected guessing strategy
	end
	
	def clear_guess_codes
	  init_codes_ws
	end
	
	private
	
	def init_codes_ws
	  @codes_ws = @@full_rows_set.dup
	end
	
	def dumb_strategy(last_row)
	  'RGYT'
	end
	
	def random_strategy(last_row)
	  code = []
	  last_row[0].size.times { |_| code << CodePegsRow::color_symbols.keys.shuffle.sample }
	  code.join
	end
	
	def smart_strategy(last_row)
	  return random_strategy(last_row) if last_row[0] == ([nil] * last_row[0].size)
	  
	  update_working_set(last_row[0], last_row[1])
	  @codes_ws.sample.join
	end
	
	def update_working_set(row, keys)
	  row_array = row.split(//).map { |peg| peg.to_sym }
	  keys_array = keys.split(//).map { |key| key.to_sym }
	  
	  if keys.empty?
	    # delete any code including code pegs not awarded
	    @codes_ws.delete_if do |code|  
		  code.any? { |peg| row_array.include?(peg) }
		end
	  else
	    @codes_ws.delete(row_array)
		
		# update for W key pegs
		if keys_array.include?(:W)
		  @codes_ws.keep_if do |code|
		    keys_array.count(:W) <= 
		      code.each_with_index.reduce(0) { |acum, elem| row_array.include?(elem[0]) ? acum += 1 : acum }
		  end
		end
		
		# update for B key pegs
		if keys_array.include?(:B)
	      @codes_ws.keep_if do |code|
		    keys_array.count(:B) <= 
		      code.each_with_index.reduce(0) { |acum, elem| elem[0] == row_array[elem[1]] ? acum += 1 : acum }
		  end
		end
				
	  end
	end
  end
    
  # Implements the game's logic
  class MMGame
	MAX_GUESSES = 12
	
	def initialize
	  @human_player = HumanPlayer.new("Player 1")
	  @cpu_player = ComputerPlayer.new("CPU")
	  @code_maker = nil
	  @code_breaker = nil
	  
	  @board = Board.new
	  @guess_row = CodePegsRow.new
	  @rounds = 0
	end
  
    # Start playing the game
    def play
	  @human_player.reset_score
	  @cpu_player.reset_score
	  @rounds = 0
	  
	  loop do
	    @board.clear
		@rounds += 1
		
		puts "\n*************************  Mastermind  ***************************\n"
		
		@code_breaker, @code_maker = prompt_player_type
		
		@board.set_secret_code_row(@code_maker.get_secret_code)
		code_size = @board.get_secret_code.size
		@code_breaker.clear_guess_codes
		#p @board.get_secret_code  
		
		puts "\n#{@code_breaker.name} will play as the Codebreaker; #{@code_maker.name} will be the Codemaker\n\n"  
		@board.print_board
		
		num_guesses = 0
		win = false
		
		while !win && num_guesses < MAX_GUESSES
		  last_row = @board.get_last_guess_row
		  last_row ||= [Array.new(code_size), []]
		  		  		
		  @guess_row.set_pegs_from_str(@code_breaker.make_guess(last_row))
		  @board.set_guess_row(@guess_row)
		  
		  win = @board.is_winner?
		  @board.print_board(win)  
		  
		  num_guesses += 1
		end
		
		if win
		  @code_breaker.score[:codebreaker] += 1
		  puts "\nThe code was guessed in #{num_guesses} tr#{num_guesses == 1 ? 'y' : 'ies'}..."
		  puts "#{@code_breaker.name} wins!!!"
	    else
		  @code_maker.score[:codemaker] += 1
		  puts "\nThe Codebreaker could not guess the code in the maximum number of tries..."
		  puts "The secret code was: #{@board.get_secret_code}"  
		  puts "#{@code_breaker.name} loses, #{@code_maker.name} wins!" 
		end
		
		break if prompt_quit
	  end
	  
	  print_final_score
	end
	
	private
	
	# Ask for the type of player
	def prompt_player_type
	  player_types = [@human_player, @cpu_player]
	  loop do
	    puts "\nPlay the game as:\n\n[1] Codebreaker\n[2] Codemaker\n\n"
		print "Select your choice (1-2): "
	    choice = gets.chomp.to_i
		if (1..2).include? choice
		  player_types.rotate! if choice == 2  
		  break
		else
		  puts "Invalid choice! Try again.."  
		end
	  end
	  player_types
	end
	
	# Ask for quitting the game
	def prompt_quit
	  ans = ''
	  loop do
	    print "\nDo you want to play again (Y/N)? "
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
	  
	  puts "\n** #{@human_player.name} **"
	  puts "   #{@human_player.score[:codebreaker]} win#{@human_player.score[:codebreaker] == 1 ? '' : 's'} as a Codebreaker" 
	  puts "   #{@human_player.score[:codemaker]} win#{@human_player.score[:codemaker] == 1 ? '' : 's'} as a Codemaker" 
	  puts "\n** #{@cpu_player.name} **"
	  puts "   #{@cpu_player.score[:codebreaker]} win#{@cpu_player.score[:codebreaker] == 1 ? '' : 's'} as a Codebreaker" 
	  puts "   #{@cpu_player.score[:codemaker]} win#{@cpu_player.score[:codemaker] == 1 ? '' : 's'} as a Codemaker" 
	  	  	  
	  puts "\n\n"
	end
	
  end
end
