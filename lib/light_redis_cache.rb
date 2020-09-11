require "light_redis_cache/version"
require "socket"

module LightRedisCache
  class Error < StandardError; end

  class Client
    attr_accessor :socket

    def initialize hostname:, port:
      @socket = TCPSocket.new(hostname, port)
      @hostname = hostname
      @port = port
    end
  end
end
