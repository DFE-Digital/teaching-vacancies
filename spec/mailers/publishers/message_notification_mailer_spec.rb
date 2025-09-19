require "rails_helper"

RSpec.describe Publishers::MessageNotificationMailer do
  let(:publisher) { create(:publisher, given_name: "John") }

  describe "#messages_received" do
    let(:mail) { described_class.messages_received(publisher: publisher, message_count: message_count) }

    context "with one message" do
      let(:message_count) { 1 }

      it "has the correct subject" do
        expect(mail.subject).to eq("You have a new message")
      end

      it "has the correct recipient" do
        expect(mail.to).to eq([publisher.email])
      end

      it "includes the singular message text" do
        expect(mail.body.encoded).to include("You have received a message in your Teaching Vacancies account")
      end

      it "includes the publisher's name" do
        expect(mail.body.encoded).to include("Dear John")
      end
    end

    context "with multiple messages" do
      let(:message_count) { 3 }

      it "has the correct subject" do
        expect(mail.subject).to eq("You have 3 new messages")
      end

      it "includes the plural message text" do
        expect(mail.body.encoded).to include("You have received 3 messages in your Teaching Vacancies account")
      end
    end
  end
end
