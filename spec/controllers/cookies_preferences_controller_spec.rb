require 'rails_helper'

RSpec.describe CookiesPreferencesController, type: :controller do
  before do
    allow(CookiesBannerFeature).to receive(:enabled?).and_return(cookies_banner_enabled)
  end

  context 'when CookiesBannerFeature is enabled' do
    let(:cookies_banner_enabled) { true }

    describe '#new' do
      it 'returns success' do
        get :new
        expect(response).to have_http_status(:success)
      end
    end

    describe '#create' do
      it 'sets cookie value' do
        post :create, params: { cookies_consent: 'yes' }
        expect(response.cookies['consented-to-cookies']).to eql('yes')
      end
    end
  end

  context 'when CookiesBannerFeature is disabled' do
    let(:cookies_banner_enabled) { false }

    describe '#new' do
      it 'redirects to the cookies page' do
        get :new
        expect(response).to redirect_to(page_path('cookies'))
      end
    end

    describe '#create' do
      it 'redirects to the cookies page' do
        post :create
        expect(response).to redirect_to(page_path('cookies'))
      end
    end
  end
end
