require "rails_helper"

RSpec.describe Conversation do
  let(:conversation) { create(:conversation) }
  let(:job_application) { create(:job_application, status: "interviewing") }

  describe "associations" do
    it { is_expected.to belong_to(:job_application) }
    it { is_expected.to have_many(:messages).dependent(:destroy) }
  end

  describe "#last_message_at" do
    let!(:conversation) { create(:conversation, job_application: job_application) }

    context "when conversation has no messages" do
      it "returns nil" do
        expect(conversation.last_message_at).to be_nil
      end
    end

    context "when conversation has messages" do
      it "returns the timestamp of the most recent message" do
        recent_message = create(:publisher_message, conversation: conversation, created_at: 30.minutes.ago)
        expect(conversation.reload.last_message_at.to_i).to eq(recent_message.created_at.to_i)
      end
    end

    context "when a new message is added" do
      it "updates when a new message is created" do
        expect { create(:publisher_message, conversation: conversation) }
          .to(change { conversation.reload.last_message_at })
      end
    end
  end

  describe "#has_unread_messages" do
    let!(:conversation) { create(:conversation, job_application: job_application) }

    context "when conversation has no messages" do
      it "returns false" do
        expect(conversation.has_unread_messages).to be false
      end
    end

    context "when all messages are read" do
      let!(:jobseeker_message) { create(:jobseeker_message, conversation: conversation) }
      let!(:publisher_message) { create(:publisher_message, conversation: conversation) }

      it "returns false" do
        jobseeker_message.mark_as_read!
        publisher_message.mark_as_read!
        expect(conversation.reload.has_unread_messages).to be false
      end
    end

    context "when there are unread messages" do
      let!(:publisher_message) { create(:publisher_message, conversation: conversation) }

      before do
        create(:jobseeker_message, conversation: conversation)
      end

      it "returns true" do
        publisher_message.mark_as_read!
        expect(conversation.reload.has_unread_messages).to be true
      end
    end

    context "when a message is marked as read" do
      let!(:unread_message) { create(:jobseeker_message, conversation: conversation, read: false) }

      it "updates when all messages become read" do
        expect { unread_message.mark_as_read! }
          .to change { conversation.reload.has_unread_messages }
          .from(true).to(false)
      end

      context "when other messages remain unread" do
        before do
          create(:publisher_message, conversation: conversation, read: false)
        end

        it "remains true if other messages are still unread" do
          expect { unread_message.mark_as_read! }
            .not_to change { conversation.reload.has_unread_messages }
            .from(true)
        end
      end
    end

    context "when a new unread message is created" do
      before do
        message = create(:jobseeker_message, conversation: conversation, read: true)
        message.mark_as_read!
      end

      it "updates to true when new unread message is added" do
        expect { create(:publisher_message, conversation: conversation, read: false) }
          .to change { conversation.reload.has_unread_messages }
          .from(false).to(true)
      end
    end
  end
end
