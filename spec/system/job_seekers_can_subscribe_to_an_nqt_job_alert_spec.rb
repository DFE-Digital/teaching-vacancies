require 'rails_helper'

RSpec.describe 'A job seeker can subscribe to an NQT job alert' do
  before { allow(EmailAlertsFeature).to receive(:enabled?) { true } }

  describe 'A job seeker' do
    scenario 'can successfully subscribe to a job alert' do
      visit nqt_job_alerts_path

      expect(page).to have_content(I18n.t('nqt_job_alerts.heading'))

      fill_in 'nqt_job_alerts_form[keywords]', with: 'Maths'
      fill_in 'nqt_job_alerts_form[location]', with: 'London'
      fill_in 'nqt_job_alerts_form[email]', with: 'test@email.com'

      message_delivery = instance_double(ActionMailer::MessageDelivery)
      expect(SubscriptionMailer).to receive(:confirmation) { message_delivery }
      expect(message_delivery).to receive(:deliver_later)
      click_on I18n.t('buttons.subscribe')

      expect(page).to have_content(I18n.t('nqt_job_alerts.confirm.heading'))
      click_on I18n.t('buttons.go_to_teaching_vacancies')

      expect(page).to have_current_path(jobs_path(keyword: 'nqt Maths', location: 'London'))
    end
  end
end
