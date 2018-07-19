require 'rails_helper'

RSpec.describe HiringStaff::SignIn::Azure::SessionsController, type: :controller do
  describe '#new' do
    it 'redirects to Azure' do
      get :new
      expect(response).to redirect_to('/auth/azureactivedirectory') # From here we trust Omniauth
    end
  end
end
