require 'light_redis_cache/version'
require 'light_redis_cache/configuration'
require 'socket'
require 'json'

module LightRedisCache

  class << self
    attr_accessor :socket

    def configure
      yield(configuration)
    end

    def configuration
      @configuration ||= LightRedisCache::Configuration.new
    end

    # Get the value of a key
    #
    # @param [String] key
    # @return [String, Integer, Array, Hash] value
    # @see https://redis.io/commands/get GET command
    def get key
      open_socket
      @socket.write("*2\r\n$3\r\nGET\r\n$#{ key.length }\r\n#{ key }\r\n")
      value = @socket.gets == "$-1\r\n" ? nil : JSON.parse((@socket.gets).gsub("\r\n", "").force_encoding("iso-8859-1").encode!("utf-8"))
      close_socket
      value
    end

    # Set key to hold the value
    #
    # @param [String] key
    # @param [String, Integer, Array, Hash] value
    # @param [Integer] expires_in - default value : 86400 seconds (1 day)
    # @return [nil]
    # @see https://redis.io/commands/set SET command
    def set key, value, expires_in: 86400
      open_socket
      value = value.to_json.encode("iso-8859-1").force_encoding("utf-8")
      @socket.write("*3\r\n$3\r\nSET\r\n$#{ key.length }\r\n#{ key }\r\n$#{ value.length }\r\n#{ value }\r\n")
      @socket.write("*3\r\n$6\r\nEXPIRE\r\n$#{ key.length }\r\n#{ key }\r\n$#{ expires_in.to_s.length }\r\n#{ expires_in }\r\n")
      close_socket
    end

    # Get the value of a key. If the key does not exist,
    # call a block, set the result and return it
    #
    # @param [String] key
    # @param [Integer] expires_in - default value : 86400 seconds (1 day)
    # @param [Proc] block
    # @return [void]
    def fetch key, expires_in: 86400, &block
      result = get(key)
      if result == nil
        value = block.call
        set(key, value, expires_in: expires_in)
        value
      else
        result
      end
    end

    # Remove keys corresponding to matcher
    #
    # @param [String] matcher
    # @return [void]
    def delete_matched matcher
      # get matched keys
      # @see https://redis.io/commands/keys KEYS command

      open_socket
      @socket.puts("KEYS #{ matcher }")
      first_result = @socket.gets

      if first_result.include?("*")
        matched_keys_number = first_result.gsub("*", "").gsub("\r\n", "").to_i
        keys = []
        (1..(matched_keys_number*2)).collect do |index|
          if index.even?
            keys.push((@socket.gets).gsub("\r\n", ""))
          else
            @socket.gets
          end
        end

        # delete matched keys
        # @see https://redis.io/commands/del DEL command

        request = ""
        request_length = 0
        keys.each do |key|
          request.insert(-1, "$#{ key.length }\r\n#{ key }\r\n")
          request_length +=1
        end
        @socket.write("*#{ request_length + 1 }\r\n$3\r\nDEL\r\n#{ request }")
      end
      close_socket
    end

    # Clear database
    #
    # @return [void]
    # @see https://redis.io/commands/flushall FLUSHALL command
    def clear
      open_socket
      @socket.puts("FLUSHALL")
      close_socket
    end

    private

    def open_socket
      @socket = TCPSocket.new(@configuration.hostname, @configuration.port)
    end

    def close_socket
      @socket.close
    end
  end
end
