require 'rails_helper'
RSpec.describe 'Creating a vacancy' do
  include ActiveJob::TestHelper
  let(:school) { create(:school) }
  let(:session_id) { SecureRandom.uuid }

  before(:each) do
    ActionMailer::Base.deliveries.clear
    stub_hiring_staff_auth(urn: school.urn, session_id: session_id, email: 'test@mail.com')
  end

  after(:each) do
    travel_back
  end

  context 'Hiring staff has expired vacancy that is not older than 2 weeks' do
    scenario 'does not receive feedback prompt e-mail' do
      current_user = User.find_by(oid: session_id)
      vacancy = create(
        :vacancy,
        :published,
        job_title: 'Vacancy',
        publish_on: Time.zone.today,
        expires_on: Time.zone.today + 1.week,
        publisher_user_id: current_user.id,
      )
      vacancy.organisation_vacancies.create(organisation: school)

      travel 2.weeks do
        perform_enqueued_jobs do
          SendExpiredVacancyFeedbackEmailJob.new.perform
        end

        expect(ApplicationMailer.deliveries.count).to eq(0)
      end
    end
  end

  context 'Hiring staff has 2 expired vacancies that are older than 2 weeks' do
    scenario 'receives feedback prompt email with 2 vacancies' do
      current_user = User.find_by(oid: session_id)
      vacancy = create(
        :vacancy,
        :published,
        job_title: 'Job one',
        publish_on: Time.zone.today,
        expires_on: Time.zone.today,
        publisher_user_id: current_user.id,
      )
      vacancy.organisation_vacancies.create(organisation: school)

      vacancy = create(
        :vacancy,
        :published,
        job_title: 'Job two',
        publish_on: Time.zone.today,
        expires_on: Time.zone.today,
        publisher_user_id: current_user.id,
      )
      vacancy.organisation_vacancies.create(organisation: school)

      vacancy = create(
        :vacancy,
        :published,
        job_title: 'Job three',
        publish_on: Time.zone.today,
        expires_on: Time.zone.today + 2.weeks,
        publisher_user_id: current_user.id,
      )
      vacancy.organisation_vacancies.create(organisation: school)

      travel 2.weeks do
        perform_enqueued_jobs do
          SendExpiredVacancyFeedbackEmailJob.new.perform
        end

        expect(ApplicationMailer.deliveries.first.to).to eq(['test@mail.com'])
        expect(ApplicationMailer.deliveries.count).to eq(1)
        expect(ApplicationMailer.deliveries.first.body).to have_content('Job one')
        expect(ApplicationMailer.deliveries.first.body).to have_content('Job two')
        expect(ApplicationMailer.deliveries.first.body).to_not have_content('Job three')
      end
    end
  end

  context 'Two expired vacancies for two users that are older than 2 weeks' do
    scenario 'both receives feedback prompt emails' do
      current_user = User.find_by(oid: session_id)
      another_user = create(:user, email: 'another@user.com')
      vacancy = create(
        :vacancy,
        :published,
        job_title: 'Job one',
        publish_on: Time.zone.today,
        expires_on: Time.zone.today,
        publisher_user_id: current_user.id,
      )
      vacancy.organisation_vacancies.create(organisation: school)

      vacancy = create(
        :vacancy,
        :published,
        job_title: 'Job two',
        publish_on: Time.zone.today,
        expires_on: Time.zone.today,
        publisher_user_id: another_user.id,
      )
      vacancy.organisation_vacancies.create(organisation: school)

      travel 2.weeks do
        perform_enqueued_jobs do
          SendExpiredVacancyFeedbackEmailJob.new.perform
        end

        expect(ApplicationMailer.deliveries.map(&:to)).to match a_collection_containing_exactly(
          ['another@user.com'], ['test@mail.com']
        )
        expect(ApplicationMailer.deliveries.count).to eq(2)
      end
    end
  end
end
