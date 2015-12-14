# Hangman module
# Contains classes that implement a Hangman game.
#
# NOTE: You must download hangman.rb and dictio_5desk.txt files and put them in the same directory.
#
# Run from the command line:
# ruby hangman.rb
#
# or
#
# Usage from irb:
# 1. $LOAD_PATH << "absolute_path_to_the_directory_containing_this_file"
# 2. Dir::chdir("absolute_path_to_the_directory_containing dictio_5desk.txt")
# 3. require 'hangman.rb'
# 4. Hangman::HangmanGame.new.play
# 
# Enjoy it!

require 'yaml'

module Hangman

  # Represents a player info
  Player = Struct.new(:name, :wins, :loses)
  
  # Represents a Hangman board
  class Board
    DICTIO_FILENAME = "./dictio_5desk.txt"  
    MAX_GUESSES = 7
	LETTER_PLACE_HOLDER = '_'
    
	def initialize()
	  @letters_missed = []
	  @word_holder = []
	  @secret_word = ''
	  @dictio_words = load_words(DICTIO_FILENAME)
	end
    
	# Select a new secret word from the dictionary
	def select_secret_word
	  @secret_word = @dictio_words.sample
	  @word_holder = Array.new(@secret_word.size, LETTER_PLACE_HOLDER)
	end
	
	def get_secret_word
	  @secret_word
	end
	
	# Try to guess a letter 
	def set_guess(letter)
	  if !@secret_word.include?(letter)
	    @letters_missed << letter if !@letters_missed.include?(letter)
	  elsif !@word_holder.include?(letter)
	    @secret_word.split('').each_with_index do |ltr, idx|
	      @word_holder[idx] = ltr.upcase if ltr == letter
	    end
	  end
	end
	
	# Check for the availability of a letter
	def is_letter_available?(letter)
	  !@letters_missed.include?(letter)
	end
	
	# Detect whether or not the board is empty
	def is_empty?
	  @word_holder.count(LETTER_PLACE_HOLDER) == @secret_word.size
	end
	
	# Detect whether or not the board is full
	def is_full?
	  @word_holder.count(LETTER_PLACE_HOLDER) == 0
	end
	
	# Check for a winning condition
	def is_winner?
	  @word_holder.join.downcase == @secret_word
	end
	
	# Check for a losing condition
	def is_hanged?
	  (MAX_GUESSES - @letters_missed.size) == 0
	end
	
	def print_board
	  separator, top_piece, bottom_piece, post_piece = " ", "┌───┐", "─┴─────", "│"
	  body_tab = separator * 3
	  member_tab = separator * 2 
	  stick_figure = ["O", "│", "/", "\\", "/", "\\", "|"]
	  	  
	  rem_guesses = MAX_GUESSES - @letters_missed.size
	  
	  gallows_post = lambda do |piece, idx| 
	    body_part = 
	      case idx
		  when 0
		    (body_tab + stick_figure[-1]) if rem_guesses == 0
		  when 1
		    (body_tab + stick_figure[0]) if rem_guesses < MAX_GUESSES
		  when 2
		    if rem_guesses < MAX_GUESSES - 1
		      member_tab + 
			    (rem_guesses <= 4 ? stick_figure[2] : ' ') +
			    stick_figure[1] +
			    (stick_figure[3] if rem_guesses <= 3).to_s
		    end
		  when 3
		    if rem_guesses <= 2
		      member_tab + stick_figure[4] +
			    ((' ' + stick_figure[5]) if rem_guesses <= 1).to_s
		    end
		  end
		piece + body_part.to_s + "\n"
	  end
	  
	  puts
	  puts  (separator * 3) + top_piece
	  puts ([separator * 3 + post_piece] * 5).each_with_index.map(&gallows_post).join
	  puts (separator * 2) + bottom_piece
	  puts
	  puts "Word: #{@word_holder.join(' ')}"
	  puts
	  puts "Misses: #{@letters_missed.join(', ')}"
	  puts "Remaining guesses: #{rem_guesses}"
	  puts
	end
  
    # Clear the board
    def clear
	  @letters_missed.clear
	  @secret_word.clear
	  @word_holder.clear
	end
  
    def get_board_data
	  {:sw => @secret_word, :lm => @letters_missed, :wh => @word_holder}
	end
	
	def set_board_data(board_data)
	  if !board_data.empty?
	    @secret_word = board_data[:sw]
	    @letters_missed = board_data[:lm]
	    @word_holder = board_data[:wh]
	  end
	end
  
    private
	
	# Load a set of words from a dictionary file
	def load_words(filename)
	  words = []
	  File.open(filename, "r").each do |word|
	    words << word.downcase.chomp if word.size.between?(5, 12) && !word[0].between?('A', 'Z')
	  end
	  words
	end
	
  end
  
  # Implements the game's logic
  class HangmanGame
	
	SAVEDGAME_FILENAME = "./saved_game.sav" 
	
	def initialize
	  @player = Player.new("Player", 0, 0)
	  @board = Board.new
	  @rounds = 0
	end
  
    # Start playing the game
    def play
	  @player.wins = 0
	  @player.loses = 0
	  
	  loop do
	    @board.clear
		@board.select_secret_word
		@rounds += 1
		
		load_game if prompt_load_game
		
		puts "\n******************* Hangman ********************"
	    @board.print_board  
	    
		loop do
          answer = prompt_guess
		  
		  if answer == 'save'
		    save_game
			next
		  end
		  
	      @board.set_guess(answer)
		  @board.print_board  
		  
		  result = 
		    if @board.is_winner?
		      @player.wins += 1
		      puts "\n#{@player.name} wins!!"
			  true
		    elsif @board.is_hanged?
			  @player.loses += 1
		      puts "\n#{@player.name} was hanged and loses.. The answer was #{@board.get_secret_word.upcase}"
			  true
			end
		  
		  break if result
		end
		
		break if prompt_quit
	  end
	  
	  print_final_score
	end
	
	private
	
	# Ask for loading a previoulsy saved game
	def prompt_load_game
	  ans = ''
	  loop do
	    print "\nDo you want to load a previoulsy saved game (Y/N)? "
	    ans = gets.chomp.upcase
		break if ['Y', 'N'].include? ans
		puts "Invalid answer! Try again..."
	  end
	  ans == 'Y'
	end
	
	# Ask for the player's guess
	def prompt_guess
	  guess = ''
	  loop do
	    print "\n#{@player.name}, make your guess (or type 'save' for saving your current game): "
	    guess = gets.chomp
		break if ('a'..'z').include?(guess) or guess == 'save'
		puts "Invalid choice! Try again.."  
	  end
	  guess
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
	  puts "\nScore:"
	  puts "\nRounds played: #{@rounds}"
	  
	  puts "Won games: #{@player.wins}"
	  puts "Lost games: #{@player.loses}"
	  puts "\n\n"
	end
	
	def save_game
	  game_data = {}
	  game_data[:player] = @player
	  game_data[:rounds] = @rounds
	  game_data[:board] = @board.get_board_data
	  
	  File.open(SAVEDGAME_FILENAME, "w") do |file|
	    file.write YAML.dump(game_data)
	  end
	  
	  puts "The current game was successfully saved!"
	end
	
	def load_game
	  puts "\nLoading a previous game..."
	  
	  game_data = nil
	  if File.exists?(SAVEDGAME_FILENAME)
	    File.open(SAVEDGAME_FILENAME, "r") do |file|
	      game_data = YAML.load(file.read)
	    end
	  end
	  
	  result = 
	    if !game_data.nil? 
	      @player = game_data[:player]
		  @rounds = game_data[:rounds]
		  @board.set_board_data(game_data[:board])
		  true
	    else
	      puts "Error: The game could not be loaded!"
		  false
	    end
	end
	
  end
end

# Run the script
Hangman::HangmanGame.new.play
