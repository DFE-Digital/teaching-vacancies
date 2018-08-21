require 'rails_helper'

RSpec.describe RegionalPayBandArea, type: :model do
  context 'associations' do
    it { should have_many(:local_authorities) }
  end

  context 'validations' do
    it { should validate_presence_of(:name) }
  end
end
