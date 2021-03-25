require 'date'

RSpec.describe LightRedisCache::Client do
  describe ".fetch" do

    # Set the hostname and the port of a local Redis server in `spec/local_redis_server.rb` to run the tests
    let!(:client) { LightRedisCache::Client.new(hostname: LocalRedisServer::HOSTNAME, port: LocalRedisServer::PORT) }

    before(:each) { client.clear }

    it 'returns block value if nothing in database' do
      expect(client.fetch('Hello') { 'Good bye' }).to eq 'Good bye'
    end

    it 'if value found in database, returns it and does not call block' do
      expect(client.fetch('Hello') { 'Good bye' }).to eq 'Good bye'
      expect(client.fetch('Hello') { 'And now ?' }).to eq 'Good bye'
    end

    it 'sets an expiration time' do
      expect(client.fetch('Hi', expires_in: 1) { 'Good bye' }).to eq 'Good bye'
      expect(client.fetch('Hi', expires_in: 1) { 'And now ?' }).to eq 'Good bye'
      sleep 2
      expect(client.fetch('Hi', expires_in: 1)  { 'And now ?' }).to eq 'And now ?'
    end
  end
end
