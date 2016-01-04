require 'socket'		
require 'json'

port = 3000								# Port to listen

server = TCPServer.open(port)   # Socket to listen on port 
puts "Server initialized."
loop do										# Server run forever
  puts "\nWaiting for a connection..."
  client = server.accept				# Wait for a client to connect
  puts "Connection accepted."
  
  request = ''
  while !client.eof
    line = client.gets
    request << line
  end
  
  expr = /\A([A-Z]+) (.+) (HTTP\/[\d\.]+)/
  headers, body = request.split("\r\n\r\n", 2)
  _, method, path, version = headers.match(expr).to_a
  
  
  filename = '.' + path
  status_code = 0
  reason = ''
  
  puts "Request received - #{method}" 
  
  case method
    when 'GET'
	  if File::exist?(filename)
	    puts "File requested exists."
	    status_code = 200
	    reason = 'OK'
	    body = File.open(filename, 'r').read
      else
        puts "File requested not found."
        status_code = 404
	    reason = 'Not Found'
	    body = "The requested resource was not found at the specified location"
      end
	when 'POST'
	  status_code = 200
	  reason = 'OK'
	  params = {}; 
	  params.merge!(JSON.parse(body))
	  
	  body = File.open("./thanks.html", 'r').read
	  body.gsub!("<%= yield %>") do |match|
	    str = ''
	    params.each_value do |value|
		  value.each { |k,v| str << "<li>#{k.to_s.capitalize}: #{v}</li>" }
		end
		str
	  end
  end
  
  header = "#{version} #{status_code} #{reason}\r\n"
  header << "Content-type: text/html\r\n"
  header << "Content-Length: #{body.length}\r\n\r\n"
  
  puts "Sending response to the client..."
  client.puts(header + body)   # Send the response to the client
  
  puts "Closing the connection..."
  client.close							# Disconnect from the client
end

server.close