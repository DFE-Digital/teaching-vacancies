require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe '#authenticate' do
    context 'when we want to authenticate' do
      before(:each) do
        allow(controller).to receive(:authenticate?).and_return(true)
      end

      it 'passes information to ActionController to decide' do
        expect(controller).to receive(:authenticate_or_request_with_http_basic)
        controller.authenticate
      end
    end

    context 'when we do NOT want to authenticate' do
      before(:each) do
        allow(controller).to receive(:authenticate?).and_return(false)
      end

      it 'skips the authentication call' do
        expect(controller).to_not receive(:authenticate_or_request_with_http_basic)
        controller.authenticate
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
        expect(controller.authenticate?).to eq(true)
      end
    end
  end
end
