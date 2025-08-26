require "rails_helper"

RSpec.describe MessagesHelper do
  let(:email) { Faker::Internet.email(domain: TEST_EMAIL_DOMAIN) }
  let(:jobseeker) { build_stubbed(:jobseeker, email: email) }
  let(:publisher) { build_stubbed(:publisher, given_name: "John", family_name: "Smith") }
  let(:job_application) { build_stubbed(:job_application, first_name: "Jane", last_name: "Doe") }
  let(:vacancy) { build_stubbed(:vacancy) }
  let(:current_organisation) { build_stubbed(:school, name: "Current School") }

  describe "#sender_is_current_user?" do
    context "when current user is a jobseeker" do
      let(:current_user_type) { "jobseeker" }

      it "returns true when message sender is a jobseeker" do
        message = build_stubbed(:message, :from_jobseeker)
        expect(helper.sender_is_current_user?(message, current_user_type)).to be true
      end

      it "returns false when message sender is a publisher" do
        message = build_stubbed(:message, :from_publisher)
        expect(helper.sender_is_current_user?(message, current_user_type)).to be false
      end
    end

    context "when current user is a publisher" do
      let(:current_user_type) { "publisher" }

      it "returns true when message sender is a publisher" do
        message = build_stubbed(:message, :from_publisher)
        expect(helper.sender_is_current_user?(message, current_user_type)).to be true
      end

      it "returns false when message sender is a jobseeker" do
        message = build_stubbed(:message, :from_jobseeker)
        expect(helper.sender_is_current_user?(message, current_user_type)).to be false
      end
    end
  end

  describe "#message_sender_display_name" do
    it "returns jobseeker name and email when sender is a jobseeker" do
      message = build_stubbed(:message, :from_jobseeker, sender: jobseeker)
      expected = "Jane Doe <#{email}>"

      result = helper.message_sender_display_name(message, job_application, vacancy)
      expect(result).to eq(expected)
    end

    it "returns publisher name and organisation when sender is a publisher" do
      message = build_stubbed(:message, :from_publisher, sender: publisher)
      expected = "John Smith, #{vacancy.organisation_name} <via Teaching Vacancies>"

      result = helper.message_sender_display_name(message, job_application, vacancy)
      expect(result).to eq(expected)
    end
  end

  describe "#message_card_title_class" do
    context "when sender is current user" do
      it "returns blue class" do
        message = build_stubbed(:message, :from_jobseeker)
        expect(helper.message_card_title_class(message, "jobseeker")).to eq("message-header--blue")
      end
    end

    context "when sender is not current user" do
      it "returns grey class" do
        message = build_stubbed(:message, :from_publisher)
        expect(helper.message_card_title_class(message, "jobseeker")).to eq("message-header--grey")
      end
    end
  end
end
