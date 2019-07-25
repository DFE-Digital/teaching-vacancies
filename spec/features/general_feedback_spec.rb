require 'rails_helper'
RSpec.feature 'Giving general feedback for the service' do
  before(:each) { visit new_feedback_path }

  it 'displays the general feedback page' do
    expect(page).to have_content(I18n.t('feedback.heading'))
  end

  scenario 'successfully submitting feedback for the service' do
    choose 'Find a job in teaching'

    fill_in 'general_feedback_comment', with: 'Keep going!'

    click_on 'Submit feedback'

    expect(page).to have_content('Your feedback has been successfully submitted')
  end
end
