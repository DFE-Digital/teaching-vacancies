require 'rails_helper'

RSpec.describe AutoExpireCacheRedis do
  let(:mock_redis) { MockRedis.new }
  let(:ttl) { Faker::Number.between(from: 100, to: 1000) }
  subject { described_class.new(mock_redis, ttl) }

  before do
    subject['a_url'] = 'a_value'
  end

  it 'can fetch information about a key that has been stored' do
    expect(subject['a_url']).to eq('a_value')
  end

  it 'can fetch all stored keys' do
    subject['another_url'] = 'another_value'
    expect(subject.keys).to eq(%w[a_url another_url])
  end

  it 'can delete a stored key' do
    expect { subject.del('a_url') }.to change { subject['a_url'] }.from('a_value').to(nil)
  end

  it 'sets a ttl on a stored key' do
    expect(mock_redis.ttl('a_url')).to eq(ttl)
  end
end
