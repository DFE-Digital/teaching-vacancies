require 'rails_helper'
RSpec.feature 'Giving general feedback for the service' do
  before(:each) { visit new_feedback_path }

  context 'when viewing the visiting purpose section' do
    it 'displays the section heading' do
      expect(page).to have_content(I18n.t('general_feedback.visit_purpose_legend'))
    end

    it 'displays the visiting purpose options' do
      expect(page).to have_content(I18n.t('general_feedback.visit_purpose_options.find_teaching_job'))
      expect(page).to have_content(I18n.t('general_feedback.visit_purpose_options.list_teaching_job'))
      expect(page).to have_content(I18n.t('general_feedback.visit_purpose_options.other_purpose'))
    end
  end

  context 'when viewing the service rating comment section' do
    it 'displays the section heading' do
      expect(page).to have_content(I18n.t('feedback.comment_label'))
    end
  end

  scenario 'successfully submitting feedback for the service' do
    choose 'Find a job in teaching'

    fill_in 'general_feedback_comment', with: 'Keep going!'

    click_on 'Submit feedback'

    expect(page).to have_content('Your feedback has been successfully submitted')
  end
end
