require 'rails_helper'
RSpec.feature 'Vacancy publish feedback' do
  let(:school) { create(:school) }
  let(:session_id) { SecureRandom.uuid }
  let(:choose_yes_to_participation) { choose('vacancy-publish-feedback-user-participation-response-interested-field') }
  let(:choose_no_to_participation) {
    choose('vacancy-publish-feedback-user-participation-response-not-interested-field')
  }

  before(:each) do
    stub_hiring_staff_auth(urn: school.urn, session_id: session_id)
  end

  context 'The feedback page can not be accessed for a draft job post' do
    let(:draft_job) { create(:vacancy, :complete, :draft, school_id: school.id) }

    scenario 'can not be accessed for non-published vacancies' do
      visit new_organisation_job_feedback_path(draft_job.id)

      expect(page).to have_content('Page not found')
    end
  end

  context 'The feedback page can not be accessed for a vacancy that has already received feedback' do
    let(:published_job) { create(:vacancy, :complete, school_id: school.id) }

    scenario 'can not be accessed for non-published vacancies' do
      create(:vacancy_publish_feedback, vacancy: published_job)

      visit new_organisation_job_feedback_path(published_job.id)

      expect(page).to have_content(I18n.t('errors.vacancy_publish_feedback.already_submitted'))
    end
  end

  context 'Submiting feedback for a published vacancy' do
    let(:published_job) { create(:vacancy, :complete, school_id: school.id) }

    scenario 'must have a participation response' do
      visit new_organisation_job_feedback_path(published_job.id)
      fill_in 'vacancy_publish_feedback[comment]', with: 'Perfect!'

      click_on 'Submit feedback'

      expect(page).to have_content("Please indicate if you'd like to participate in user research")
    end

    scenario 'must have an email when participation response is Yes' do
      visit new_organisation_job_feedback_path(published_job.id)
      choose_yes_to_participation

      click_on 'Submit feedback'

      expect(page).to have_content('Enter your email address')
    end

    scenario 'Can be successfully submitted for a published vacancy' do
      visit new_organisation_job_feedback_path(published_job.id)

      fill_in 'vacancy_publish_feedback[comment]', with: 'Perfect!'
      choose_no_to_participation

      click_on 'Submit feedback'
      expect(page).to have_content(
        strip_tags(I18n.t('messages.jobs.feedback.submitted_html', job_title: published_job.job_title))
      )
    end

    scenario 'creates a feedback record' do
      visit new_organisation_job_feedback_path(published_job.id)

      fill_in 'vacancy_publish_feedback[comment]', with: 'Perfect!'
      choose_yes_to_participation
      fill_in 'vacancy_publish_feedback[email]', with: 'user@email.com'

      click_on 'Submit feedback'

      feedback = VacancyPublishFeedback.last

      expect(feedback).to_not be_nil
      expect(feedback.comment).to eq('Perfect!')
      expect(feedback.user).to eq(User.find_by(oid: session_id))
      expect(feedback.email).to eq('user@email.com')
    end

    scenario 'logs an audit activity' do
      visit new_organisation_job_feedback_path(published_job.id)

      fill_in 'vacancy_publish_feedback[comment]', with: 'Perfect!'
      choose_no_to_participation

      click_on 'Submit feedback'
      expect(page).to have_content(
        strip_tags(I18n.t('messages.jobs.feedback.submitted_html', job_title: published_job.job_title))
      )

      activity = published_job.activities.last
      expect(activity.key).to eq('vacancy.publish_feedback.create')
      expect(activity.session_id).to eq(session_id)
    end
  end
end
