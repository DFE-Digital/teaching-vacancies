require "rails_helper"

RSpec.describe Publishers::FeedbackPromptMailer, type: :mailer do
  include DatesHelper

  let(:body) { mail.body.raw_source }

  describe "prompt_for_feedback" do
    let(:email) { "dummy@dum.com" }
    let(:publisher) { create(:publisher, email: email) }
    let(:mail) { described_class.prompt_for_feedback(publisher, vacancies) }
    let(:notify_template) { NOTIFY_PROMPT_FEEDBACK_FOR_EXPIRED_VACANCIES }
    let(:vacancies) { create_list(:vacancy, 2, :published) }
    let(:expected_data) do
      {
        notify_template: notify_template,
        email_identifier: anonymised_form_of(email),
        user_anonymised_jobseeker_id: nil,
        user_anonymised_publisher_id: anonymised_form_of(publisher.oid),
      }
    end

    context "with two vacancies" do
      it "shows both vacancies" do
        expect(mail.subject).to eq("Teaching Vacancies needs your feedback on expired job listings")
        expect(mail.to).to eq([email])

        expect(body).to match(/Dear vacancy publisher/)
                    .and match(/\* #{vacancies.first.job_title}/)
                    .and match(/\* #{vacancies.second.job_title}/)
      end

      it "triggers a `publisher_prompt_for_feedback` email event" do
        expect { mail.deliver_now }.to have_triggered_event(:publisher_prompt_for_feedback).with_data(expected_data)
      end
    end
  end
end
