def fibs(n)
  return n if n < 1
  
  prev, fib = 0, 1
  2.upto(n) { |_| prev, fib = fib, prev + fib }
  fib
end

def fibs_rec(n)
  return n if n < 2
  fibs_rec(n-2) + fibs_rec(n-1)
end

puts "First 20th terms from Fibonacci's Serie using an iterative solution:"
1.upto(20) do |n|
  print fibs(n).to_s + (n < 20 ? ", " : "\n")
end
puts
puts "First 20th terms from Fibonacci's Serie using a recursive solution:"
1.upto(20) do |n|
  print fibs_rec(n).to_s + (n < 20 ? ", " : "\n")
end
