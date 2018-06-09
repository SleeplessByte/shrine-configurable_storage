# shrine-configurable_storage

Register Shrine storages using a key and lazy configure that storage later.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'shrine-configurable_storage'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shrine-configurable_storage

## Usage

Setup your configurable, lazy, dynamic storage by adding the plugin and calling configure.

```Ruby
require 'shrine/plugins/configurable_storage'

class MyUploader < Shrine
  plugin :configurable_storage
  configurable_storage_name :foo
end

# Somewhere else
Shrine::Plugins::ConfigurableStorage.configure |config| do
  config[:foo] = {
    cache: Shrine::Storage::FileSystem.new(...),
    store: Shrine::Storage::S3.new(...)
  }
end
```

You can use the `:default` key (`config[:default] =`) to add fallback storage(s). You can add as many storages as you
want, and just like before, you're not limited to cache and store. When finding a storage, the name will be used to find
the set of storages and fallback to `:default`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can
also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the
version number in `shrine-configurable_storage.gemspec.rb`, and then run `bundle exec rake release`, which will create
a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/SleeplessByte/shrine-configurable_storage.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Shrine::ConfigurableStorage project’s codebases, issue trackers, chat rooms and mailing
lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/shrine-configurable_storage/blob/master/CODE_OF_CONDUCT.md).
