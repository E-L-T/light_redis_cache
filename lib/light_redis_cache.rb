require 'light_redis_cache/version'
require 'socket'
require 'json'
require 'date'

module LightRedisCache
  class Client
    attr_accessor :socket

    def initialize hostname:, port:
      @hostname = hostname
      @port = port
    end

    def get key
      open_socket
      @socket.puts("GET #{ key }")
      value = @socket.gets == "$-1\r\n" ? nil : JSON.parse(@socket.gets.gsub(/\$\d+/, "").gsub("\r\n", ""))
      close_socket
      value
    end

    def set key, value, expires_in:
      open_socket
      value = value.to_json
      @socket.write("*3\r\n$3\r\nSET\r\n$#{ key.length }\r\n#{ key }\r\n$#{ value.length }\r\n#{ value }\r\n")
      @socket.write("*3\r\n$6\r\nEXPIRE\r\n$#{ key.length }\r\n#{ key }\r\n$#{ expires_in.to_s.length }\r\n#{ expires_in }\r\n")
      close_socket
    end

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

    def delete_matched matcher
      #get matched keys
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

        #delete keys
        request = ""
        request_length = 0
        keys.each do |key|
          request.insert(-1, "$#{ key.length }\r\n#{ key }\r\n")
          request_length +=1
        end
        @socket.puts("*#{ request_length + 1 }\r\n$3\r\nDEL\r\n#{ request }")
      end
      close_socket
    end

    def clear
      open_socket
      @socket.puts("FLUSHALL")
      close_socket
    end

    private

    def open_socket
      @socket = TCPSocket.new(@hostname, @port)
    end

    def close_socket
      @socket.close
    end
  end
end
