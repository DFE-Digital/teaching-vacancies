require 'rails_helper'

RSpec.feature 'Hiring staff can share their vacancy' do
  let(:school) { create(:school) }
  before(:each) do
    stub_hiring_staff_auth(urn: school.urn)
  end

  scenario 'A school can visit their page as the job seeker would' do
    vacancy = create(:vacancy)
    vacancy.organisation_vacancies.create(organisation: school)

    visit organisation_path

    click_on(vacancy.job_title)
    click_on(I18n.t('jobs.view_public_link'))

    expected_url = URI("localhost:3000#{job_path(vacancy)}")

    expect(current_url).to match(expected_url.to_s)
    expect(page).to have_content(vacancy.job_title)
  end
end
