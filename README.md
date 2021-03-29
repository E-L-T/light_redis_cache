# LightRedisCache


It is a very basic implementation of a Redis client ( !!! do not to use it in production !!! ).

The aim of this gem is to understand of Redis work and how to implement a redis client to cache data.
It can replace `Rails.cache` to connect to Redis in a Ruby on Rails application.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'light_redis_cache'
```

And then execute:
```
$ bundle
```

Or install it yourself as:
```
$ gem install light_redis_cache
```

## Usage

## Development

After checking out the repo, run `bin/setup` to install dependencies.

Set the config of the local redis server you want to use for the tests in `spec/local_redis_server.rb`.

Then, run `rake spec` to run the tests.
