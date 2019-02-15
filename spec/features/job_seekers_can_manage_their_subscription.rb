require 'rails_helper'

RSpec.feature 'A job seeker can manage their subscription' do
  let(:subscription) { create(:subscription, frequency: :daily) }

  context 'with the correct token' do
    let(:token) { subscription.token }

    scenario 'can view their subscription details' do
      visit subscription_path(token)

      expect(page).to have_text('Manage your subscription')
    end
  end

  context 'with an expired token' do
    let(:token) do
      Timecop.travel(-7.days) { subscription.token }
    end

    scenario 'cannot see subscription details' do
      visit subscription_path(token)

      expect(page).to have_text('Page not found')
    end
  end
end