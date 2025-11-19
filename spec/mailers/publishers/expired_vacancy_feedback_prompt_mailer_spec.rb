require "rails_helper"
require "dfe/analytics/rspec/matchers"

RSpec.describe Publishers::ExpiredVacancyFeedbackPromptMailer do
  include DatesHelper

  describe "prompt_for_feedback" do
    let(:email) { Faker::Internet.email(domain: TEST_EMAIL_DOMAIN) }
    let(:publisher) { build_stubbed(:publisher, email: email) }
    let(:mail) { described_class.prompt_for_feedback(publisher, vacancy) }
    let(:vacancy) { build_stubbed(:vacancy, :expired) }
    let(:expected_data) do
      {
        notify_template: notify_template,
        email_identifier: anonymised_form_of(email),
        user_anonymised_jobseeker_id: nil,
        user_anonymised_publisher_id: anonymised_form_of(publisher.oid),
      }
    end

    it "lists all vacancies" do
      expect(mail.to).to eq([email])

      expect(mail.personalisation).to include({ job_title: vacancy.job_title })
    end

    it "triggers a `publisher_prompt_for_feedback` email event", :dfe_analytics do
      mail.deliver_now
      expect(:publisher_prompt_for_feedback).to have_been_enqueued_as_analytics_event(with_data: %i[uid notify_template]) # rubocop:disable RSpec/ExpectActual
    end
  end
end
