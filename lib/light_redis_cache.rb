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

    def fetch key, expires_in: 1.day, &block
      result = get(key)
      if result == "no value"
        value = block.call
        set(key, value, expires_in: expires_in)
        value
      else
        result
      end
    end

    # TODO : implement a delete_matched method with https://redis.io/commands/keys

    private

    def open_socket
      @socket = TCPSocket.new(@hostname, @port)
    end

    def close_socket
      @socket.close
    end

    def get key
      open_socket
      @socket.write("*2\r\n$3\r\nGET\r\n$#{ key.length }\r\n#{ key }\r\n")
      first_result = @socket.gets
      if first_result == "$-1\r\n"
        result = "no value"
      else
        result = JSON.parse(@socket.gets.gsub(/\$\d+/, "").gsub("\r\n", ""))
      end
      close_socket
      result
    end

    def set key, value, expires_in:
      open_socket
      value = value.to_json
      @socket.write("*3\r\n$3\r\nSET\r\n$#{ key.length }\r\n#{ key }\r\n$#{ value.length }\r\n#{ value }\r\n")
      @socket.write("*3\r\n$6\r\nEXPIRE\r\n$#{ key.length }\r\n#{ key }\r\n$#{ expires_in.seconds.to_s.length }\r\n#{ expires_in.seconds.to_i }\r\n")
      close_socket
    end
  end
end
