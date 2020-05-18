require 'rails_helper'

RSpec.feature 'A job seeker can unsubscribe from subscriptions' do
  before { allow(EmailAlertsFeature).to receive(:enabled?) { true } }

  let(:search_criteria) { { keyword: 'English', location: 'SW1A1AA', radius: 20 } }
  let(:reference) { 'A reference' }
  let(:subscription) do
    create(:subscription,
           reference: reference,
           frequency: :daily,
           search_criteria: search_criteria.to_json)
  end

  before do
    visit subscription_unsubscribe_path(subscription_id: token)
  end

  context 'with the correct token' do
    let(:token) { subscription.token }

    it 'unsubscribes successfully' do
      expect(page).to have_content(I18n.t('subscriptions.deletion.header'))
    end

    it 'deletes the subscription' do
      expect { subscription.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'audits the unsubscription' do
      activity = subscription.activities.last
      expect(activity.key).to eq('subscription.daily_alert.delete')
    end

    it 'allows me to resubscribe' do
      click_on I18n.t('subscriptions.deletion.resubscribe_link_text')

      expect(page).to have_content('Keyword: English')
      expect(page).to have_content('Location: Within 20 miles of SW1A1AA')
    end

    context 'with deprecated search criteria' do
      let(:search_criteria) { { keyword: 'English', location: 'SW1A1AA', radius: 20 } }

      it 'unsubscribes successfully' do
        expect(page).to have_content(I18n.t('subscriptions.deletion.header'))
      end

      it 'deletes the subscription' do
        expect { subscription.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'audits the unsubscription' do
        activity = subscription.activities.last
        expect(activity.key).to eq('subscription.daily_alert.delete')
      end

      it 'allows me to resubscribe' do
        click_on I18n.t('subscriptions.deletion.resubscribe_link_text')

        expect(page).to have_content('Keyword: English')
        expect(page).to have_content('Location: Within 20 miles of SW1A1AA')
      end
    end

    context 'with a generated reference' do
      let(:reference) { SecureRandom.hex(8) }

      it 'does not show the reference' do
        expect(page).to_not have_content(reference)
        expect(page).to have_content(I18n.t('subscriptions.deletion.confirmation'))
      end
    end

    context 'with a custom reference' do
      let(:reference) { 'English teacher jobs' }

      it 'shows my reference' do
        expect(page).to have_content(reference)
        expect(page).to have_content(I18n.t('subscriptions.deletion.confirmation_with_reference',
                                            reference: reference))
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
    let(:token) do
      Timecop.travel(-3.days) { subscription.token }
    end

    scenario 'still returns 200' do
      expect(page.status_code).to eq(200)
    end
  end
end
