# LightRedisCache


This gem is a very basic implementation of a Ruby client for Redis.

It is not supposed to be used in production, the aim of this gem is to understand of Redis work and how to implement a Redis client to cache data.

It creates a TCP socket between your app and your Redis server. A few methods let you communicate with your Redis server using a protocol called RESP (REdis Serialization Protocol). See https://redis.io/topics/protocol

In a Rails app, just use `LightRedisCache` instead of `Rails.cache`.

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

## Configuration
Add this block, with the configuration of your Redis server, in your code :

```ruby
LightRedisCache.configure do |config|
  config.hostname = 'MY_HOSTNAME' # default: 'localhost'
  config.port = 'MY_PORT' # default: '6379'
end
```
If you have a Rails app, it should go in `config/initializers/light_redis_cache.rb`

## Development

After checking out the repo, run `bin/setup` to install dependencies.

Set the config of the local redis server you want to use for the tests in `spec/local_redis_server.rb`.

Then, run `rake spec` to run the tests.
