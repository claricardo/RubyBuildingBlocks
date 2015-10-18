=begin
Method for ciphering/deciphering a message according to the Caesar's code.
Parameters:
	in_msg: a message to encode
	key: shift factor; number of displaced positions 
	action: :cipher (to encode) / :decipher (to decode) 
Return: 
	A properly coded/decoded string, preserving text case
=end
def caesar_cipher in_msg, key, action = :cipher
  out_msg = ""
  beg_pos = 'a'.ord 	# starting position (ASCII number of the 'a' character)
  alpha_size = 26 		# Size of the alphabet (26 symbols; a-z)
  shift = (action == :decipher ? -key : key)
  in_msg.each_char do |char|
    up_case = (char =~ /[A-Z]/)
	char = (((char.downcase.ord - beg_pos) + shift) % alpha_size + beg_pos).chr	unless (char =~ /[^A-z]/) 
	out_msg << (up_case ? char.upcase : char)
  end
  out_msg
end  

# Testing with a standard short string
puts "\nTest #1\n"
str1 = "What a string!"
puts "Original message: " + str1
str1 = caesar_cipher(str1, 5)
puts "Ciphered message: " + str1
puts "Deciphered message: " + caesar_cipher(str1, 5, :decipher)
puts

# Testing with a long string including case handling 
puts "\nTest #2\n"
str1 = "This Is AnoTher TesT for The metHod including CASE Handling, 12345 (numbers) and #$%/:;. (symbols)"
puts "Original message: " + str1
str1 = caesar_cipher(str1, 10)
puts "Ciphered message: " + str1
puts "Deciphered message: " + caesar_cipher(str1, 10, :decipher)