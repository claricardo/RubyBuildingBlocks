require_relative './spec_helper'
require_relative '../my_enumerables'


describe Enumerable do

  before(:context) do
    @an_array = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
  end

  #*** my_each (defined for Array)
  describe "#my_each" do
	  
	it "returns an Enumerator when no block is given" do
	  expect(@an_array.my_each).to be_an_instance_of(Enumerator)
	end
	  
	context "when a block is given" do  
	  
	  it "returns an empty array when the caller is empty" do
		expect([].my_each {}).to eq([])
	  end
		
	  it "always returns the caller array"  do
		expect(@an_array.my_each {}).to be(@an_array)
	  end 
		 
	  it "enumerates as many elements as the caller's length" do
		count = 0
		@an_array.my_each { |elem| count += 1 }
		expect(count).to eq(@an_array.length)
	  end

	  it "preserves the values and orders of traversed elements" do
		tmp_array = []
		@an_array.my_each { |elem| tmp_array << elem }
		expect(tmp_array).to eq(@an_array)
	  end
    
	end
	  
  end

  #*** my_select (defined for Array)
  describe "#my_select" do

    it "returns an Enumerator when no block is given" do
	  expect(@an_array.my_select).to be_an_instance_of(Enumerator)
    end
  	
    context "when a block is given" do  

      it "produces an array whose length is at most the caller array's length" do 
		expect(@an_array.my_select { |elem| elem.odd? }.length ).to be <= (@an_array.length)
	  end

      it "returns an empty array when the caller is empty" do
	    expect([].my_select { true } ).to eq([])
	  end
	
	  it "returns an empty array when the block is always false" do 
	    expect(@an_array.my_select { false }).to eq([])
	  end

      it "returns the caller array when the block is always true" do
	    expect(@an_array.my_select { true }).to eq(@an_array)
	  end
	
	  it "returns an array whose elements satisfy the block's condition" do
	    expect(@an_array.my_select { |elem| elem.even? } ).to eq([0, 2, 4, 6, 8])
	  end 
	
    end

  end

  #*** my_all?   (defined for Array)
  describe "#my_all?" do
  
    context "with no block given" do  
      
	  it  "is 'truthy' if all the elements are not false nor nil" do
	    test_array = [1, 'a', true, :a]
	    expect(test_array.my_all?).to be_truthy
	  end
	
	  it  "is 'falsy' if at least one element is false or nil" do
	    test_array = [1, false, 'a', nil]
	    expect(test_array.my_all?).to be_falsy
	  end
	  
    end
  
    context "when a block is given" do  
    
	  it "returns true if the caller array is empty" do   
        expect([].my_all? { }).to be true
	  end

	  it "returns true if the block is always true" do
        expect(@an_array.my_all? { true }).to be true
	  end
	
	  it "returns false if the block is always false" do
	    expect(@an_array.my_all? { false }).to be false
	  end

	  it "returns true if all the elements satisfy the block's condition" do
        expect(@an_array.my_all? { |elem| elem >= 0 }).to be true
	  end

	  it "returns false if at least one element does not satisfy the block's condition" do 
        expect(@an_array.my_all? { |elem| elem < 0 }).to be false
	  end
	
	end
  
  end


  #*** my_count (defined for Array)
  describe "#my_count" do
    
    context "with no block given" do 

      it "returns zero if the caller is empty" do 
	    expect([].my_count).to eq(0)
	  end

      it "returns the caller's length if no argument is given" do 
	    expect(@an_array.my_count).to eq(@an_array.length)
	  end
	  
	  it "returns zero when the given argument is not found in the caller" do
	    expect(@an_array.my_count(-1)).to eq(0)
	  end
	  
	  it "returns the number of caller's elements equal to the given argument" do 
	    test_array = [1, 2, 3, 2, 4, 2, 5, 2, 6, 2, 7]
	    expect(test_array.my_count(2)).to eq(5)
	  end
	  
    end
  
    context "when a block is given" do 

      it "returns zero if the caller is empty" do 
	    expect([].my_count {}).to eq(0)
	  end

      it "returns the caller's length if the block's condition is always true" do 
	    expect(@an_array.my_count { true }).to eq(@an_array.length)
	  end
	  
      it "returns zero if the block's condition is always false" do 
	    expect(@an_array.my_count { false }).to eq(0)
	  end

      it "returns the number of caller's elements that satisfy the block's condition" do 
	    expect(@an_array.my_count { |elem| elem.even? }).to eq(5)
	  end

      context "when an argument is also given" do 
	    it "returns just the number of caller's elements that satisfy the block's condition" do 
	      expect(@an_array.my_count(3) { |elem| elem.odd? }).to eq(5)
		end
	  end
	
    end

  end


  #*** my_map (defined for Array)
  describe "#my_map" do

    context "without a proc argument" do 
    
	  it "returns an Enumerator if caller is empty" do
	    expect([].my_map).to be_an_instance_of(Enumerator)
	  end
	
	  it "returns an Enumerator if caller has elements" do
	    expect(@an_array.my_map).to be_an_instance_of(Enumerator)
	  end
	
    end

    before (:context) do
      @my_proc = Proc.new {|elem| elem += 2}
    end
  
    context "when a proc is given" do

      it "returns an empty array when the caller is empty and there is no block" do
		expect([].my_map(@my_proc)).to eq([])
	  end
	  
	  it "returns an empty array when the caller is empty and a block is given" do
	    expect([].my_map(@my_proc) {}).to eq([])
	  end

	  it "returns the caller's elements modified by the given proc" do
	    expect(@an_array.my_map(@my_proc)).to eq([2, 3, 4, 5, 6, 7, 8, 9, 10, 11])
	  end
	
	  it "returns the caller's elements modified by the given proc and then by the block" do
	    expect(@an_array.my_map(@my_proc) {|elem| elem ** 3}).to eq([8, 27, 64, 125, 216, 343, 512, 729, 1000, 1331])
	  end

      it "produces an array whose length is the same of the caller's length" do 
        expect(@an_array.my_map(@my_proc) {|elem| elem ** 2}.length).to eq(@an_array.length)
	  end

    end

  end

  #*** my_inject (defined on Array)
  describe "#my_inject" do

    it "raises an ArgumentError when the number of arguments is not in range 0..2" do
      expect(lambda {@an_array.my_inject(0, :+, 5)}).to raise_error(ArgumentError)  
    end
  
    context "with two arguments" do
  
      it "raises a TypeError if the second argument is not a symbol" do
	    expect(lambda {@an_array.my_inject(0, 3)}).to raise_error(TypeError)
	  end

	  it "returns the original 'memo' value if caller is empty" do
	    expect([].my_inject(0, :+)).to eq(0)
      end

      it "returns the result of applying 'symbol' as a proc on caller's elements with initial 'memo' value" do
	    expect(@an_array.my_inject(2, :+)).to eq(47)
	  end
	  
    end
	  
    context "with one argument" do

      context "when caller is empty" do
	  
        it "returns nil if 'symbol' is given without a block" do
	      expect([].my_inject(:+)).to be_nil
	    end
		
        it "raises a TypeError if 'memo' is given without a block" do
	      expect(lambda {[].my_inject(0)}).to raise_error(TypeError)
	    end

        it "returns the original 'memo' value" do
	      expect([].my_inject(10) { |memo, elem| memo *= 2 }).to eq(10)
	    end

      end
		
	  context "when caller has elements" do
        
		it "returns the result of aplying the block on caller's elements with initial 'memo' value" do 
		  expect(@an_array.my_inject(0) { |memo, elem| memo += elem }).to eq(45)
        end

		it "returns the result of aplying 'symbol' as a proc on caller's elements with its first element as initial value" do
		  expect(@an_array.my_inject(:+) ).to eq(45)
        end
		
		it "raises a NoMethodError if a symbol is given as a 'memo' for a block" do
	      expect(lambda {@an_array.my_inject(:+) { |memo, elem| memo += 1 } }).to raise_error(NoMethodError)
	    end
      
	  end
	  
    end
  
    context "with no arguments" do

	  it "raises a LocalJumpError when no block is given" do
	    expect(lambda {@an_array.my_inject}).to raise_error(LocalJumpError)
	  end
	
	  context "when a block is given" do
		
		it "returns nil when the caller is empty" do
		  expect([].my_inject { |memo, element| memo += element }).to be_nil
		end

	  	it "returns the result of aplying the block on caller's elements with its first element as initial value" do
		  expect(@an_array.my_inject { |memo, element| memo += element }).to eq(45)
		end
		
	  end
	  
    end

  end

end