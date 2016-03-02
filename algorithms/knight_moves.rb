# Class that defines a Knight piece
class Knight
  # Valid offsets
  @@offsets = [[1, -2], [2, -1], [2, 1], [1, 2], [-1, 2], [-2, 1], [-2, -1], [-1, -2]]
  
  def initialize(row  = 0, col = 0)
    @symbol = :K
    @position = {:row => row, :col => col }
  end
  
  def to_sym
    @symbol
  end
  
  # Set the piece's current position
  def set_position(row, col)
    if row.between?(0, 7) && col.between?(0, 7)
      @position[:row] = row
	  @position[:col] = col
	end
  end
  
  # Get all possible movements from the piece's current position
  def get_possible_moves
    moves = 
	  @@offsets.collect do |move| 
	    row = @position[:row] + move[0]
	    col = @position[:col] + move[1]
		[row, col] if row.between?(0, 7) && col.between?(0, 7)
	  end
	moves.compact
  end

end


# Class that defines a chess board.
# Each board's square is at same time a piece holder and a Search Tree node
class Board

  def initialize
    @board = Array.new(8) { Array.new(8) { {:value => nil, :parent => nil, :distance => Float::INFINITY } } }  
  end
   
  # Rows are numbered from bottom to top
  def to_row(row)
    7 - row
  end
  
  # Validate (row, col) to be in range (0..7)
  def valid_position?(row, col)
    row.between?(0, 7) && col.between?(0, 7) ? true : false
  end
  
  def is_square_empty?(row, col)
    @board[to_row(row)][col][:value].nil?
  end
  
  def mark_square(row, col, mark)
    @board[to_row(row)][col][:value] = mark if valid_position?(row, col)
  end
  
  def clear_square(row, col)
    @board[to_row(row)][col] = {:value => nil, :parent => nil, :distance => Float::INFINITY } if valid_position?(row, col) 
  end
  
  def get_square(row, col)
    @board[to_row(row)][col] if valid_position?(row, col)
  end
  
  def get_square_parent(row, col)
    @board[to_row(row)][col][:parent] if valid_position?(row, col)
  end
  
  def set_square_parent(row, col, parent)
    @board[to_row(row)][col][:parent] = parent if valid_position?(row, col)
  end
 
  def get_square_distance(row, col)
    @board[to_row(row)][col][:distance] if valid_position?(row, col)
  end
 
  def set_square_distance(row, col, dist)
    @board[to_row(row)][col][:distance] = dist if valid_position?(row, col)
  end
   
  def print_board
    @board.each do |row|
	  row.each { |col| print !col[:value].nil? ? "#{col[:value]}" : 0}
	  puts
	end
  end
   
end


# Find the shortest path to move a Knigth piece from a source square to a target square
def knight_moves(src_sqr = [0, 0], tgt_sqr = [0, 0])
  # Init the board and a Knight piece
  board = Board.new
  knight = Knight.new
  
  puts "\nFrom #{src_sqr} to #{tgt_sqr}..."
  
  unless board.valid_position?(src_sqr[0], src_sqr[1]) && board.valid_position?(tgt_sqr[0], tgt_sqr[1])
    puts "Invalid starting or ending positions!\nPlease, provide only valid positions in range [0, 0] to [7, 7] to find a solution!"
	return
  end
  
  # Mark the source square on the board and set its distance to 0
  board.mark_square(src_sqr[0], src_sqr[1], knight.to_sym)
  board.set_square_distance(src_sqr[0], src_sqr[1], 0)
  # Enqueue the source square
  queue = [src_sqr]
  
  # BFS algorithm  
  while !queue.empty?
    cur_sqr = queue.shift  
    
	break if cur_sqr == tgt_sqr
	
    # Get all possible moves from current position	
	knight.set_position(cur_sqr[0], cur_sqr[1])
	knight.get_possible_moves.each do |move| 
	  next unless board.is_square_empty?(move[0], move[1]) 
	  
	  # Enqueue all possible moves whose related squares are not visited yet
	  queue << move 
	  board.mark_square(move[0], move[1], knight.to_sym)
	  board.set_square_distance(move[0], move[1], board.get_square_distance(cur_sqr[0], cur_sqr[1]) + 1)
	  board.set_square_parent(move[0], move[1], cur_sqr)
	end
  end
  
  # Build the reverse path from src_sqr to tgt_sqr, starting from tgt_sqr
  path = [tgt_sqr]
  parent = board.get_square_parent(tgt_sqr[0], tgt_sqr[1])
  while !parent.nil?
    path << parent
	parent = board.get_square_parent(parent[0], parent[1])
  end
  
  # Print the solution
  puts "Solution obtained in #{path.length - 1} move#{path.length - 1 != 1 ? 's' : ''}! The path is:"
  path.reverse.each {|move| p move}
  
end


# Some tests for the knight_moves function
knight_moves([0, 0], [-1, -1])
knight_moves([0, 0], [0, 0])
knight_moves([0, 0], [2, 1])
knight_moves([0, 0], [1, 2])
knight_moves([3, 3], [4, 4])
knight_moves([0,0],[3,3])
knight_moves([3,3],[0,0])
knight_moves([3,3],[4,3])
knight_moves([0,0],[1,1])
knight_moves([7,7],[6,6])
knight_moves([0,0],[7,7])
