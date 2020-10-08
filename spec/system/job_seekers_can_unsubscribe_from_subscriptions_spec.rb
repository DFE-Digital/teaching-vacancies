require 'rails_helper'

RSpec.describe 'A job seeker can unsubscribe from subscriptions' do
  let(:search_criteria) { { keyword: 'English', location: 'SW1A1AA', radius: 20 } }
  let(:subscription) { create(:subscription, frequency: :daily, search_criteria: search_criteria.to_json) }

  before do
    visit unsubscribe_subscription_path(token)
  end

  context 'with the correct token' do
    let(:token) { subscription.token }

    it 'unsubscribes successfully' do
      expect(page).to have_content(I18n.t('subscriptions.unsubscribe.header'))
    end

    it 'deletes the subscription' do
      expect { subscription.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'audits the unsubscription' do
      activity = subscription.activities.last
      expect(activity.key).to eq('subscription.daily_alert.delete')
    end

    it 'allows me to resubscribe' do
      click_on I18n.t('subscriptions.unsubscribe.resubscribe_link_text')

      expect(page).to have_content('Keyword: English')
      expect(page).to have_content('Location: Within 20 miles of SW1A1AA')
    end

    context 'with deprecated search criteria' do
      let(:search_criteria) { { keyword: 'English', location: 'SW1A1AA', radius: 20 } }

      it 'unsubscribes successfully' do
        expect(page).to have_content(I18n.t('subscriptions.unsubscribe.header'))
      end

      it 'deletes the subscription' do
        expect { subscription.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'audits the unsubscription' do
        activity = subscription.activities.last
        expect(activity.key).to eq('subscription.daily_alert.delete')
      end

      it 'allows me to resubscribe' do
        click_on I18n.t('subscriptions.unsubscribe.resubscribe_link_text')

        expect(page).to have_content('Keyword: English')
        expect(page).to have_content('Location: Within 20 miles of SW1A1AA')
      end
    end
  end

  context 'with the incorrect token' do
    let(:token) { subscription.id }

    it 'returns not found' do
      expect(page.status_code).to eq(404)
    end
  end

  context 'with an old token' do
    let(:token) { subscription.token }

    scenario 'still returns 200' do
      travel 3.days do
        expect(page.status_code).to eq(200)
      end
    end
  end
end
