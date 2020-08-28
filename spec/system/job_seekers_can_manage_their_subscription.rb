require 'rails_helper'

RSpec.describe 'A job seeker can manage their subscription' do
  let(:subscription) { create(:subscription, frequency: :daily) }

  context 'with the correct token' do
    let(:token) { subscription.token }

    scenario 'can view their subscription details' do
      visit subscription_path(token)

      expect(page).to have_text('Manage your subscription')
    end
  end

  context 'with an old token' do
    scenario 'cannot see subscription details' do
      travel 7.days do
        visit subscription_path(token)

        expect(page).to have_text('Manage your subscription')
      end
    end
  end
end
