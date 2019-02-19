require 'rails_helper'

RSpec.feature 'Hiring staff can view a public vacancy' do
  scenario 'A vacancy page view is not tracked' do
    school = create(:school)
    vacancy = create(:vacancy, :published)
    stub_hiring_staff_auth(urn: school.urn)

    expect(TrackVacancyPageViewJob).not_to receive(:perform_later)

    visit job_path(vacancy)
  end
end
