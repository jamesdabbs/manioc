# Gestalt


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gestalt'
```

## Usage

Gestalt exposes two main utility classes: `Struct` and `Container`.

A struct is a simple stateless object with transparently inverted dependencies:

```
class Service < Gestalt[:http, :logger]
end

real = Service.new(http: HTTP::Client.new, logger: Logger.new)
fake = Service.new(http: double('http'), logger: double('logger'))

[real, fake].sample.logger.info "..."
```

A container makes it easy to declare and customize the interdependencies between various structs:

```
dev = Gestalt::Container.new do
  http          { HTTP::Client.new }
  logger        { Logger.new STDOUT }
  error_handler { ->(e) { logger.error e } }
end

test = dev.with do
  http { instance_double HTTP::Client }
end

prod = dev.with do
  error_handler { ->(e) { Rollbar.error e } }
end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/gestalt. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

