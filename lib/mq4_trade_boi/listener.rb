require 'yaml'
require 'socket'
require 'json'
require_relative 'http_req_resp'

secrets = YAML.load(File.read("secrets.yml"))

BOT_TOKEN = secrets[:bot_token]
class Listen
	def initialize time, out
		port = 2020
		@server = TCPServer.new port
		@timeout = time + out
	end
	def work
		command = nil
		obj = { 
			"text" =>
				"*BOT ONLINE*\n_Time Remaining = 00:#{(@timeout - Time.now).round}_", 
			"channel" => "DR2A3F448", "as_user" => true 
		}
		Post.new 'https://slack.com/api/chat.postMessage', obj, BOT_TOKEN
		puts "Hello sent."
		loop do
			puts "Waiting for data..."
			begin
				socket = @server.accept_nonblock
			rescue
				if(Time.now >= @timeout)
					puts "Connection timed out, exiting server loop."
					break;
				end
				# No connection, retrying...
				retry
			end
			# puts "Awaiting connection..."
			# socket = @server.accept
			puts "Data recieved..."
			# Read data, parse into easily readable content

			ready = IO.select([socket], nil, nil, 3)
			headers = []
			content = ""
			length = 0
			if ready
				begin
					while true
						r = ""
						# Read until end of line
						until r.include?("\n")
							r += ready[0][0].readpartial(1)
						end

						# Parse headers into neat array
						headers.push(r.gsub("\r\n", "").split(": "))

						# Save content length
						if r.include?("Content-Length")
							length = r.split(' ')[1].to_i
						end

						# Check for end of header if so, read and save content, then close reading
						if r == "\r\n" || r.include?("\r\n\r\n")
							content = ready[0][0].readpartial(length)
							puts "done reading data."
							ready[0][0].close_read
							break
						end
					end
				rescue
					# An unexpected exception was raised - the connection is no good.
					socket.close
					raise
				end
			else
				# IO.select returns nil when the socket is not ready before timeout 
				# seconds have elapsed
				socket.close
				raise "Connection timeout"
			end
			# Remove empty header from headers array
			headers.pop
			# Build request

			request = Http_Request.new
			request.set_headers headers
			request.set_body content
		
			# puts JSON.pretty_generate(JSON.parse(content))
			code = request.validate ? 0 : 1
			
			response = Http_Response.new code
			
			if code > 0
				socket.send response.string, 0
				puts "Unauthorized request denied."
				socket.close
				next
			end
			
			if request.body_has("challenge")
				body = JSON.parse(content)
				response.single_content 'application/json', ["challenge", body["challenge"]]
			end

			#Increase timeout, to continue conversation
			@timeout+=5

			#Send immediate response
			# puts response.string
			socket.send response.string, 0
			puts "Acknowledgement Response sent."

			
			#Send Msg/Data response
			if request.body_has("event") && !request.get("event", "bot_id")
				request.load_msgs
				channel = request.get "event", "channel"
				while request.has_msg
					text = request.get_msg
					obj = { 
						"text" =>
							text+"\r\n\n_Time Remaining = 00:#{(@timeout - Time.now).round}_", 
						"channel" => channel, "as_user" => true 
					}
					# puts obj
					Post.new 'https://slack.com/api/chat.postMessage', obj, BOT_TOKEN
					puts "Data Response sent."
					sleep(1.25)
				end
			end
			socket.flush
			socket.close
			puts "Connection finished."
			command = request.processed_command
			if command
				break;
			end
		end

		obj = { 
			"text" =>
				"*BOT OFFLINE*", 
			"channel" => "DR2A3F448", "as_user" => true 
		}
		Post.new 'https://slack.com/api/chat.postMessage', obj, BOT_TOKEN
		puts "Goodbye sent."
		puts "command gathered #{command}"
		case command
			when "abort"
				exit!
			when "end"
				return nil
		end
		command
	end
end

# puts Listen.new(Time.now,30).work == nil