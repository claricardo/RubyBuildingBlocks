=begin
A couple of methods for sorting an array using the "Bubble Sort" algorithm.
bubble_sort - uses a standard comparison between the array's elements
bubble_sort_by - uses a given block for establishing the order between, similar to the results provided 
                 by the <=> 'spaceship' operator (-1: less than, 0: equal to, 1: greater than)
Parameters:
	src_array: an array to sort
	{block} (for bubble_sort_by)
Return: 
	A properly sorted array
=end

def bubble_sort(src_array)
  tgt_array = src_array.dup  # make a copy for not modifying the original array
  for i in (0...tgt_array.length - 1)
    for j in (i+1...tgt_array.length)
	  tgt_array[i], tgt_array[j] = tgt_array[j], tgt_array[i] if tgt_array[i] > tgt_array[j]
	end
  end
  tgt_array
end

def bubble_sort_by(src_array)
  if block_given?
    tgt_array = src_array.dup  # make a copy for not modifying the original array
    for i in (0...tgt_array.length - 1)
      for j in (i+1...tgt_array.length)
	    tgt_array[i], tgt_array[j] = tgt_array[j], tgt_array[i] if yield(tgt_array[i],tgt_array[j]) > 0
	  end
    end
	tgt_array
  else
    puts "No block was provided for ordering the elements!"
	src_array
  end
end

# Testing bubble_sort
p bubble_sort([4,3,78,2,0,2])
p bubble_sort([100,3,-10,2,0,10, 1, 80, -50])

# Testing bubble_sort_by
p bubble_sort_by(["hi","hello","hey"])
p(bubble_sort_by(["hi","hello","hey"]) do |left,right|
    left.length - right.length
  end)
p(bubble_sort_by([4,3,78,2,0,2]) {|left,right| left <=> right })

