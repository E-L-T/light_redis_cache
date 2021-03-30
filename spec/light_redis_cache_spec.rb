require 'local_redis_server'

RSpec.describe LightRedisCache do
  # Set the hostname and the port of a local Redis server in `spec/local_redis_server.rb` to run the tests
  # let!(:client) { LightRedisCache::Client.new(hostname: LocalRedisServer::HOSTNAME, port: LocalRedisServer::PORT) }

  LightRedisCache.configure do |config|
    config.hostname = LocalRedisServer::HOSTNAME
    config.port = LocalRedisServer::PORT
  end

  before(:each) { LightRedisCache.clear }

  describe '.set' do
    it 'sets a key and a value and return nil' do
      expect(LightRedisCache.set('a', 'b', expires_in: 1000)).to eq nil
    end
  end

  describe '.get' do
    it 'gets the value of a key if key is found' do
      LightRedisCache.set('a', 'b', expires_in: 1000)
      expect(LightRedisCache.get('a')).to eq 'b'
      LightRedisCache.set('my_hash', {"key"=> "value"}, expires_in: 1000)
      expect(LightRedisCache.get('my_hash')).to eq({"key"=> "value"})
    end

    it 'returns nil if key is not found' do
      expect(LightRedisCache.get('unknown_key')).to eq nil
    end
  end

  describe '.fetch' do
    it 'returns and set block value if key is not found' do
      expect(LightRedisCache.get('a')).to eq nil
      expect(LightRedisCache.fetch('a') { 'b' }).to eq 'b'
      expect(LightRedisCache.get('a')).to eq 'b'
    end

    it 'returns value and does not call block if key is found' do
      expect(LightRedisCache.fetch('a') { 'b' }).to eq 'b'
      expect(LightRedisCache.fetch('a') { 'c' }).to eq 'b'
    end

    it 'sets an expiration time' do
      expect(LightRedisCache.fetch('a', expires_in: 1) { 'b' }).to eq 'b'
      expect(LightRedisCache.fetch('a', expires_in: 1) { 'c' }).to eq 'b'
      sleep 1
      expect(LightRedisCache.fetch('a') { 'c' }).to eq 'c'
    end
  end

  describe '.delete_matched' do
    it 'deletes the matched keys' do
      LightRedisCache.set('chblai36', '11', expires_in: 1000)
      LightRedisCache.set('chblai52', '22', expires_in: 1000)
      LightRedisCache.set('argh28', '33', expires_in: 1000)
      LightRedisCache.delete_matched('*chblai*')
      expect(LightRedisCache.get('chblai36')).to eq nil
      expect(LightRedisCache.get('chblai52')).to eq nil
      expect(LightRedisCache.get('argh28')).to eq '33'
    end
  end

  describe '.clear' do
    it 'flushes all database' do
      LightRedisCache.set('a', 'b', expires_in: 1000)
      LightRedisCache.set('c', 'd', expires_in: 1000)
      expect(LightRedisCache.get('a')).to eq 'b'
      expect(LightRedisCache.get('c')).to eq 'd'
      LightRedisCache.clear
      expect(LightRedisCache.get('a')).to eq nil
      expect(LightRedisCache.get('c')).to eq nil
    end
  end
end
