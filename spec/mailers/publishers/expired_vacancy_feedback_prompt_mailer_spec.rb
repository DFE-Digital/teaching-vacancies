require "rails_helper"

RSpec.describe Publishers::ExpiredVacancyFeedbackPromptMailer do
  include DatesHelper

  let(:body) { mail.body.raw_source }

  describe "prompt_for_feedback" do
    let(:content_extract) { "Please let us know whether you filled these roles through Teaching Vacancies, or through another site or service." }
    let(:email) { "test@example.com" }
    let(:publisher) { create(:publisher, email: email) }
    let(:mail) { described_class.prompt_for_feedback(publisher, vacancies) }
    let(:notify_template) { NOTIFY_PRODUCTION_TEMPLATE }
    let(:vacancies) { create_list(:vacancy, 5, :expired) }
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

      expect(body).to include(content_extract)
                  .and include(vacancies.first.job_title)
                  .and include(vacancies.second.job_title)
                  .and include(vacancies.third.job_title)
                  .and include(vacancies.fourth.job_title)
                  .and include(vacancies.fifth.job_title)
    end

    it "triggers a `publisher_prompt_for_feedback` email event" do
      expect { mail.deliver_now }.to have_triggered_event(:publisher_prompt_for_feedback).with_data(expected_data)
    end

    context "from Sandbox environment" do
      let(:notify_template) { NOTIFY_SANDBOX_TEMPLATE }

      before { allow(ENV).to receive(:[]).with("APP_ROLE").and_return("sandbox") }

      it "triggers a `publisher_sign_in_fallback` email event" do
        expect { mail.deliver_now }.to have_triggered_event(:publisher_prompt_for_feedback).with_data(expected_data)
      end
    end
  end
end
