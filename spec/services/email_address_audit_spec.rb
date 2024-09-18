require "rails_helper"

RSpec.describe EmailAddressAudit do
  subject(:audit) { described_class.run(**options) }

  let(:options) { {} }

  let(:feedback_email) { Faker::Internet.email(domain: TEST_EMAIL_DOMAIN) }
  let!(:valid_records) do
    [
      create(:feedback, email: feedback_email),
      create(:job_application, email_address: Faker::Internet.email(domain: TEST_EMAIL_DOMAIN)),
      create(:jobseeker, email: Faker::Internet.email(domain: TEST_EMAIL_DOMAIN)),
      create(:publisher, email: Faker::Internet.email(domain: TEST_EMAIL_DOMAIN)),
      create(:subscription, email: Faker::Internet.email(domain: TEST_EMAIL_DOMAIN)),
      create(:vacancy, contact_email: Faker::Internet.email(domain: TEST_EMAIL_DOMAIN)),
    ]
  end

  let!(:invalid_records) do
    [
      create_invalid_record(:feedback, email: "test@example"),
      create_invalid_record(:job_application, email_address: "test@example"),
      create_invalid_record(:jobseeker, email: "test@example"),
      create_invalid_record(:publisher, email: "test@example"),
      create_invalid_record(:subscription, email: "test@example"),
      create_invalid_record(:vacancy, contact_email: "test@example"),
    ]
  end

  def create_invalid_record(factory_name, attributes = {})
    build(factory_name, attributes).tap { |record| record.save(validate: false) }
  end

  it "builds a report on the number of invalid email addresses per class" do
    expect(audit).to eq({
      "Feedback" => 1,
      "JobApplication" => 1,
      "Jobseeker" => 1,
      "Publisher" => 1,
      "Subscription" => 1,
      "Vacancy" => 1,
    })
  end

  it "does not delete them" do
    audit

    expect(Feedback.count).to eq(2)
  end

  context "when a listing is requested" do
    let(:options) do
      {
        list: true,
      }
    end

    it "builds a report with a list of invalid email addresses per class" do
      expect(audit).to eq({
        "Feedback" => ["test@example"],
        "JobApplication" => ["test@example"],
        "Jobseeker" => ["test@example"],
        "Publisher" => ["test@example"],
        "Subscription" => ["test@example"],
        "Vacancy" => ["test@example"],
      })
    end
  end

  context "when deletion is requested" do
    let(:options) do
      {
        delete: true,
      }
    end

    it "deletes the invalid records" do
      audit

      expect(Feedback.count).to eq(1)
      expect(Feedback.last.email).to eq(feedback_email)
    end
  end
end
