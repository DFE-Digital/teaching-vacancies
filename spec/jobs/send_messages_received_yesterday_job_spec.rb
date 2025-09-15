require "rails_helper"

RSpec.describe SendMessagesReceivedYesterdayJob do
  describe "#perform" do
    let(:organisation) { create(:organisation) }
    let(:publisher) { create(:publisher, organisations: [organisation]) }
    let(:vacancy) { create(:vacancy, organisations: [organisation]) }
    let(:job_application) { create(:job_application, vacancy: vacancy) }
    let(:conversation) { create(:conversation, job_application: job_application) }
    let(:jobseeker) { create(:jobseeker) }

    before do
      allow(Publishers::MessageNotificationMailer).to receive(:messages_received).and_call_original
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_later)
      # rubocop:enable RSpec/AnyInstance
    end

    context "when there are unread messages from yesterday" do
      before do
        travel_to(1.day.ago) do
          create(:jobseeker_message, conversation: conversation, sender: jobseeker, read: false)
          create(:jobseeker_message, conversation: conversation, sender: jobseeker, read: false)
        end
      end

      it "finds publishers with messages received yesterday" do
        expect {
          described_class.new.perform
        }.to change { ActionMailer::Base.deliveries.size }.by(1)

        expect(Publishers::MessageNotificationMailer)
          .to have_received(:messages_received)
          .with(publisher: publisher, message_count: 2)
      end

      it "only sends one email per publisher even with multiple messages" do
        travel_to(1.day.ago) do
          # Add more unread messages from yesterday
          create(:jobseeker_message, conversation: conversation, sender: jobseeker, read: false)
        end

        expect {
          described_class.new.perform
        }.to change { ActionMailer::Base.deliveries.size }.by(1)
      end

      it "only sends emails to publishers who received messages, not others" do
        # Create a different publisher with their own vacancy and messages
        other_organisation = create(:organisation)
        other_publisher = create(:publisher, organisations: [other_organisation])
        other_vacancy = create(:vacancy, organisations: [other_organisation])
        other_job_application = create(:job_application, vacancy: other_vacancy)
        other_conversation = create(:conversation, job_application: other_job_application)

        travel_to(1.day.ago) do
          # Unread message to other publisher (should get email)
          create(:jobseeker_message, conversation: other_conversation, sender: jobseeker, read: false)
        end

        expect {
          described_class.new.perform
        }.to change { ActionMailer::Base.deliveries.size }.by(2) # Both publishers get emails

        expect(Publishers::MessageNotificationMailer)
          .to have_received(:messages_received)
          .with(publisher: publisher, message_count: 2)

        expect(Publishers::MessageNotificationMailer)
          .to have_received(:messages_received)
          .with(publisher: other_publisher, message_count: 1)
      end

      it "does not send emails about messages from other days to the same publisher" do
        # Add unread messages from different days for the same publisher
        travel_to(3.days.ago) do
          create(:jobseeker_message, conversation: conversation, sender: jobseeker, read: false)
          create(:jobseeker_message, conversation: conversation, sender: jobseeker, read: false)
        end

        travel_to(5.days.ago) do
          create(:jobseeker_message, conversation: conversation, sender: jobseeker, read: false)
        end

        # Only yesterday's unread messages (2) should count, not the 3 older ones
        expect {
          described_class.new.perform
        }.to change { ActionMailer::Base.deliveries.size }.by(1)

        expect(Publishers::MessageNotificationMailer)
          .to have_received(:messages_received)
          .with(publisher: publisher, message_count: 2) # Only yesterday's 2 messages
      end

      it "only counts unread messages from yesterday" do
        travel_to(1.day.ago) do
          # Create one more unread message and one read message
          create(:jobseeker_message, conversation: conversation, sender: jobseeker, read: false)
          create(:jobseeker_message, conversation: conversation, sender: jobseeker, read: true)
        end

        # Should count original 2 unread + 1 new unread = 3 (not the read one)
        expect {
          described_class.new.perform
        }.to change { ActionMailer::Base.deliveries.size }.by(1)

        expect(Publishers::MessageNotificationMailer)
          .to have_received(:messages_received)
          .with(publisher: publisher, message_count: 3) # Only unread messages
      end
    end

    context "when there are no unread messages from yesterday" do
      before do
        # Create unread message from today
        create(:jobseeker_message, conversation: conversation, sender: jobseeker, read: false)

        # Create unread message from 2 days ago
        travel_to(2.days.ago) do
          create(:jobseeker_message, conversation: conversation, sender: jobseeker, read: false)
        end
      end

      it "does not send any emails" do
        expect {
          described_class.new.perform
        }.not_to(change { ActionMailer::Base.deliveries.size })
      end
    end

    context "when publisher has no email" do
      let(:publisher_without_email) { create(:publisher, email: nil, organisations: [organisation]) }
      let(:vacancy_without_email) { create(:vacancy, organisations: [organisation]) }
      let(:job_application_without_email) { create(:job_application, vacancy: vacancy_without_email) }
      let(:conversation_without_email) { create(:conversation, job_application: job_application_without_email) }

      before do
        travel_to(1.day.ago) do
          create(:jobseeker_message, conversation: conversation_without_email, sender: jobseeker, read: false)
        end
      end

      it "does not send emails to publishers without email addresses" do
        expect {
          described_class.new.perform
        }.not_to(change { ActionMailer::Base.deliveries.size })
      end
    end

    context "when there are only publisher messages (not jobseeker messages)" do
      before do
        travel_to(1.day.ago) do
          create(:publisher_message, conversation: conversation, sender: publisher, read: false)
        end
      end

      it "does not send emails for publisher messages" do
        expect {
          described_class.new.perform
        }.not_to(change { ActionMailer::Base.deliveries.size })
      end
    end

    context "when all messages from yesterday are already read" do
      before do
        travel_to(1.day.ago) do
          create(:jobseeker_message, conversation: conversation, sender: jobseeker, read: true)
          create(:jobseeker_message, conversation: conversation, sender: jobseeker, read: true)
        end
      end

      it "does not send emails for already read messages" do
        expect {
          described_class.new.perform
        }.not_to(change { ActionMailer::Base.deliveries.size })
      end
    end
  end
end
