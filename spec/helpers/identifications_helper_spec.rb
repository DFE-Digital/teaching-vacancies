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
      stub_const('IdentificationsHelper::AZURE_SIGN_IN_OPTIONS',
                 [
                   OpenStruct.new(
                     name: 'test_azure_region',
                     to_radio: ['test_azure_region', 'Test azure region']
                   )
                 ])
    end

    it 'returns an array of duplicated sign in options' do
      expect(helper.identification_options).to eq(
        [['test_azure_region', 'Test azure region'], ['test_dfe_sign_in_region', 'Test DfE Sign In region']]
      )
    end

    context 'when the environment is production' do
      before(:each) do
        allow(Rails).to receive(:env)
          .and_return(ActiveSupport::StringInquirer.new('production'))
      end

      it 'does not return the dfe sign in options' do
        expect(helper.identification_options).to eq([['test_azure_region', 'Test azure region']])
      end
    end
  end
end
