require 'rails_helper'

RSpec.describe LocalAuthority, type: :model do
  context 'associations' do
    it { should have_many(:regional_pay_band_areas) }
  end

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:code) }
  end
end
