require 'rails_helper'

RSpec.describe 'Giving general feedback for the service' do
  before(:each) do
    visit new_feedback_path
  end

  it 'displays the general feedback page' do
    expect(page).to have_content(I18n.t('feedback.heading'))
  end

  context 'when submitting feedback on the service' do
    let(:choose_yes_to_participation) { choose('general-feedback-user-participation-response-interested-field') }
    let(:choose_no_to_participation) { choose('general-feedback-user-participation-response-not-interested-field') }

    scenario 'must have a visit purpose' do
      fill_in 'general_feedback[comment]', with: 'Keep going!'
      choose_no_to_participation

      click_on I18n.t('feedback.submit')

      expect(page).to have_content('Enter the reason for your visit')
    end

    scenario 'must have a participation response' do
      choose 'Find a job in teaching'
      fill_in 'general_feedback[comment]', with: 'Keep going!'

      click_on I18n.t('feedback.submit')

      expect(page).to have_content("Please indicate if you'd like to participate in user research")
    end

    scenario 'successfully submitting feedback for the service' do
      choose 'Find a job in teaching'
      fill_in 'general_feedback[comment]', with: 'Keep going!'
      choose_no_to_participation

      click_on I18n.t('feedback.submit')

      expect(page).to have_content('Your feedback has been successfully submitted')
    end

    scenario 'must have an email when participation response is Yes' do
      choose 'Find a job in teaching'
      fill_in 'general_feedback[comment]', with: 'Keep going!'
      choose_yes_to_participation

      click_on I18n.t('feedback.submit')

      expect(page).to have_content('Enter your email address')
    end

    scenario 'successfully submitting feedback and interest in user research' do
      choose 'Find a job in teaching'
      fill_in 'general_feedback[comment]', with: 'Keep going!'

      choose_yes_to_participation
      fill_in 'email', with: 'test@test.com'

      click_on I18n.t('feedback.submit')

      expect(page).to have_content('Your feedback has been successfully submitted')
    end
  end
end
