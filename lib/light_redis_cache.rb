require "light_redis_cache/version"
require "socket"

module LightRedisCache
  class Error < StandardError; end

  class Client
    attr_accessor :socket

    def initialize hostname:, port:
      @hostname = hostname
      @port = port
    end

    def open_socket
      @socket = TCPSocket.new(@hostname, @port)
    end

    # TODO : implement fetch
    # fetch try to get value from redis cache
    # if no value it calls a block and set the result in cache
    # in both cases it returns the value
    def fetch key, &block
      get key
    end

    def get key
      open_socket
      @socket.write("*2\r\n$3\r\nGET\r\n$#{ key.length }\r\n#{ key }\r\n")
      first_result = @socket.gets
      if first_result == "$-1\r\n"
        result = "no value"
      else
        result = @socket.gets.gsub(/\$\d+/, "").gsub("\r\n", "")
        parsed_result = JSON.parse(result)
      end
      @socket.close
      parsed_result
    end

    def set key, value
      open_socket
      value = value.to_json
      @socket.write("*3\r\n$3\r\nSET\r\n$#{ key.length }\r\n#{ key }\r\n$#{ value.length }\r\n#{ value }\r\n")
      result = @socket.gets
      @socket.close
      result
    end
  end
end
