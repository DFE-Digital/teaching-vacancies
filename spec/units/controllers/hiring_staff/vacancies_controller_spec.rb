require 'rails_helper'

RSpec.describe HiringStaff::VacanciesController, type: :controller do
  describe 'sets headers' do
    it 'robots are asked not to index or to follow' do
      get :new
      expect(response.headers['X-Robots-Tag']).to eq('noindex, nofollow')
    end
  end
end
