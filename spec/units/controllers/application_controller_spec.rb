require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe 'routing' do
    it 'check endpoint is publically accessible' do
      expect(get: '/check').to route_to(controller: 'application', action: 'check')
    end
  end

  describe '#request_ip' do
    it 'returns the anonymized IP with the last octet zero padded' do
      expect(controller.request_ip).to eql('0.0.0.0')
    end

    context 'when the IP is at the max range' do
      it 'returns the anonymized IP with the last octet zero padded' do
        allow_any_instance_of(ActionController::TestRequest)
          .to receive(:remote_ip)
          .and_return('255.255.255.255')
        expect(controller.request_ip).to eql('255.255.255.0')
      end
    end
  end

  describe '#check_staging_auth' do
    context 'when we want to authenticate' do
      before(:each) do
        allow(controller).to receive(:authenticate?).and_return(true)
      end

      it 'passes information to ActionController to decide' do
        expect(controller).to receive(:authenticate_or_request_with_http_basic)
        controller.check_staging_auth
      end
    end

    context 'when we do NOT want to authenticate' do
      before(:each) do
        allow(controller).to receive(:authenticate?).and_return(false)
      end

      it 'skips the authentication call' do
        expect(controller).to_not receive(:authenticate_or_request_with_http_basic)
        controller.check_staging_auth
      end
    end
  end

  describe '#authenticate?' do
    context 'when in test' do
      before(:each) do
        allow(Rails).to receive(:env)
          .and_return(ActiveSupport::StringInquirer.new('test'))
      end

      it 'returns false' do
        expect(controller.authenticate?).to eq(false)
      end
    end

    context 'when in development' do
      before(:each) do
        allow(Rails).to receive(:env)
          .and_return(ActiveSupport::StringInquirer.new('development'))
      end

      it 'returns false' do
        expect(controller.authenticate?).to eq(false)
      end
    end

    context 'when in staging' do
      before(:each) do
        allow(Rails).to receive(:env)
          .and_return(ActiveSupport::StringInquirer.new('staging'))
      end

      it 'returns true' do
        expect(controller.authenticate?).to eq(true)
      end
    end

    context 'when in production' do
      before(:each) do
        allow(Rails).to receive(:env)
          .and_return(ActiveSupport::StringInquirer.new('production'))
      end

      it 'returns true' do
        expect(controller.authenticate?).to eq(false)
      end
    end
  end

  describe 'sets headers' do
    it 'robots are asked not to index or to follow' do
      get :check
      expect(response.headers['X-Robots-Tag']).to eq('noindex, nofollow')
    end
  end
end
