=begin
A reimplementation of some enumerable methods from the Enumerable module
Reimplemented methods: each, each_with_index, select, all?, any?, none?, count, map, inject
Parameters:
	all methods can receive a block
	my_count, my_map, my_inject could receive the same parameters as the original methods do; 
	                            see the examples for proper usage
Return: 
	Results depend on the enumerable method
=end

module Enumerable
  def my_each
    if block_given?
	  0.upto(self.size-1) {|idx| yield self[idx]}
	  self
	else
	  self.to_enum(:my_each)
	end
  end

  def my_each_with_index
    if block_given?
      0.upto(self.size-1) {|idx| yield(self[idx],idx)}
	  self
	else
	  self.to_enum(:my_each_with_index)
	end
  end
  
  def my_select
    if block_given?
	  result = []
	  self.my_each {|elem| result << elem if yield(elem)}
      result
	else
	  self.to_enum(:my_select)
	end
  end
  
  def my_all?
    result = true
    if block_given?
	  self.my_each {|elem| result &&= yield(elem)}
	else
	  self.my_each {|obj| result &&= obj}
	end
	result && true
  end
  
  def my_any?
    result = false
    if block_given?
	  self.my_each {|elem| result ||= yield(elem); break if result }
	else
	  self.my_each {|obj| result ||= obj; break if result }
	end
	result && true
  end
  
  def my_none?
    result = false
    if block_given?
	  self.my_each {|elem| result ||= yield(elem); break if result }
	else
	  self.my_each {|obj| result ||= obj; break if result }
	end
	!(result || false)
  end
  
  def my_count(item = nil)
    count = 0
	if block_given?
	  self.my_each {|elem| count += 1 if yield(elem)}
	else
	  if item.nil?
	    count = self.size
	  else
	    self.my_each {|elem| count += 1 if item == elem}
	  end
	end
	count
  end
    
  def my_map(a_proc = nil)
    if a_proc.nil?
	  result = self.to_enum(:my_map)
	else
	  result = []
	  self.my_each {|elem| result << a_proc.call(elem)} 
	  result.my_each_with_index {|elem,idx| result[idx] = yield(elem)} if block_given? 
 	end
    result
  end
  
  def my_inject(*args)
    
	n_args = args.size
	case n_args
	when 2
	  # Error: initial value and symbol were in swapped order
	  raise TypeError, "#{args[1]} is not a symbol" if !args[1].is_a? Symbol
	  
	  memo = args[0]
	  symb = args[1]
	when 1
	  if args[0].is_a? Symbol
	    symb = args[0]
		memo = self.first
		shft = true
	  else
	    memo = args[0]
		symb = nil
	  end
	when 0
	  memo = self.first
	  shft = true
	else
	  # Error: only 0, 1 or 2 arguments are allowed
	  raise ArgumentError, "wrong number of arguments (#{args.size} for 0..2)"
	end
	
    if !symb.nil? # a symbol was provided in the arguments
      # Error: a symbol was provided as a memo for a block
	  raise NoMethodError, "undefined method for :#{symb}:Symbol" if block_given? && n_args == 1 
	  
	  self.my_each_with_index {|elem,idx| next if shft && idx == 0; memo = symb.to_proc.call(memo, elem)}    
    else	# no symbol provided...
	  if block_given? # ...so, test for a given block
        self.my_each_with_index {|elem, idx| next if shft && idx == 0; memo = yield(memo, elem)}
	  else
	    # Error: expecting a symbol when no block is provided
	    raise TypeError, "#{memo} is not a symbol" if n_args == 1
		
		# Error: no block nor symbol were given
	    raise LocalJumpError, "no block given" if n_args == 0
	  end
	end
	memo
  end
 
end
 
#******************** TESTS **********************
 
# # Testing my_each
# puts "\nmy_each:"
# [1,2,3,4,5].my_each {|elem| puts elem}
 
# # Testing my_each_with_index
# puts "\nmy_each_with_index:"
# [1,2,3,4,5].my_each_with_index {|elem, idx| puts "[#{idx}] = #{elem}"}
 
# # Testing my_select
# puts "\nmy_select:"
# p [1,2,3,4,5,6,7,8,9,10].my_select {|elem| elem % 2 != 0}
  
# # Testing my_all?
# puts "\nmy_all?:"
# puts [1,2,3,4,5,6,7,8,9,10].my_all? {|elem| elem > 0}
# puts [1,2,3,4,5,6,7,8,9,10].my_all? {|elem| elem <= 0}
 
# # Testing my_any?
# puts "\nmy_any?:"
# puts [1,2,3,4,5,6,7,8,9,10].my_any? {|elem| elem == 5}
# puts [1,2,3,4,5,6,7,8,9,10].my_any? {|elem| elem < 0}
 
# # Testing my_none?
# puts "\nmy_none?:"
# puts [1,2,3,4,5,6,7,8,9,10].my_none? {|elem| elem % 11 == 0}
# puts [1,2,3,4,5,6,7,8,9,10].my_none? {|elem| elem % 2 == 0}
 
# # Testing my_count
# puts "\nmy_count:"
# puts [1,2,3,4,5,6,7,8,9,10].my_count
# puts [1,2,3,2,2,2,7,8,9].my_count(2)
# puts [1,2,3,4,5,6,7,8,9,10].my_count {|elem| elem % 2 != 0}
 
# # Testing my_map
# puts "\nmy_map:"
# my_proc = Proc.new {|elem| elem += 2}
# p [-1,0,1,2,3].my_map(my_proc)
# p [-1,0,1,2,3].my_map(my_proc) {|elem| elem ** 3}
 
# # Testing my_inject
# puts "\nmy_inject:"

# def multiply_els(arr)
  # arr.my_inject(1, :*)
# end
# puts multiply_els([2,4,5])
 
# puts [1,2,3,4,5,6,7,8,9,10].my_inject(:+)
# puts [1,2,3,4,5,6,7,8,9,10].my_inject(10, :+)
# puts [1,2,3,4,5,6,7,8,9,10].my_inject(1) {|res, elem| res *= elem}
# puts [10,2,3,4,5,6,7,8,9,10].my_inject {|res, elem| res *= elem}
 
 