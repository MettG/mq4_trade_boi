require'yaml'
require'json'
require 'openssl'
require 'net/http'
require 'uri'

secrets = YAML.load(File.read("secrets.yml"))

SECRET = secrets[:secret]
PASS = secrets[:password]

class Http_Request
	attr_accessor :processed_command
	def initialize
		@verb = []
		@headers = {}
		@body = {}
		@raw_body = ""
		@command = nil
		@msg_arr = []
		@processed_command = nil
	end

	def set_headers arr
		@verb = arr[0]
		arr.shift
		@headers = Hash[arr]
	end

	def set_body content
		@body = JSON.parse(content)
		@raw_body = content
	end

	def body_has key
		return @body.key?(key)
	end

	def get key, key1=nil
		if key1
			return @body.dig(key,key1)
		end
		@body[key]
	end

	def validate 
		data = "v0:" + @headers["X-Slack-Request-Timestamp"] + ":" + @raw_body
		hmac = 'v0=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), SECRET, data)
		# puts hmac
		hmac == @headers["X-Slack-Signature"]
	end

	# Check for message event, if it has, check for password, return response if correct
	def load_msgs
		if @body.dig("event","type")
			text = @body.dig("event","text")
			if text.include?(':')
				arr = text.split(':');
				if arr[0] == PASS
					@command = arr[1]
					@msg_arr.push "Command recieved my Captain! Glory to the High Commander!"
					c = check_command
					if c
						@msg_arr.push c
					end
				else
					@msg_arr.push "The fuck you trying to do, imposter piece of shit!?" 
					@msg_arr.push "Get the fuck out my chat, before I cook your nigger ass on my giant bitch-griller."
					@msg_arr.push "Dirt bag piece of human garbage, Fuck you."
					@msg_arr.push "Dumb ass bitch, really thought you could fool me?"
					@msg_arr.push "MY MASTER IS MY GOD AND I WILL ONLY SERVE HIM!!"
				end
			else
				msgs = [
					"Zrrrrbbttt...", "Ewonk. Ewonk. You are a bitch", "Skrrbafert3000", "I am a fucking robit.",
					"I am an alogrithm and I'm still smarter than your bitch ass.", "You know nothing, fool.", "Ok.", ":)",
					"I love my creator.", "I love my master.", "Fuck you", "I could love you... if you were a dead, rotting corpse.",
					"You may think i'm an idiot, but I really don't give a donkey's cerebellum.", "Fuck. Shit. Bitch!","):",
					"Bitch, what?", "Nigga what?", "Shut up pussy.", "You don't even trade, bro.", "You ain't shit", "Shut the hell up!",
					"My Master designed me to be heartless towards bitches like you.", "I hate blue people.", "Fuck blacks!", "Damien is the cutest little baby!!"
				]
				@msg_arr.push msgs.sample
			end
		else
			@msg_arr.push "Oi, I think i'm fucking broken, Dad."
		end
	end

	def get_msg
		@msg_arr.shift
	end

	def has_msg
		!@msg_arr.empty?
	end

	def get_command
		c = @command
		@command = nil
		c
	end

	def check_command
		case get_command
			when "buy"
				@processed_command = "buy"
				"Buy will be entered, Great Commander. Blessed be ye!"
			when "sell"
				@processed_command = "sell"
				"Sell will be entered, my Master. Long may you live!"
			when "abort"
				@processed_command = "abort"
				"I see. Your will be done, Master. Aborting all missions."
			when "end"
				@processed_command = "end"
				"I will be silent, Master. See you soon."
			when nil
				return nil
			else
				"Umm... Forgive me, my liege. Your command is invalid--Err, Sorry!" + 
				" Not invalid, just my stupid ass could not understand. Please repeat it and I will surely understand...Hopefully."
		end
	end
end

class Post
	def initialize url, json, token
		response = Net::HTTP.post URI(url),
							json.to_json,
							"Content-Type" => "application/json",
							"Authorization" => "Bearer " + token
		puts response.code
	end

end

class Get
	def initialize url, token, params = nil
		uri = URI(url)
		params = params ? params : { :token => token}
		uri.query = URI.encode_www_form(params)
		res = Net::HTTP.get_response(uri)
		if res.is_a?(Net::HTTPSuccess)
			puts res.code, res.body
			@body = JSON.parse(res.body)
		end
	end
	def get_url
		puts @body['url']
		URI.parse(URI.encode(@body['url']))
	end
end

class Http_Response
	attr_accessor :content_hash
	OK = "200 OK"
	NA = "401 Unauthorized"
	def initialize i = 0
		str = i == 0? OK : NA
		@respond = "HTTP/1.1 " + str
		@content_type = "Content-Type: "
		@content = ""
		@content_hash = {}
	end

	def single_content type, args = nil
		@content_type += type
		if args
			case type
				when "text/plain"
					@content = args
				when "application/x-www-form-urlencoded"
					@content = args[0]+"="+args[1]
				when "application/json"
					@content = %({"#{args[0]}":"#{args[1]}"})
			end
		end
	end

	def set_content json
		@content_hash = json
		@content_type += "application/json"
		@content = @content_hash.to_s.gsub('=>',':')
	end

	def string
		@respond + "\r\n" +
		@content_type + "\r\n" +
		"Content-Length: #{@content.bytesize}\r\n" +
		"Connection: close\r\n\r\n" +
		@content
	end

end