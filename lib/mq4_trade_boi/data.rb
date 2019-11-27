class MData
	attr_accessor :order
	def initialize(path)
		@serial = 0
		@highs = []
		@lows = []
		@ask = 0
		@bid = 0
		@pip = 0
		@atr = 0
		@basis = 0
		@seconds = 0
		@path = path
		@order = nil
	end
	def collect
		File.open(@path, 'r').each do |line|
			arr = line.strip.split('_')
			case arr[0].downcase
				when 'serial'
					@serial = arr[1].to_i
				when 'atr'
					@atr = arr[1].to_f
				when 'ask'
					@ask = arr[1].to_f
				when 'bid'
					@bid = arr[1].to_f
				when 'pip'
					@pip = arr[1].to_f
				when 'ordernumber'
					if arr[1] == '0'
						next
					end
					if arr[2] != nil && arr[3] != nil && arr[4] != nil
						@order = Order.new(arr[1].to_f, arr[2].to_f,arr[3].to_f, arr[4].to_f)
					else
						puts "Order not saved, 0 value recieved. Order currently managed?".black
					end
				when 'low'
					@lows[0] = arr[1].to_f
				when 'lastlow'
					@lows[1] = arr[1].to_f
				when 'high'
					@highs[0] = arr[1].to_f
				when 'lasthigh'
					@highs[1] = arr[1].to_f
				when 'secondssince'
					@seconds = arr[1].to_f
				when 'basis'
					@basis= arr[1].to_f
				when 'complete'
					break
			end
		end
	end
	def recently_closed?
		@seconds / 60 <= 5
	end
	def unique?(serial)
		if @serial == 0
			return true
		end
		# puts "New #{serial} | Old #{@serial}"
		serial.to_i != @serial
	end
	def has_order?
		@order != nil
	end
	def move_stop?
		return (@order.dir == -1 && @ask < @order.take && @highs[1] < @order.take) ||
					(@order.dir == 1 && @bid > @order.take && @lows[1] > @order.take)
	end
	def break_even?
		return (@order.dir == -1 && @ask <= @order.take) ||
					(@order.dir == 1 && @bid >= @order.take)
	end
	def close_profit?
		return (@order.dir == -1 && @ask > @basis) ||
					(@order.dir == 1 && @bid < @basis)
	end
	def break_even
		e = @order.open + 30 * @pip;
		if @order.dir == -1
			e = @order.open - 30 * @pip;
		end
		e
	end
	def trail_stop
		@order.take
	end
	def buy_stop
		@lows[1] - 1.5 * @atr
	end
	def sell_stop
		@highs[1] + 1.5 * @atr
	end
	def buy_take
		@ask + 1.1 * @atr
	end
	def sell_take
		@bid - 1.1 * @atr
	end
end