require "rails_helper"

RSpec.describe Conversation do
  let(:conversation) { create(:conversation) }
  let(:job_application) { create(:job_application, status: "interviewing") }

  describe "associations" do
    it { is_expected.to belong_to(:job_application) }
    it { is_expected.to have_many(:messages).dependent(:destroy) }
    it { is_expected.to have_many(:jobseeker_messages).dependent(:destroy) }
    it { is_expected.to have_many(:publisher_messages).dependent(:destroy) }
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

  describe "#has_unread_jobseeker_messages" do
    let!(:conversation) { create(:conversation, job_application: job_application) }

    context "when conversation has no messages" do
      it "returns false" do
        expect(conversation.has_unread_jobseeker_messages).to be false
      end
    end

    context "when all jobseeker messages are read" do
      let!(:jobseeker_message) { create(:jobseeker_message, conversation: conversation) }
      let!(:publisher_message) { create(:publisher_message, conversation: conversation) }

      it "returns false" do
        jobseeker_message.mark_as_read!
        publisher_message.mark_as_read!
        expect(conversation.reload.has_unread_jobseeker_messages).to be false
      end
    end

    context "when there are unread jobseeker messages" do
      let!(:publisher_message) { create(:publisher_message, conversation: conversation, read: false) }

      before do
        create(:jobseeker_message, conversation: conversation, read: false)
      end

      it "returns true" do
        publisher_message.mark_as_read!
        expect(conversation.reload.has_unread_jobseeker_messages).to be true
      end
    end

    context "when a jobseeker message is marked as read" do
      let!(:unread_jobseeker_message) { create(:jobseeker_message, conversation: conversation, read: false) }

      it "updates when all jobseeker messages become read" do
        expect { unread_jobseeker_message.mark_as_read! }
          .to change { conversation.reload.has_unread_jobseeker_messages }
          .from(true).to(false)
      end

      context "when other jobseeker messages remain unread" do
        before do
          create(:jobseeker_message, conversation: conversation, read: false)
        end

        it "remains true if other jobseeker messages are still unread" do
          expect { unread_jobseeker_message.mark_as_read! }
            .not_to change { conversation.reload.has_unread_jobseeker_messages }
            .from(true)
        end
      end

      context "when only publisher messages remain unread" do
        before do
          create(:publisher_message, conversation: conversation, read: false)
        end

        it "becomes false even if publisher messages are unread" do
          expect { unread_jobseeker_message.mark_as_read! }
            .to change { conversation.reload.has_unread_jobseeker_messages }
            .from(true).to(false)
        end
      end
    end

    context "when a new unread jobseeker message is created" do
      before do
        message = create(:jobseeker_message, conversation: conversation, read: true)
        message.mark_as_read!
      end

      it "updates to true when new unread jobseeker message is added" do
        expect { create(:jobseeker_message, conversation: conversation, read: false) }
          .to change { conversation.reload.has_unread_jobseeker_messages }
          .from(false).to(true)
      end

      it "remains false when unread publisher message is added" do
        expect { create(:publisher_message, conversation: conversation, read: false) }
          .not_to change { conversation.reload.has_unread_jobseeker_messages }
          .from(false)
      end
    end
  end

  describe "searchable content updates" do
    let(:vacancy) { create(:vacancy, :live, job_title: "Science Teacher") }
    let(:job_application) { create(:job_application, vacancy: vacancy, first_name: "John", last_name: "Smith", status: "interviewing") }
    let(:conversation) { create(:conversation, job_application: job_application) }

    describe "on conversation creation" do
      it "populates searchable_content" do
        new_conversation = build(:conversation, job_application: job_application)

        expect { new_conversation.save! }.to change { new_conversation.searchable_content }.from(nil)
        expect(new_conversation.searchable_content).to include("science")
        expect(new_conversation.searchable_content).to include("john")
        expect(new_conversation.searchable_content).to include("smith")
      end
    end

    describe "when job title changes" do
      it "updates searchable_content when vacancy job_title changes" do
        conversation
        initial_content = conversation.reload.searchable_content

        expect {
          vacancy.update!(job_title: "Math Teacher")
          conversation.reload
        }.to change(conversation, :searchable_content).from(initial_content)

        expect(conversation.searchable_content).to include("math")
        expect(conversation.searchable_content).not_to include("science")
      end

      it "does not update when non-searchable vacancy fields change" do
        conversation # Create the conversation
        conversation.reload.searchable_content

        expect {
          vacancy.update!(salary: "£30,000")
          conversation.reload
        }.not_to(change(conversation, :searchable_content))
      end
    end

    describe "when candidate name changes" do
      it "updates searchable_content when job_application name changes" do
        conversation
        job_application.reload
        conversation.reload.searchable_content
        job_application.update!(first_name: "Jane", last_name: "Doe")
        conversation.reload

        expect(conversation.searchable_content).to include("jane")
        expect(conversation.searchable_content).to include("doe")
        expect(conversation.searchable_content).not_to include("john")
        expect(conversation.searchable_content).not_to include("smith")
      end

      it "does not trigger callback when job_application has no conversations" do
        job_application_without_conversation = create(:job_application, vacancy: vacancy)

        expect {
          job_application_without_conversation.update!(first_name: "New Name")
        }.not_to raise_error
      end
    end

    describe "when message content changes via Action Text" do
      let!(:message) { create(:jobseeker_message, conversation: conversation, content: "Initial message content") }

      it "updates searchable_content when message content is updated" do
        initial_content = conversation.reload.searchable_content
        expect(initial_content).to include("initial")

        expect {
          message.content = "Updated message content with keywords"
          message.save!
          conversation.reload
        }.to change(conversation, :searchable_content).from(initial_content)

        expect(conversation.searchable_content).to include("updated")
        expect(conversation.searchable_content).to include("keywords")
      end

      it "updates searchable_content when new message is created" do
        initial_content = conversation.reload.searchable_content

        expect {
          create(:publisher_message, conversation: conversation, content: "New message with unique words")
          conversation.reload
        }.to change(conversation, :searchable_content).from(initial_content)

        expect(conversation.searchable_content).to include("unique")
      end
    end
  end
end
