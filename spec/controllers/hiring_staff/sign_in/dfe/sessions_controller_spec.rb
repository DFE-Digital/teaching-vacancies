require 'rails_helper'

RSpec.describe HiringStaff::SignIn::Dfe::SessionsController, type: :controller do
  describe '#new' do
    it 'redirects to Dfe' do
      get :new
      expect(response).to redirect_to('/auth/dfe') # From here we trust Omniauth
    end
  end
end
