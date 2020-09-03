require 'rails_helper'

RSpec.describe 'Job seekers can apply for a vacancy' do
  let(:school) { create(:school) }

  scenario 'the application link is without protocol' do
    vacancy = create(:vacancy, :published, application_link: 'www.google.com')
    vacancy.organisation_vacancies.create(organisation: school)

    visit job_path(vacancy)

    expect(page).to have_link(I18n.t('jobs.apply', href: 'http://www.google.com'))
  end

  scenario 'an activity is logged successfuly' do
    vacancy = create(:vacancy, :published, application_link: 'www.google.com')
    vacancy.organisation_vacancies.create(organisation: school)

    visit job_path(vacancy)

    click_on I18n.t('jobs.apply')

    activity = vacancy.activities.last
    expect(activity.key).to eq('vacancy.get_more_information')
    expect(activity.session_id).to eq(nil)
  end

  scenario 'it increments the get_more_info_counter' do
    vacancy = create(:vacancy, :published)
    vacancy.organisation_vacancies.create(organisation: school)

    visit job_path(vacancy)

    expect { click_on I18n.t('jobs.apply') }.to change { vacancy.get_more_info_counter.to_i }.by(1)
  end

  scenario 'it triggers a job to write an express_interest_event to the audit table' do
    vacancy = create(:vacancy, :published)
    vacancy.organisation_vacancies.create(organisation: school)

    visit job_path(vacancy)

    freeze_time do
      timestamp = Time.zone.now.iso8601

      express_interest_event = {
        datestamp: timestamp.to_s,
        vacancy_id: vacancy.id,
        school_urn: vacancy.parent_organisation.urn,
        application_link: vacancy.application_link
      }

      expect(AuditExpressInterestEventJob).to receive(:perform_later)
        .with(express_interest_event)

      click_on I18n.t('jobs.apply')
    end
  end
end
