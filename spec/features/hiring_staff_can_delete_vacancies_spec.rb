require 'rails_helper'
RSpec.feature 'School deleting vacancies' do
  let(:school) { create(:school) }
  let(:session_id) { SecureRandom.uuid }

  before(:each) do
    stub_hiring_staff_auth(urn: school.urn, session_id: session_id)
  end

  scenario 'A school can delete a vacancy from a list' do
    vacancy1 = create(:vacancy, school: school)
    vacancy2 = create(:vacancy, school: school)

    delete_vacancy(school, vacancy1.id)

    expect(page).not_to have_content(vacancy1.job_title)
    expect(page).to have_content(vacancy2.job_title)
    expect(page).to have_content('The job has been deleted')
  end

  scenario 'The last vacancy is deleted' do
    vacancy = create(:vacancy, school: school)

    delete_vacancy(school, vacancy.id)

    expect(page).to have_content(I18n.t('schools.no_jobs.heading'))
  end

  scenario 'Audits the vacancy deletion' do
    vacancy = create(:vacancy, school: school)

    delete_vacancy(school, vacancy.id)

    activity = vacancy.activities.last
    expect(activity.session_id).to eq(session_id)
    expect(activity.key).to eq('vacancy.delete')
  end

  scenario 'Notifies the Google index service' do
    vacancy = create(:vacancy, school: school)

    expect_any_instance_of(HiringStaff::Vacancies::ApplicationController)
      .to receive(:remove_google_index).with(vacancy)

    delete_vacancy(school, vacancy.id)
  end

  def delete_vacancy(school, vacancy_id)
    visit school_path(school)

    within("tr#school_vacancy_presenter_#{vacancy_id}") do
      click_on 'Delete'
    end
  end
end
