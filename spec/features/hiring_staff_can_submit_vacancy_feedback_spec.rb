require 'rails_helper'
RSpec.feature 'Vacancy feedback' do
  let(:school) { create(:school) }
  let(:session_id) { SecureRandom.uuid }

  before(:each) do
    stub_hiring_staff_auth(urn: school.urn, session_id: session_id)
  end

  context 'Vacancy feedback' do
    context 'The feedback page can not be accessed for a draft job post' do
      let(:draft_job) { create(:vacancy, :complete, :draft, school_id: school.id) }

      scenario 'can not be accessed for non-published vacancies' do
        visit new_school_job_feedback_path(draft_job.id)

        expect(page).to have_content('Page not found')
      end
    end

    context 'The feedback page can not be accessed for a vacancy that has already received feedback' do
      let(:published_job) { create(:vacancy, :complete, school_id: school.id) }

      scenario 'can not be accessed for non-published vacancies' do
        create(:feedback, vacancy: published_job)

        visit new_school_job_feedback_path(published_job.id)

        expect(page).to have_content('Feedback for this job listing has already been submitted')
      end
    end

    context 'Submiting feedback for a published vacancy' do
      let(:published_job) { create(:vacancy, :complete, school_id: school.id) }

      scenario 'must have a rating specified' do
        visit new_school_job_feedback_path(published_job.id)

        fill_in 'feedback_comment', with: 'Perfect!'

        click_on 'Submit feedback'
        expect(page).to have_content('Rating can\'t be blank')
      end

      scenario 'Can be successfully submitted for a published vacancy' do
        visit new_school_job_feedback_path(published_job.id)

        choose 'Very satisfied'
        fill_in 'feedback_comment', with: 'Perfect!'

        click_on 'Submit feedback'
        expect(page).to have_content('Your feedback has been successfully submitted')
      end

      scenario 'logs an audit activity' do
        visit new_school_job_feedback_path(published_job.id)

        choose 'Very satisfied'
        fill_in 'feedback_comment', with: 'Perfect!'

        click_on 'Submit feedback'
        expect(page).to have_content('Your feedback has been successfully submitted')

        activity = published_job.activities.last
        expect(activity.key).to eq('vacancy.feedback.create')
        expect(activity.session_id).to eq(session_id)
      end

      scenario 'triggers a job to write the feedback to a Spreadsheet' do
        visit root_path
        timestamp = Time.zone.now.iso8601
        data = [timestamp.to_s, session_id, published_job.id, published_job.school.urn, 5, 'Perfect!']

        expect(AuditFeedbackJob).to receive(:perform_later)
          .with(data)

        Timecop.freeze(timestamp) do
          visit new_school_job_feedback_path(published_job.id)

          choose 'Very satisfied'
          fill_in 'feedback_comment', with: 'Perfect!'

          click_on 'Submit feedback'
        end
      end
    end
  end
end
