require 'rails_helper'

RSpec.feature 'A job seeker can unsubscribe from subscriptions' do
  before { allow(EmailAlertsFeature).to receive(:enabled?) { true } }

  let(:search_criteria) { { keyword: 'English', location: 'SW1A1AA', radius: 20 } }
  let(:subscription) do
    create(:subscription,
           frequency: :daily,
           search_criteria: search_criteria.to_json)
  end

  # This needs to be here as we get redirected to the root page, which errors
  # if we haven't flushed the Elasticsearch indices
  before { Vacancy.__elasticsearch__.client.indices.flush }

  before do
    visit subscription_unsubscribe_path(subscription_id: token)
  end

  context 'with the correct token' do
    let(:token) { subscription.token }

    scenario 'unsubscribes successfully' do
      expect(page).to have_content(I18n.t('subscriptions.deletion.header'))
    end

    scenario 'deletes the subscription' do
      expect { subscription.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    scenario 'audits the unsubscription' do
      activity = subscription.activities.last
      expect(activity.key).to eq('subscription.daily_alert.delete')
    end

    scenario 'allows me to resubscribe' do
      click_on I18n.t('subscriptions.deletion.resubscribe_link_text')

      expect(page).to have_content('Keyword: English')
      expect(page).to have_content('Location: Within 20 miles of SW1A1AA')
    end

    context 'with a generated reference' do
      it 'does not show the reference' do
        expect(page).to_not have_content(subscription.reference)
        expect(page).to have_content(I18n.t('subscriptions.deletion.confirmation'))
      end
    end

    context 'with a custom reference' do
      let(:subscription) do
        create(:subscription,
               frequency: :daily,
               search_criteria: search_criteria.to_json,
               reference: 'English teacher jobs')
      end

      it 'shows my reference' do
        expect(page).to have_content(subscription.reference)
        expect(page).to have_content(I18n.t('subscriptions.deletion.confirmation_with_reference',
                                            reference: subscription.reference))
      end
    end
  end

  context 'with the incorrect token' do
    let(:token) { subscription.id }

    scenario 'returns not found' do
      expect(page.status_code).to eq(404)
    end
  end

  context 'with an expired token' do
    let(:token) do
      Timecop.travel(-3.days) { subscription.token }
    end

    scenario 'returns not found' do
      expect(page.status_code).to eq(404)
    end
  end
end