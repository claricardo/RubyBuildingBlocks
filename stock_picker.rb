=begin
Method for selecting the best days to buy/sell stocks from a set of prices.
The algorithm assumes:
	* A non-empty array of stock prices
	* There should be prices for at least a couple of days
Parameters:
	stock_prices: an array of day-indexed stock prices
Return: 
	An array of two days representing [best_day_to_buy, best_day_to_sell] for a maximum profit.
	[nil, nil] is returned whether the array is empty or contains less than two items (prices)
=end
def stock_picker(stock_prices)
	max_profit = -Float::INFINITY
	best_buy_day, best_sell_day = nil
	(stock_prices.length-1).times do |idx|
		sell_day = stock_prices.index(stock_prices[idx+1...stock_prices.size].max)
		profit = stock_prices[sell_day] - stock_prices[idx]
		if profit > max_profit
			max_profit = profit
			best_buy_day = idx
			best_sell_day = sell_day
		end
	end
	[best_buy_day, best_sell_day]
end

# Testing with a fixed set of stock prices
prices = [17,3,6,9,15,8,6,1,10]
days = stock_picker(prices)
buy_str = "%d ($%d)" % [days[0], prices[days[0]]]
sell_str = "%d ($%d)" % [days[1], prices[days[1]]]
profit_str = "$%d" % (prices[days[1]] - prices[days[0]])
puts "\nTest #1"
puts "Stock prices: " + prices.to_s
puts "Selected days: " + days.to_s
puts "You should buy on day #{buy_str} and sell on day #{sell_str} for a profit of #{profit_str}"
puts

# Testing with a set of 20 randomly generated stock prices
prices = Array.new(20) {rand(50..500)}
days = stock_picker(prices)
buy_str = "%d ($%d)" % [days[0], prices[days[0]]]
sell_str = "%d ($%d)" % [days[1], prices[days[1]]]
profit_str = "$%d" % (prices[days[1]] - prices[days[0]])
puts "\nTest #2"
puts "Stock prices: " + prices.to_s
puts "Selected days: " + days.to_s
puts "You should buy on day #{buy_str} and sell on day #{sell_str} for a profit of #{profit_str}"
    