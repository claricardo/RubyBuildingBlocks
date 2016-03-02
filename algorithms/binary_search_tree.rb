# Class that defines a binary tree's node
class Node
  attr_accessor :value, :parent, :children
  
  def initialize(value = nil)
    @value = value
	@parent = nil
	@children = nil
  end
end

# Helper function for recursively inserting a node into a binary tree
def insert_node(cur_node, parent_node, value)
  node = nil
  
  if cur_node.nil?
	node = Node.new(value)
    node.children = Array.new(2, nil)
	node.parent = parent_node
    return node
  end
  
  if value < cur_node.value
    node = insert_node(cur_node.children[0], cur_node, value)
	cur_node.children[0] ||= node
  else
    node = insert_node(cur_node.children[1], cur_node, value)
	cur_node.children[1] ||= node
  end
  
  node
end

# Recursive function to build a binary tree from given data array
def build_tree_2(data_array)
  root = nil
  
  data_array.each do |elem|
    node = insert_node(root, nil, elem) 
	root ||= node
  end
  
  root
end

# Iterative function to build a binary tree from a given data array
def build_tree(data_array)
  root = nil
    
  data_array.each do |elem|
    cur_node = root
  
    node = Node.new(elem)
	node.children = Array.new(2, nil)
	
	while !cur_node.nil?
	  if elem < cur_node.value
	    if cur_node.children[0].nil?
		  node.parent = cur_node
		  cur_node.children[0] = node
		  cur_node = node
		end
		cur_node = cur_node.children[0]
	  else
	    if cur_node.children[1].nil?
		  node.parent = cur_node
		  cur_node.children[1] = node
		  cur_node = node
		end
		cur_node = cur_node.children[1]
	  end
	end
	
	root ||= node
	  
  end
  
  root
end

# Breadth First Search algorithm for finding a value inside a binary tree
def breadth_first_search(tree, value)
  tgt_node = nil
  
  queue = Array(tree)
  
  while !queue.empty?
    cur_node = queue.shift  
    
	if cur_node.value == value
	  tgt_node = cur_node
	  break
	end
	
	cur_node.children.each { |child| queue << child unless child.nil? }
  end
  
  tgt_node
end

# Depth First Search algorithm for finding a value inside a binary tree
def depth_first_search(tree, value)
  tgt_node = nil
  
  stack = Array(tree)
  
  while !stack.empty?
    cur_node = stack.pop
  
	if cur_node.value == value
	  tgt_node = cur_node
	  break
	end
	
	cur_node.children.reverse_each { |child| stack.push(child) unless child.nil? }
  end
  
  tgt_node
end

# Recursive DFS algorithm for finding a value inside a binary tree
def dfs_rec(cur_node, value)
  return nil if cur_node.nil?
  
  if cur_node.value == value
	cur_node
  else
    tgt_node = nil
    cur_node.children.each do |child| 
	  tgt_node = dfs_rec(child, value)
	  break unless tgt_node.nil?
	end
	tgt_node
  end
end

# Helper function to print a binary search tree
def print_tree(tree)
   return "-" if tree.nil?
   puts "#{tree.value}: "
   print "Left: "
   puts "#{print_tree(tree.children[0])}"
   print "Right: "
   puts "#{print_tree(tree.children[1])}"
end


# Script for testing the functions

data = [1, 7, 4, 23, 8, 9, 4, 3, 5, 7, 9, 67, 6345, 324]
puts "\nData array: #{data}"
puts 

tree = build_tree(data)
#puts "\n*** Iteratively built tree:"
#print_tree tree

puts "BFS:"
puts (f = breadth_first_search(tree, 67)).nil? ? 'Not found' : f.value
puts (f = breadth_first_search(tree,324)).nil? ? 'Not found' : f.value
puts (f = breadth_first_search(tree, -10)).nil? ? 'Not found' : f.value
puts

puts "DFS:"
puts (f = depth_first_search(tree, 67)).nil? ? 'Not found' : f.value
puts (f = depth_first_search(tree,324)).nil? ? 'Not found' : f.value
puts (f = depth_first_search(tree, 0)).nil? ? 'Not found' : f.value
puts

puts "Recursive DFS:"
puts (f = dfs_rec(tree, 3)).nil? ? 'Not found' : f.value
puts (f = dfs_rec(tree,6345)).nil? ? 'Not found' : f.value
puts (f = dfs_rec(tree, 190)).nil? ? 'Not found' : f.value


