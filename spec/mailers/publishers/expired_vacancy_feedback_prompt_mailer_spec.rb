require "rails_helper"
require "dfe/analytics/rspec/matchers"

RSpec.describe Publishers::ExpiredVacancyFeedbackPromptMailer do
  include DatesHelper

  let(:body) { mail.body.raw_source }

  describe "prompt_for_feedback" do
    let(:content_extract1) do
      "You recently recruited for #{vacancy.job_title}"
    end
    let(:content_extract2) do
      "Tell us how you filled your vacancy"
    end
    let(:email) { "test@example.com" }
    let(:publisher) { create(:publisher, email: email) }
    let(:mail) { described_class.prompt_for_feedback(publisher, vacancy) }
    let(:notify_template) { NOTIFY_PRODUCTION_TEMPLATE }
    let(:vacancy) { create(:vacancy, :expired) }
    let(:expected_data) do
      {
        notify_template: notify_template,
        email_identifier: anonymised_form_of(email),
        user_anonymised_jobseeker_id: nil,
        user_anonymised_publisher_id: anonymised_form_of(publisher.oid),
      }
    end

    it "lists all vacancies" do
      expect(mail.subject).to eq("Teaching Vacancies needs your feedback on closed job listings")
      expect(mail.to).to eq([email])

      expect(body).to include(content_extract1)
                  .and include(content_extract2)
                  .and include(vacancy.job_title)
    end

    it "triggers a `publisher_prompt_for_feedback` email event" do
      mail.deliver_now
      expect(:publisher_prompt_for_feedback).to have_been_enqueued_as_analytics_events
    end
  end
end
