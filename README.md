# Mq4TradeBoi

This gem works as a better interactive server to the MT4 interface. How it works:
    Main.rb is initiated, it looks for a data folder created by the EA, creating a new trade boi instance for each folder
    The EA is intigated, it creates a folder for a specific symbol and time frame, and saves specific data to a file
    Ruby will read the data file, and determine user specified order management (Default is my own order management strategy)
    Ruby is also connected to a slack server and can recieve commands to buy/sell or close trades from anywhere slack recieves data
    Ruby will save all commands to a file, which then the EA reads and performs commands to manage orders
    The EA will save all errors and certains errors will be messaged through the slack to the designated user

    ## Future Updates Will Include ##
        Automated Error Management
        Trade Signals
        Account info data file
        Better info through slack commands
        Better documentation and flexibility of order management strategies
        Algorithmic trading

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mq4_trade_boi'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mq4_trade_boi

## Usage

Write your own order management logic in data.rb and specify which data to save in mql4 main file, all mql4 objects are in objects.lib to easily gather data. MAKE SURE TO SPECIFIY WHERE THE DATA IS BEING SAVED (create a new folder called 'data') And check main.rb to see how the program reads from the folder to build a new instance of Trade Boi.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/MettG/mq4_trade_boi. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Mq4TradeBoi project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/mq4_trade_boi/blob/master/CODE_OF_CONDUCT.md).
