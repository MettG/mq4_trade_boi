
# Initialize
	# Determine Data Needs (Preset)
	# Save Commands to pull data
	# Wait for data collection

# Data save complete:
	# Extract data from file
	# Create Classes from data
	# Determine if new trade

	
#Indicators
	#Pass necessary data to indicators
	#Retrieve indicator values

#Strategy
	#Pass indicator data into strategy
	#Retrieve calculated action

#Save Action to file
	# open:buy/sell
	# modify:*new stop loss*
	# close:(close one trade on symbol)
	# abort:(cancels ability to trade)

require 'colorize'

require_relative 'order'
require_relative 'data'
require_relative 'listener'

class TradeBoi
	attr_accessor :name
	def initialize(symbol=nil,time_frame=nil)
		unless symbol == nil
			@name = symbol + "_"+ time_frame
			@path = "./data/#{name}/"+name+".txt"
			@c_path = "./data/#{name}/com_"+name+".txt"
		else
			@path = "./data/test.txt"
			@c_path = "./data/c_test.txt"
		end
		@command=""
		@data = MData.new(@path)
		puts "TradeBoi:#{name} Created!".bold.yellow
		start
	end
	def start
		ready
		#Load Data
		@data.collect
		#Determine Action from data
		# If Order, do management
		if @data.has_order?
			if @data.break_even?
				@command = "modify_#{@data.break_even}"
			end
			if @data.move_stop?
				@command = "modify_#{@data.trail_stop}"
			end
			if @data.close_profit?
				@command = "close"
			end
		else
			# If no order, check for entry
			@command = menu
		end
		if @command != nil
			save_command
		else
			sleep(30)
		end

		start
	end

	def menu
		listener = Listen.new(Time.now,30)
		ans = listener.work
		ans
	end

	def ready
		puts "Called ready."
		#Check file for complete, if not, wait for it be
		while true
			# puts "looping...".black
			if check_file('_complete')
				puts "File Ready!".green
				break
			else
				puts "File Not Ready.".red
				sleep(5)
			end
		end
	end

	def check_file(s)
		# returns true if s in data file
		puts "Checking file..."
		i=0
		File.open(@path,'r').each do |line|
			# puts "#{@data.unique?(line.strip.split('_')[1])} " + line.strip.split('_')[1]
			# sleep(1)
			unless @data.unique?(line.strip.split('_')[1])
				if i < 1
					puts "Old Data File!".red
					sleep(5)
					return false
				end
			end
			if line.strip == s
				return true
			end
			i+=1
		end

		return false
	end

	def save_command
		File.write(@c_path,@command)
	end
end

class Program

	def initialize
		puts "Program begin."
		@boys = []
		process
	end

	def add(boy)
		@boys.push(boy.name)
	end

	def exists?(path)
		@boys.include?(path)
	end

	def process
		# Look at each folder within data
		# For each folder, create a new TradeBoi
		puts "Checking for new folders...".black
		Dir.entries('./data').each do |f|
			if !f.include?('.') && !exists?(f)
				arr = f.split('_')
				add(TradeBoi.new(arr[0],arr[1]))
			end
		end
		sleep(10)
		process
	end

end

# Test
Program.new





