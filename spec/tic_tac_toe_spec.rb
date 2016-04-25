require_relative './spec_helper'
require_relative '../tic_tac_toe'

include TicTacToe

describe Player do

  before(:context) do
    @player = Player.new('Name', :X, 0)
  end
	
  it "holds the player's mark" do
    expect(@player.mark).to eq(:X)
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
    @a_board = Board.new()
  end
  
  it "has 3 rows and 3 columns by default" do
    expect([@a_board.rows, @a_board.cols]).to eq([3, 3])
  end
  
  describe "#is_empty?" do
      
	it "returns true when created and no move is done yet" do
      expect(@a_board.is_empty?).to be true
    end
  
    it "returns false when at least one valid position is marked" do
      @a_board.set_mark(1, :X)
      expect(@a_board.is_empty?).to be false
    end
	  
  end
  
  describe "is_cell_available?" do
  
    it "returns false when queried for an invalid position" do
      expect(@a_board.is_cell_available?(-1)).to be false
    end
  
    it "returns true if a valid position is available" do
      expect(@a_board.is_cell_available?(2)).to be true
    end
    
    it "returns false when a position is already marked" do
      @a_board.set_mark(2, :O)
      expect(@a_board.is_cell_available?(2)).to be false
    end
  end
  
  describe "#is_full?" do
    it "returns false when there are still available positions" do
      expect(@a_board.is_full?).to be false
    end
  
    it "returns true when there are not more available positions" do
      test_board = Board.new(3, 3, [[:X, :X, :X], [:X, :X, :X], [:X, :X, :X]])
	  expect(test_board.is_full?).to be true
    end
  end
  
  describe "#is_winner?" do
    it "returns true if a mark satisfies a winning condition" do
      test_board = Board.new(3, 3, [[:X, :X, :X], ['', '', ''], ['', '', '']])
	  expect(test_board.is_winner?(:X)).to be true
	end
	
	it "returns false if a mark does not satisfy a winning condition" do
      test_board = Board.new(3, 3, [[:O, :X, :O], ['', '', ''], ['', '', '']])
	  expect(test_board.is_winner?(:O)).to be false
	end
  end
  
  describe "#clear" do
    it "clears the board and empties it" do
      @a_board.clear
      expect(@a_board.is_empty?).to be true
    end
  end

end

describe "a tied game" do
  before(:context) do
    @tied_board = Board.new(3, 3, [[:X, :O, :X], [:X, :O, :X], [:O, :X, :O]])
  end
  
  it "has a full board" do
    expect(@tied_board.is_full?).to  be true
  end
  
  it "has no player X as winner" do
    expect(@tied_board.is_winner?(:X)).to be false
  end
  
  it "has no player O as winner" do
    expect(@tied_board.is_winner?(:O)).to be false
  end
end

describe "a won game" do
  
  def to_row_col(pos)
	row = (pos - 1) / 3
	col = (pos - 1) % 3
	[row, col]
  end
  
  it "satisfies one of the 8 possible winning configurations" do
    a_full_won_grid =  [[:X, :X, :X], [:X, :X, :X], [:X, :X, :X]]
		
	n_wins = 
	  Board::WIN_CONFIGS.reduce(0) do |wins, line|
	    wins +=1 if 
	      line.all? do |elem|
		    row, col = to_row_col(elem)
		    a_full_won_grid[row][col] == :X
	      end
	  end
	
	expect(n_wins).to  eq(8)
  end
  
  subject(:board) { Board.new }
  subject(:play) { play = double("play") }
	
  let(:ttt_game) do
    board.clear
    loop do
      position, mark = play.move
	  board.set_mark(position, mark)
	  break if board.is_winner?(mark)
	end
  end
    	
  context "when player X is the winner" do
    it "returns true for player X as winner and false for player O" do
	  allow(play).to receive(:move).and_return([1, :X], [3, :O], [9, :X], [5, :O], [7, :X], [4, :O], [8, :X])
	  ttt_game
      expect(board.is_winner?(:X)).to be true
	  expect(board.is_winner?(:O)).to be false
    end
  end
  
  context "when player O is the winner" do
    it "returns true for player O as winner and false for player X" do
      allow(play).to receive(:move).and_return([4, :X], [3, :O], [1, :X], [7, :O], [5, :X], [9, :O], [8, :X], [6, :O])
	  ttt_game
      expect(board.is_winner?(:O)).to be true
	  expect(board.is_winner?(:X)).to be false
    end
  end
  
end


