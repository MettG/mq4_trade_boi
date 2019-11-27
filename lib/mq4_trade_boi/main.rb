
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
require 'timeout'
require_relative 'order'
require_relative 'data'

class TradeBoi
	attr_accessor :@path
	def initialize(symbol=nil,time_frame=nil)
		unless symbol == nil
			name = symbol + "_"+ time_frame
			@path = "./data/#{name}/"+name+".txt"
			@c_path = "./data/#{name}/com_"+name+".txt"
		else
			@path = "./data/test.txt"
			@c_path = "./data/c_test.txt"
		end
		@command=""
		@data = MData.new(@path)
		start
	end
	def start
		ready
		#Load Data
		@data.collect
		#Determine Action from data
		if @data.recently_closed?
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
			end
		end
		start
	end

	def menu
		puts "Enter Order?".bold.green
		ans = nil
		begin
			Timeout::timeout 15 do
				while true
					print "Buy/Sell > ".bold.white
					case gets.strip.downcase
						when 'b','buy'
							ans = "buy_#{@data.buy_stop}_#{@data.buy_take}"
							break
						when 's','sell'
							ans = "sell_#{@data.sell_stop}_#{@data.sell_take}"
							break
						when 'n','no'
							break
						when 'q','quit','exit'
							puts "Are you sure you want to Abort Program!?".bold.red
							print "(Y/N) > ".white
							if gets.strip.downcase == 'y'
								exit
							else
								puts "Exit canceled, no order made.".bold.yellow
								break
							end
					end
				end
			end
		rescue Timeout::Error
			ans = nil
		end
		unless ans
			puts "No Order Entered.".bold.red
		else
			puts "#{ans.capitalize} Order will be Entered!".bold.yellow
		end
		ans
	end

	def ready
		#Check file for complete, if not, wait for it be
		while true
			if check_file('_complete')
				puts "File Ready!".green
				break
			end
			puts "File Not Ready.".red
			sleep(1)
		end
	end

	def check_file(s)
		# returns true if s in data file
		puts "Checking file..."
		File.open(@path,'r').each do |line|
			# puts "#{@data.unique?(line.strip.split('_')[1])} " + line.strip.split('_')[1]
			# sleep(1)
			unless @data.unique?(line.strip.split('_')[1])
				puts "Old Data File!".red
				sleep(5)
				return false
			end
			if line.strip == s
				return true
			end
		end

		return false
	end

	def save_command
		File.write(@c_path,@command)
	end
end

class Program

	def initialize
		@boys = []
		process
	end

	def add(boy)
		@boys.push(boy.path)
	end

	def exists?(path)
		@boys.include?(path)
	end

	def process
		# Look at each folder within data
		# For each folder, create a new TradeBoi

		Dir.entries('./data').each do |f|
			if !f.include?('.') && !exists?(path)
				arr = f.split('_')
				add(TradeBoi.new(arr[0],arr[1]))
			end
		end
		sleep(10)
		process
	end

end







