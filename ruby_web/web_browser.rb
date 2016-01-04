require 'socket'
require 'json'


def prompt_request
  ans = ''
  loop do
    print "\nChoose your request type ([1] GET - [2] POST): "
	ans = gets.chomp.upcase
	break if ['1', '2'].include? ans
	puts "Invalid type! Try again..."
  end
  ans.to_i
end

REQUESTS = {1 => 'GET', 2 => 'POST'}

host = 'localhost'					# The web server
port = 3000							# Default HTTP port
path = ''
headers = ''
body = ''

# Ask for the request type
request_type = REQUESTS[prompt_request]

# Build the request
case request_type
  when 'GET'
    print "\nEnter the filename/resource to GET (format: name.ext): "
	path = '/' + gets.chomp
  when 'POST'
    print "\nEnter the Viking's name: "
	viking_name = gets.chomp
	print "\nEnter the Viking's e-mail: "
	viking_email = gets.chomp
	path = "/simple_server.rb"
	
	body = { :viking => { :name => viking_name, :email => viking_email } }.to_json
	headers << "Content-Length: #{body.length}\r\n"
end

# This is the HTTP request we send 
request = "#{request_type} #{path} HTTP/1.0\r\n"
request << headers + "\r\n" + body

TCPSocket.open(host, port) do |socket|		# Connect to server

  socket.print(request)				# Send request
  socket.close_write
  response = socket.read			# Read complete response

  # Split response into header and body
  headers, body = response.split("\r\n\r\n", 2)

  expr = /\A(HTTP\/[\d.]+) (\d{3}) ([\w ]+)\s{1,2}(?:[\S ]+\s{,2})*Content-Length: (\d+)/
  _, version, status_code, reason, size = headers.match(expr).to_a

  puts
  puts "Received #{size} characters from the server\nStatus code: #{status_code} - #{reason}"
  puts "\n" + (status_code.to_i == 200 ? "Content received:" : "Description message:")
  puts body
  puts
  puts "Connection ended."

end

