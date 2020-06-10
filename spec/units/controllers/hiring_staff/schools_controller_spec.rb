require 'rails_helper'

RSpec.describe HiringStaff::SchoolsController, type: :controller do
  describe 'sets headers' do
    it 'robots are asked not to index or to follow' do
      get :show
      expect(response.headers['X-Robots-Tag']).to eq('noindex, nofollow')
    end
  end
end
