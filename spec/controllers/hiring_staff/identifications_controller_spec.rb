require 'rails_helper'

RSpec.describe HiringStaff::IdentificationsController, type: :controller do
  describe '#create' do
    it 'redirects to DfE Sign in' do
      post :create
      expect(response).to redirect_to(new_dfe_path)
    end
  end
end
