require 'rails_helper'
RSpec.feature 'Users cannot manage vacancies' do
  before(:each) do
    expect_any_instance_of(HiringStaff::BaseController)
      .to receive(:authenticate?)
      .and_return(true)

    fake_env = double.as_null_object
    allow(Figaro).to receive(:env).and_return(fake_env)
    allow(fake_env).to receive(:http_user?).and_return(false)
    allow(fake_env).to receive(:http_pass?).and_return(false)
    allow(fake_env).to receive(:http_user).and_return(nil)
    allow(fake_env).to receive(:http_pass).and_return(nil)
  end

  scenario 'An unauthenticated user tries to create a vacancy' do
    school = create(:school)

    visit "/schools/#{school.id}/vacancies/new"

    expect(page).to have_content('HTTP Basic: Access denied.')
  end

  scenario 'An unauthenticated user tries to update a vacancy' do
    school = create(:school)
    vacancy = create(:vacancy, school: school)

    visit "/schools/#{school.id}/vacancies/#{vacancy.slug}"

    expect(page).to have_content('HTTP Basic: Access denied.')
  end
end
