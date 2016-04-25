require_relative './spec_helper'
require_relative '../caesar_cipher'


describe "Caesar's Cipher" do

  before(:context) do
    @a_msg = "this is a test message"
  end

  context "when :cipher is the default or explicit action argument" do 
  
    it "produces an empty message if the original message is empty" do
	  expect(caesar_cipher("")).to eq("")
    end
	
    it "produces the original message if key is 0" do
	  expect(caesar_cipher(@a_msg, 0)).to eq(@a_msg)
    end
	
    it "ciphers a message with a given key" do
	  expect(caesar_cipher(@a_msg, 5)).to eq("ymnx nx f yjxy rjxxflj")
	end

	# helper function for titleizing a message
	def titleize_message(msg)
	  msg.split.map {|word| word.capitalize}.join(' ')
	end
	
	it "keeps text case when ciphers a message" do
	  expect(caesar_cipher(titleize_message(@a_msg), 5)).to eq(titleize_message("ymnx nx f yjxy rjxxflj"))
	end 

	it "does not cipher numeric and non-alpha characters" do
	  test_msg = "1234567890!#$%&/()=?<>;:,._-"
	  expect(caesar_cipher(test_msg, 2)).to eq(test_msg)
	end

	it "properly ciphers a message with mixed content" do
	  src_msg = "ThIs_1! iS2 A TesT#8 me$$@G3!?"
	  tgt_msg = "YmNx_1! nX2 F YjxY#8 rj$$@L3!?"
	  expect(caesar_cipher(src_msg, 5)).to eq(tgt_msg)
	end
	
	context "when called twice with a same key" do
      it "produces a message ciphered with 2 times the key" do ###
        expect(caesar_cipher(caesar_cipher(@a_msg, 2), 2)).to eq(caesar_cipher(@a_msg, 4))
	  end 
	end
	
	context "when called twice with different keys" do
      it "produces a message ciphered with the sum of the two keys" do ###
        expect(caesar_cipher(caesar_cipher(@a_msg, 2), 3)).to eq(caesar_cipher(@a_msg, 5))
	  end 
	end
	
  end
	
  context "when :decipher is the explicit action argument" do
	
	context "when ciphering and deciphering keys have both the same value" do
	  it "deciphers and produces the original message" do
	    expect(caesar_cipher(caesar_cipher(@a_msg, 3), 3, :decipher)).to eq(@a_msg)
	  end
	end
	
	context "when ciphering and deciphering keys differ in value" do
	  it "does not decipher and produces a wrong message" do
	    expect(caesar_cipher(caesar_cipher(@a_msg, 3), 1, :decipher)).not_to eq(@a_msg)
	  end
	end
	
  end
	
end

