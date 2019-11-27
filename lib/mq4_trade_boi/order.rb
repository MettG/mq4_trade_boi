class Order
	attr_accessor :dir, :open, :stop, :take
	def initialize(dir,open,stop,take)
		@dir = dir
		@open = open
		@stop = stop
		@take = take
	end
end