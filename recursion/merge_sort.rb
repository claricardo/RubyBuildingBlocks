def merge(arr1, arr2)
  arr = []
  
  while arr1.size > 0 && arr2.size > 0
    if arr1[0] < arr2[0]
	  arr << arr1.shift
	else
	  arr << arr2.shift
	end
  end
  
  if arr1.empty?
    arr += arr2
  else
    arr += arr1
  end
  
  arr
end

def merge_sort(arr)
  return arr if arr.size <= 1
  
  arr1 = merge_sort(arr[0...(arr.size / 2)])
  arr2 = merge_sort(arr[(arr.size / 2)..-1])
  merge(arr1, arr2)
end

a = [8, 4, 5, -100, 200, 100, 1, 1, 24, -40, 10, 0, -70]
puts "\nOriginal array: #{a}"
puts 
puts "Sorted array: #{merge_sort(a)}"


