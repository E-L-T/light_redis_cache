module LightRedisCache
  class Configuration
    attr_accessor :hostname
    attr_accessor :port

    def initialize
      @hostname = nil
      @port = nil
    end
  end
end
