require 'jumpstart_auth'
require 'bitly'
require 'klout'

class MicroBlogger
  attr_reader :client
  
  def initialize
    puts "Initializing MicroBlogger..."
	@client = JumpstartAuth.twitter
	
	Bitly.use_api_version_3
	Klout.api_key = 'xu9ztgnacmjx3bu82warbr3h'
  end
  
  def run
    puts "Welcome to the JSL Twitter Client!"
	
	command = ''
	while command != 'q'
	  printf "Enter command: "
	  input = gets.chomp
	  parts = input.split(' ')
	  command = parts[0]
	  case command
	    when 'q' then puts "Goodbye!"
		when 't' then tweet(parts[1..-1].join(' '))
		when 'dm' then dm(parts[1], parts[2..-1].join(' '))
		when 'spam' then spam_my_followers(parts[1..-1].join(' '))
		when 'elt' then everyones_last_tweet
		when 's' then shorten(parts[1])
		when 'turl' then tweet(parts[1..-2].join(' ') + ' ' + shorten(parts[-1]))
		else
		  puts "Sorry, I don't know how to #{command}"
	  end
	end
  end
  
  def tweet(message)
    if message.length > 140
	  puts "ERROR: Your message is #{message.length} characters long (max. allowed is 140)!"
	  return
	end
	@client.update(message)
  end
  
  def dm(target, message)
    screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
	
	if !screen_names.include? target
	  puts "ERROR: You can only send direct messages to people who follow you!"
	  return
	end
  
    puts "Trying to send #{target } this direct message:"
	puts message
	message = "d @#{target} #{message}"
	tweet(message)
  end
  
  def followers_list
    screen_names = []
	@client.followers.each do |follower|
	  screen_names << @client.user(follower).screen_name
	end
	screen_names
  end
  
  def spam_my_followers(message)
    followers_list.each { |follower| dm(follower, message) }
  end
  
  def everyones_last_tweet
    friends = @client.friends
	friends = friends.sort_by { |friend| @client.user(friend).screen_name.downcase }
	
	friends.each do |friend|
	  friend_data = @client.user(friend)
	  name = friend_data.screen_name
	  timestamp = friend_data.status.created_at.strftime("%A, %b %d %Y")
	  message = friend_data.status.text
	  puts "#{name} said this on #{timestamp}...\n#{message}"
	  puts
	end
  end
  
  def shorten(original_url)
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
	shrt_url = bitly.shorten(original_url).short_url
	
	puts "Shortening URL #{original_url} as: #{shrt_url}"
    return shrt_url
  end
  
  def klout_score
    friends = @client.friends.collect { |friend| @client.user(friend).screen_name }
	puts "Friends' Klout scores:"
	friends.each do |friend|
	  identity = Klout::Identity.find_by_screen_name(friend)
	  puts "#{friend}: #{Klout::User.new(identity.id).score.score}"
	  puts
	end
  end
end
 
blogger = MicroBlogger.new
blogger.run

#blogger.klout_score