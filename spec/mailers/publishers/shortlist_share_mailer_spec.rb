require "rails_helper"
require "dfe/analytics/rspec/matchers"

RSpec.describe Publishers::ShortlistShareMailer do
  let(:publisher) { create(:publisher) }
  let(:vacancy) { create(:vacancy) }
  let(:job_applications) { create_list(:job_application, 2, :status_shortlisted, vacancy:) }
  let(:recipient_email) { "hiring.manager@example.com" }
  let(:pdf_data) { "%PDF-1.4 shortlist application" }
  let(:document) { instance_double(Prawn::Document, render: pdf_data) }
  let(:generator) { instance_double(JobApplicationPdfGenerator, generate: document) }

  before do
    allow(JobApplicationPdfGenerator).to receive(:new).and_return(generator)
  end

  describe "#shortlist" do
    subject(:mail) do
      described_class.shortlist(vacancy.id, job_applications.map(&:id), recipient_email, publisher.id)
    end

    it "prepares each application as a secure Notify file" do
      first_file = mail.personalisation.fetch(:application_1)
      second_file = mail.personalisation.fetch(:application_2)

      expect(first_file).to include(
        file: Base64.strict_encode64(pdf_data),
        confirm_email_before_download: true,
        retention_period: "1 week",
      )
      expect(second_file).to include(
        file: Base64.strict_encode64(pdf_data),
        confirm_email_before_download: true,
        retention_period: "1 week",
      )
      expect(first_file.fetch(:filename)).to end_with("-application.pdf")
      expect(second_file.fetch(:filename)).to end_with("-application.pdf")
    end

    it "supplies blank values for unused Notify file placeholders" do
      expect(mail.personalisation.fetch(:application_3)).to eq("")
      expect(mail.personalisation.fetch(:application_8)).to eq("")
      expect(mail.personalisation).not_to have_key(:application_9)
    end

    it "supplies the applicant name alongside each file placeholder" do
      sorted_applications = job_applications.sort_by { |job_application| [job_application.last_name, job_application.first_name] }

      expect(mail.personalisation).to include(
        applicant_name_1: sorted_applications.first.name,
        applicant_name_2: sorted_applications.second.name,
        applicant_name_3: "",
        applicant_name_8: "",
      )
      expect(mail.personalisation).not_to have_key(:applicant_name_9)
    end

    it "addresses the configured Notify template" do
      expect(mail.to).to eq([recipient_email])
      expect(mail.template_id).to eq(described_class::TEMPLATE_ID)
      expect(mail.personalisation).to include(
        job_title: vacancy.job_title,
        organisation_name: vacancy.organisation_name,
      )
    end

    it "triggers a `publisher_shortlist` email event", :dfe_analytics do
      mail.deliver_now

      expect(:publisher_shortlist).to have_been_enqueued_as_analytics_event(with_data: %i[uid notify_template]) # rubocop:disable RSpec/ExpectActual
    end
  end
end
