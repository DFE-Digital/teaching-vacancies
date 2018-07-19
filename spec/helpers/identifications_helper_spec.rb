require 'rails_helper'

RSpec.describe IdentificationsHelper, type: :helper do
  describe '#identification_options' do
    before(:each) do
      stub_const("IdentificationsHelper::OTHER_SIGN_IN_OPTION", [])
      stub_const("IdentificationsHelper::DFE_SIGN_IN_OPTIONS", [OpenStruct.new(name: 'Test DfE Sign In region', to_radio: ['Test DfE Sign In region', 'Test DfE Sign In region'])])
      stub_const("IdentificationsHelper::AZURE_SIGN_IN_OPTIONS", [OpenStruct.new(name: 'Test azure region', to_radio: ['Test azure region', 'Test azure region'])])
    end

    it 'returns an array of duplicated sign in options' do
      expect(helper.identification_options).to eq([['Test azure region', 'Test azure region'], ['Test DfE Sign In region', 'Test DfE Sign In region']])
    end
  end
end
