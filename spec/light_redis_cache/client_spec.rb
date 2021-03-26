require 'date'

RSpec.describe LightRedisCache::Client do
  # Set the hostname and the port of a local Redis server in `spec/local_redis_server.rb` to run the tests
  let!(:client) { LightRedisCache::Client.new(hostname: LocalRedisServer::HOSTNAME, port: LocalRedisServer::PORT) }

  before(:each) { client.clear }

  describe '.set' do
    it 'sets a key and a value and return nil' do
      expect(client.set('a', 'b', expires_in: 1000)).to eq nil
    end
  end

  describe '.get' do
    it 'gets the value of a key if key is found' do
      client.set('a', 'b', expires_in: 1000)
      expect(client.get('a')).to eq 'b'
    end

    it 'returns nil if key is not found' do
      expect(client.get('unknown_key')).to eq nil
    end
  end

  describe '.fetch' do
    it 'returns and set block value if key is not found' do
      expect(client.get('a')).to eq nil
      expect(client.fetch('a') { 'b' }).to eq 'b'
      expect(client.get('a')).to eq 'b'
    end

    it 'returns value and does not call block if key is found' do
      expect(client.fetch('a') { 'b' }).to eq 'b'
      expect(client.fetch('a') { 'c' }).to eq 'b'
    end

    it 'sets an expiration time' do
      expect(client.fetch('a', expires_in: 1) { 'b' }).to eq 'b'
      expect(client.fetch('a', expires_in: 1) { 'c' }).to eq 'b'
      sleep 1
      expect(client.fetch('a') { 'c' }).to eq 'c'
    end
  end

  describe '.delete_matched' do
    it 'deletes the matched keys' do
      client.set('chblai36', '11', expires_in: 1000)
      client.set('chblai52', '22', expires_in: 1000)
      client.set('argh28', '33', expires_in: 1000)
      client.delete_matched('*chblai*')
      expect(client.get('chblai36')).to eq nil
      expect(client.get('chblai52')).to eq nil
      expect(client.get('argh28')).to eq '33'
    end
  end

  describe '.clear' do
    it 'flushes all database' do
      client.set('a', 'b', expires_in: 1000)
      client.set('c', 'd', expires_in: 1000)
      expect(client.get('a')).to eq 'b'
      expect(client.get('c')).to eq 'd'
      client.clear
      expect(client.get('a')).to eq nil
      expect(client.get('c')).to eq nil
    end
  end
end
