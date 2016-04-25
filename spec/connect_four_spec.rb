require_relative './spec_helper'
require_relative '../connect_four'

include ConnectFour

describe Player do

  before(:context) do
    @player = Player.new('Name', [:R, :Y].sample, 0)
  end

  it "holds the player's name" do
    expect(@player.name).to match(/[A-Za-z0-9\s]+/)
  end
  
  it "holds the player's disk color" do
    expect(@player.color).to eq(:R).or eq(:Y)
  end
  
  it "holds the player's score" do
    expect(@player.score).to eq(0)
  end
  
  it "updates the player's score" do
    @player.score += 5
    expect(@player.score).to eq(5)
  end
  
end

describe Board do

  before(:context) do
	  @a_board = Board.new
  end
	
  it "has 6 rows and 7 columns by default" do
    expect([@a_board.rows, @a_board.cols]).to eq([6, 7])
  end
	
  describe "::WIN_CONFIGS_OFFSETS" do
    
	def get_pos_from_offset(offset, start_pos)
	  offset.map { |pos| [start_pos[0] + pos[0], start_pos[1] + pos[1]] }
	end
	
    before(:context) do 
	  @a_grid = [[1, 2, 3, 4],[1, 2, 3, 4], [1, 2, 3, 4], [1, 2, 3, 4]]
	end
   
    it "sets a 4-cells horizontal offset from an initial grid position" do
	  hor_offset = get_pos_from_offset(Board::WIN_CONFIGS_OFFSETS[0], [1, 0])
	  expect(hor_offset).to eq([[1, 0], [1, 1], [1, 2], [1, 3]]) 
	  expect(hor_offset.collect { |pos| @a_grid[pos[1]][pos[0]] }).to eq([2, 2, 2, 2])
	end
	
	it "sets a 4-cells vertical offset from an initial grid position" do
	  vert_offset = get_pos_from_offset(Board::WIN_CONFIGS_OFFSETS[1], [0, 3])
	  expect(vert_offset).to eq([[0, 3], [1, 3], [2, 3], [3, 3]]) 
	  expect(vert_offset.collect { |pos| @a_grid[pos[1]][pos[0]] }).to eq([1, 2, 3, 4])
	end
	
	it "sets a 4-cells upward diagonal from an initial grid position" do
	  up_diag_offset = get_pos_from_offset(Board::WIN_CONFIGS_OFFSETS[2], [0, 0])
	  expect(up_diag_offset).to eq([[0, 0], [1, 1], [2, 2], [3, 3]]) 
	  expect(up_diag_offset.collect { |pos| @a_grid[pos[1]][pos[0]] }).to eq([1, 2, 3, 4])
	end
	
	it "sets a 4-cells downward diagonal from an initial grid position" do
	  down_diag_offset = get_pos_from_offset(Board::WIN_CONFIGS_OFFSETS[3], [3, 0])
	  expect(down_diag_offset).to eq([[3, 0], [2, 1], [1, 2], [0, 3]]) 
	  expect(down_diag_offset.collect { |pos| @a_grid[pos[1]][pos[0]] }).to eq([4, 3, 2, 1])
	end
	
  end	

  describe "#is_empty?" do
    it "returns true when created and no move is done yet" do
	  expect(@a_board.is_empty?).to be true
	end
	
	it "returns false when at least a valid choice has been done" do
	  @a_board.set_disk((1..@a_board.cols).to_a.sample, [:R, :Y].sample)
	  expect(@a_board.is_empty?).to be false
	end
  end
  
  describe "#clear" do
    it "clears the board and empties it" do
      @a_board.clear
      expect(@a_board.is_empty?).to be true
    end
  end
  
  describe "#set_disk" do
    it "returns false when an invalid position is provided" do
	  expect(@a_board.set_disk(10, :R)).to be false
	end
	
	it "returns false when the position is full" do
	  @a_board.clear
	  6.times { |time| @a_board.set_disk(0, :Y) }
	  expect(@a_board.set_disk(0, :R)).to be false
	end
	
	it "returns true when a disk is correctly set" do
	  expect(@a_board.set_disk(6, :R)).to be true
	end
  end
  
  describe "#is_available?" do
    it "returns false when queried for an invalid position" do
	  expect(@a_board.is_available?(-1)).to be false
	end
	
	it "returns false when the queried position is full" do
	  @a_board.clear
	  @a_board.rows.times { |row| @a_board.set_disk(1, :R) }
	  expect(@a_board.is_available?(1)).to be false
	end
	
	it "returns true if there is space available in the given position" do
	  expect(@a_board.is_available?(4)).to be true
	end
  end
	
  describe "#is_full?" do
    it "returns false when there are still available positions" do
      @a_board.clear
	  expect(@a_board.is_full?).to be false
    end
  
    it "returns true when there are not more available positions" do
      grid = Array.new(7) { Array.new(6) { [:R, :Y].sample }}
	  test_board = Board.new(6, 7, grid)
	  expect(test_board.is_full?).to be true
    end
  end
  
  describe "#is_winner?" do
    it "returns true if a color symbol satisfies an horizontal winning condition" do
      test_board = Board.new(6, 7, [[:Y], [:R, :R], [:Y, :R], [:R, :R], [:Y, :R], [:Y], [:Y, :Y]])
	  expect(test_board.is_winner?(:R)).to be true
	end
	
	it "returns true if a color symbol satisfies a vertical winning condition" do
      test_board = Board.new(6, 7, [[:Y, :Y, :R, :R], [:R, :R], [:Y, :R], [:R], [:Y, :R], [:R, :Y, :Y, :Y, :Y], []])
	  expect(test_board.is_winner?(:Y)).to be true
	end
	
	it "returns true if a color symbol satisfies an upward-diagonal winning condition" do
      test_board = Board.new(6, 7, [[:Y], [:R, :Y], [:Y, :Y, :R], [:R, :R, :Y, :R], [:Y, :R, :Y, :Y, :R], [:Y, :R, :Y, :Y, :R, :R], []])
	  expect(test_board.is_winner?(:R)).to be true
	end
	
	it "returns true if a color symbol satisfies a downward-diagonal winning condition" do
      test_board = Board.new(6, 7, [[], [:Y, :R, :R, :Y], [:R, :Y, :Y], [:R, :Y, :R], [:Y, :R, :Y, :R], [:Y, :Y], [:R, :R]])
	  expect(test_board.is_winner?(:Y)).to be true
	end
	
	it "returns false if a color symbol does not satisfy any winning condition" do
      test_board = Board.new(6, 7, [[:Y, :Y, :R, :R], [:R, :R], [:Y, :R], [:R], [:Y, :R], [:R, :Y, :Y, :Y, :Y], []])
	  expect(test_board.is_winner?(:R)).to be false
	end
  end
  
  describe "#print_board" do
    it "responds to a print board request" do
	  expect(@a_board.respond_to?(:print_board)).to be true
	end
  end
  
end

describe "CFGame" do
  before(:context) do
    @a_game = CFGame.new
  end
  
  describe "#play" do
    it "responds to a play request" do
	  expect(@a_game.respond_to?(:play)).to be true
    end
  end
  
  describe "#prompt_movement" do
    it "privatly responds to a prompt movement request" do
	  expect(@a_game.respond_to?(:prompt_movement, true)).to be true
    end
  end
  
  describe "#prompt_quit" do
    it "privatly responds to a prompt quit request" do
	  expect(@a_game.respond_to?(:prompt_quit, true)).to be true
    end
  end
  
  describe "#print_final_score" do
    it "privatly responds to a print final score request" do
	  expect(@a_game.respond_to?(:print_final_score, true)).to be true
    end
  end
  
  describe "#swap_players" do
    it "privatly responds to a swap players request" do
	  expect(@a_game.respond_to?(:swap_players, true)).to be true
    end
  end
end

describe "a tied game" do
  before(:context) do
    @tied_board = Board.new(6, 7, 
	  [[:Y, :R, :R, :Y, :R, :Y], 
	   [:Y, :R, :Y, :Y, :Y, :R], 
	   [:R, :Y, :Y, :R, :R, :R], 
	   [:R, :R, :R, :Y, :Y, :R], 
	   [:R, :Y, :R, :Y, :Y, :Y], 
	   [:Y, :Y, :R, :Y, :R, :R], 
	   [:Y, :R, :Y, :R, :R, :Y]])
  end
  
  it "has a full board" do
    expect(@tied_board.is_full?).to  be true
  end
  
  it "has no player R as winner" do
    expect(@tied_board.is_winner?(:R)).to be false
  end
  
  it "has no player Y as winner" do
    expect(@tied_board.is_winner?(:Y)).to be false
  end
end

describe "a won game" do
  
  def to_row_col(pos)
	row = (pos - 1) / 3
	col = (pos - 1) % 3
	[row, col]
  end
  
  it "satisfies any of the 69 possible winning configurations" do
    # There are 69 total winning configurations of four connected cells  in a board:
	# 24 horizontal, 21 vertical and 12 for each diagonal direcion
		
	a_full_won_grid = Array.new(7) { Array.new(6) { :R }}
		
	n_wins = 0
	(0..5).each do |row|
	    (0..6).each do |col|
		  Board::WIN_CONFIGS_OFFSETS.each do |offset|
		    positions = offset.map { |pos| [row + pos[0], col + pos[1]] }
			colors = positions.collect { |pos| ((0..5).include?(pos[0]) && (0..6).include?(pos[1])) ? a_full_won_grid[pos[1]][pos[0]] : nil }
			n_wins +=1 if colors.count(:R) == 4
	      end
	    end
	end
	
	expect(n_wins).to  eq(69)
  end
    
  subject(:board) { Board.new }
  subject(:play) { play = double("play") }
	
  let(:ttt_game) do
    board.clear
    loop do
      position, color = play.move
	  board.set_disk(position, color)
	  break if board.is_winner?(color)
	end
  end
    	
  context "when player R is the winner" do
    it "returns true for player R as winner and false for player Y" do
	  allow(play).to receive(:move).and_return([4, :R], [3, :Y], [4, :R], [2, :Y], [4, :R], [6, :Y], [4, :R])
	  ttt_game
      expect(board.is_winner?(:R)).to be true
	  expect(board.is_winner?(:Y)).to be false
    end
  end
  
  context "when player Y is the winner" do
    it "returns true for player Y as winner and false for player R" do
      allow(play).to receive(:move).and_return([4, :R], [3, :Y], [5, :R], [4, :Y], [5, :R], [5, :Y], [6, :R], [6, :Y], [6, :R], [6, :Y])
	  ttt_game
      expect(board.is_winner?(:Y)).to be true
	  expect(board.is_winner?(:R)).to be false
    end
  end
  
end

