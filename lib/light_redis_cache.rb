require "light_redis_cache/version"
require "socket"

module LightRedisCache
  class Error < StandardError; end

  class Client
    attr_accessor :socket

    def initialize hostname:, port:
      @socket = TCPSocket.new(hostname, port)
    end

    # TODO : implement fetch
    # fetch try to get value from redis cache
    # if no value it calls a block and set the result in cache
    # in both cases it returns the value
    def fetch key, &block
      get key
    end

    private

    def get key
      @socket.write("*2\r\n$3\r\nGET\r\n$#{ key.length }\r\n#{ key }\r\n")

      "#{@socket.gets + @socket.gets}".gsub(/\$\d+/, "").gsub("\r\n", "")
    end

    def set key, value
    end
  end
end
