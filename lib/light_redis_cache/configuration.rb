module LightRedisCache
  class Configuration
    attr_accessor :hostname
    attr_accessor :port

    def initialize
      @hostname = 'localhost'
      @port = '6379'
    end
  end
end
