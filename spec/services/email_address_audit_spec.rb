require "rails_helper"

RSpec.describe EmailAddressAudit do
  subject(:audit) { described_class.run(**options) }

  let(:options) { {} }

  let!(:valid_records) do
    [
      create(:feedback, email: "test@example.com"),
      create(:job_application, email_address: "test@example.com"),
      create(:jobseeker, email: "test@example.com"),
      create(:publisher, email: "test@example.com"),
      create(:subscription, email: "test@example.com"),
      create(:vacancy, contact_email: "test@example.com"),
    ]
  end

  let!(:invalid_records) do
    [
      create(:feedback, email: "test@example"),
      create(:job_application, email_address: "test@example"),
      create(:jobseeker, email: "test@example"),
      create(:publisher, email: "test@example"),
      create(:subscription, email: "test@example"),
      create(:vacancy, contact_email: "test@example"),
    ]
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
      expect(Feedback.last.email).to eq("test@example.com")
    end
  end
end
