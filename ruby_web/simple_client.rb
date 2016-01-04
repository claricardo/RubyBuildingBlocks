require 'socket'		# Get sockets from stdlib

hostname = 'localhost'
port = 3000

# Open a socket on the specified host and port
s = TCPSocket.open(hostname, port)	

while line = s.gets		# Read lines from the socket
  puts line.chop		# Print with platform line terminator
end
s.close					# Close the socket when done
  