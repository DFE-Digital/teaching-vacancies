require "rails_helper"

RSpec.describe SendApplicationsReceivedYesterdayJob do
  subject(:job) { described_class.new }

  let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

  describe "#perform" do
    context "when vacancies have contact emails" do
      it "sends emails to contact emails and groups by recipient" do
        publisher = create(:publisher, email: "publisher@example.com")
        vacancy1 = create(:vacancy, contact_email: "hr@school.com", publisher: publisher)
        vacancy2 = create(:vacancy, contact_email: "hr@school.com", publisher: publisher)

        create(:job_application, :submitted, vacancy: vacancy1, submitted_at: Date.yesterday)
        create(:job_application, :submitted, vacancy: vacancy2, submitted_at: Date.yesterday)

        expect(Publishers::JobApplicationMailer)
          .to receive(:applications_received)
          .with(vacancies: [vacancy1, vacancy2], recipient_email: "hr@school.com")
          .and_return(message_delivery)

        expect(message_delivery).to receive(:deliver_later)

        job.perform
      end
    end

    context "when vacancies have no contact email but publisher has email" do
      it "falls back to publisher email" do
        publisher = create(:publisher, email: "publisher@example.com")
        vacancy = create(:vacancy, contact_email: nil, publisher: publisher)

        create(:job_application, :submitted, vacancy: vacancy, submitted_at: Date.yesterday)

        expect(Publishers::JobApplicationMailer)
          .to receive(:applications_received)
          .with(vacancies: [vacancy], recipient_email: "publisher@example.com")
          .and_return(message_delivery)

        expect(message_delivery).to receive(:deliver_later)

        job.perform
      end
    end

    context "when vacancy has empty contact email" do
      it "falls back to publisher email" do
        publisher = create(:publisher, email: "publisher@example.com")
        vacancy = create(:vacancy, contact_email: "", publisher: publisher)

        create(:job_application, :submitted, vacancy: vacancy, submitted_at: Date.yesterday)

        expect(Publishers::JobApplicationMailer)
          .to receive(:applications_received)
          .with(vacancies: [vacancy], recipient_email: "publisher@example.com")
          .and_return(message_delivery)

        expect(message_delivery).to receive(:deliver_later)

        job.perform
      end
    end

    context "when neither vacancy nor publisher has email" do
      it "skips sending email" do
        publisher = create(:publisher, email: nil)
        vacancy = create(:vacancy, contact_email: nil, publisher: publisher)

        create(:job_application, :submitted, vacancy: vacancy, submitted_at: Date.yesterday)

        expect(Publishers::JobApplicationMailer).not_to receive(:applications_received)

        job.perform
      end
    end

    context "when applications were submitted on different days" do
      it "only includes applications from yesterday" do
        publisher = create(:publisher, email: "publisher@example.com")
        vacancy = create(:vacancy, contact_email: nil, publisher: publisher)

        create(:job_application, :submitted, vacancy: vacancy, submitted_at: Date.yesterday)
        create(:job_application, :submitted, vacancy: vacancy, submitted_at: Date.current)
        create(:job_application, :submitted, vacancy: vacancy, submitted_at: 2.days.ago)

        expect(Publishers::JobApplicationMailer)
          .to receive(:applications_received)
          .with(vacancies: [vacancy], recipient_email: "publisher@example.com")
          .and_return(message_delivery)

        expect(message_delivery).to receive(:deliver_later)

        job.perform
      end
    end

    context "when multiple recipients exist" do
      it "sends separate emails to each recipient and groups vacancies by recipient" do
        publisher1 = create(:publisher, email: "publisher1@example.com")
        publisher2 = create(:publisher, email: "publisher2@example.com")
        publisher3 = create(:publisher, email: "publisher3@example.com")

        vacancy1 = create(:vacancy, contact_email: "hr@school1.com", publisher: publisher1)
        vacancy2 = create(:vacancy, contact_email: "hr@school1.com", publisher: publisher2) # Different publisher, same contact email
        vacancy3 = create(:vacancy, contact_email: nil, publisher: publisher3)

        create(:job_application, :submitted, vacancy: vacancy1, submitted_at: Date.yesterday)
        create(:job_application, :submitted, vacancy: vacancy2, submitted_at: Date.yesterday)
        create(:job_application, :submitted, vacancy: vacancy3, submitted_at: Date.yesterday)

        expect(Publishers::JobApplicationMailer)
          .to receive(:applications_received)
          .with(vacancies: [vacancy1, vacancy2], recipient_email: "hr@school1.com")
          .and_return(message_delivery)

        expect(Publishers::JobApplicationMailer)
          .to receive(:applications_received)
          .with(vacancies: [vacancy3], recipient_email: "publisher3@example.com")
          .and_return(message_delivery)

        expect(message_delivery).to receive(:deliver_later).twice

        job.perform
      end
    end
  end
end
