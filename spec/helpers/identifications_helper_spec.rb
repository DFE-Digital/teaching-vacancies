require 'rails_helper'

RSpec.describe IdentificationsHelper, type: :helper do
  describe '#identification_options' do
    before(:each) do
      stub_const('IdentificationsHelper::OTHER_SIGN_IN_OPTION', [])
      stub_const('IdentificationsHelper::DFE_SIGN_IN_OPTIONS',
                 [
                   OpenStruct.new(
                     name: 'test_dfe_sign_in_region',
                     to_radio: ['test_dfe_sign_in_region', 'Test DfE Sign In region']
                   )
                 ])
    end

    it 'returns an array of duplicated sign in options' do
      expect(helper.identification_options).to eq(
        [['test_dfe_sign_in_region', 'Test DfE Sign In region']]
      )
    end
  end
end
