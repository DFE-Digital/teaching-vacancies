require 'rails_helper'

RSpec.feature 'Job seekers can renew their subscription' do
  let(:old_expiry) { 1.week.from_now.to_date }
  let(:subscription) do
    create(:subscription, search_criteria: { subject: 'english' }.to_json, expires_on: old_expiry)
  end

  before do
    visit subscription_renew_path(subscription_id: subscription.token)
  end

  scenario 'updates the expiry date' do
    new_expiry = 6.months.from_now.to_date
    expect { click_on 'Resubscribe' }.to change { subscription.reload.expires_on }.from(old_expiry).to(new_expiry)
  end

  scenario 'shows a confirmation page' do
    click_on 'Resubscribe'

    expect(page).to have_text(I18n.t('subscriptions.updated.header'))
  end

  scenario 'can change their email' do
    old_email = subscription.email
    new_email = 'foo@example.com'

    fill_in 'subscription_email', with: new_email

    expect { click_on 'Resubscribe' }.to change { subscription.reload.email }.from(old_email).to(new_email)
  end

  scenario 'can change their reference' do
    old_reference = subscription.reference
    new_reference = 'new reference'

    fill_in 'subscription_reference', with: new_reference

    expect { click_on 'Resubscribe' }.to change { subscription.reload.reference }.from(old_reference).to(new_reference)
  end
end