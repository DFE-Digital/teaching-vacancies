require 'rails_helper'

RSpec.describe HiringStaff::IdentificationsController, type: :controller do
  describe '#create' do
    context 'when the area is being serviced by Azure' do
      HiringStaff::IdentificationsController::AZURE_SIGN_IN_OPTIONS.each do |option|
        context "and the region is #{option.name}" do
          it 'redirects to the Azure Sign In controller' do
            post :create, params: { identifications: { name: option.name } }
            expect(response).to redirect_to(new_azure_path)
          end
        end
      end
    end

    context 'when the area is being serviced by DfE Sign In' do
      HiringStaff::IdentificationsController::DFE_SIGN_IN_OPTIONS.each do |option|
        context "and the region is #{option.name}" do
          it 'redirects to the DfE Sign In controller' do
            post :create, params: { identifications: { name: option.name } }
            expect(response).to redirect_to(new_dfe_path)
          end
        end
      end
    end
  end
end
