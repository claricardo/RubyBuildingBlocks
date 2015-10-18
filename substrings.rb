=begin
Method that inspects a sentece and extracts the frequency of words that 
belong to a dictionary and could be contained in the sentence
Parameters:
	sentence: a sentence to be inspected
	dictionary: an array of words to be searched in sentence
Return: 
	A hash that contains pairs [word => frequency] associated to the set of words from the dictionary 
	that are included in the input sentence
=end
def substrings(sentence, dictionary)
	words_freq = Hash.new(0)
	dictionary.each do |dictio_word|
		words = sentence.downcase.scan dictio_word
		words_freq[dictio_word] += words.length if words.length > 0
	end
	words_freq
end

# The dictionary
dictionary = ["below","down","go","going","horn","how","howdy","it","i","low","own","part","partner","sit"]

# Testing with a short sentence
str = "below"
puts "\nTest 1"
puts "String: " + str
puts substrings(str, dictionary)

# Testing with a sentence that contains multiple words
str = "Howdy partner, sit down! How's it going?"
puts "\nTest 2"
puts "String: " + str
puts substrings(str, dictionary)