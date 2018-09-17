require 'rails_helper'

RSpec.feature 'Job seekers can apply for a vacancy' do
  scenario 'the application link is without protocol' do
    vacancy = create(:vacancy, :published, application_link: 'www.google.com')
    visit job_path(vacancy)

    expect(page).to have_link(I18n.t('jobs.apply', href: 'http://www.google.com'))
  end

  scenario 'an activity is logged successfuly' do
    vacancy = create(:vacancy, :published, application_link: 'www.google.com')
    visit job_path(vacancy)

    click_on 'Get more information'

    activity = vacancy.activities.last
    expect(activity.key).to eq('vacancy.get_more_information')
    expect(activity.session_id).to eq(nil)
  end
end
