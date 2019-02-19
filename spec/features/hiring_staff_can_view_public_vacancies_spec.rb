require 'rails_helper'

RSpec.feature 'Hiring staff can view public vacancies' do
  scenario 'A vacancy page view is not tracked' do
    school = create(:school)
    vacancy = create(:vacancy, :published)
    stub_hiring_staff_auth(urn: school.urn)

    expect(TrackVacancyPageView).not_to receive(:perform_later)

    visit job_path(vacancy)
  end
end
