require 'rails_helper'

RSpec.describe LocalAuthority, type: :model do
  context 'associations' do
    it { should have_many(:regional_pay_band_areas) }
  end

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:code) }
  end

  context '#default_regional_pay_band_area' do
    let(:local_authority) { create(:local_authority) }
    let(:roc_pay_band_area) { create(:regional_pay_band_area, name: 'Rest of England') }
    let(:other_pay_band_area) { create(:regional_pay_band_area) }

    it 'returns the Rest of England payband when it has multiple payband areas' do
      local_authority.regional_pay_band_areas << roc_pay_band_area << other_pay_band_area

      expect(local_authority.default_regional_pay_band_area).to eq(roc_pay_band_area)
    end

    it 'returns the payband area when only one payband is set' do
      local_authority.regional_pay_band_areas << other_pay_band_area

      expect(local_authority.default_regional_pay_band_area).to eq(other_pay_band_area)
    end

    it 'returns nothing when no payband is set' do
      expect(local_authority.default_regional_pay_band_area).to eq(nil)
    end
  end
end
