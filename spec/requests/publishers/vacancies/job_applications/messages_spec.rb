require "rails_helper"

RSpec.describe "Publishers::Vacancies::JobApplications::Messages" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :live, organisations: [organisation]) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }
  let(:messages_path) { organisation_job_job_application_messages_path(vacancy.id, job_application.id) }

  before do
    sign_in(publisher, scope: :publisher)
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(Publishers::BaseController).to receive(:current_organisation).and_return(organisation)
    # rubocop:enable RSpec/AnyInstance
  end

  after { sign_out publisher }

  describe "POST /organisation/jobs/:vacancy_id/job_applications/:job_application_id/messages" do
    let(:message_params) { { publisher_message: { content: "Test message content" } } }
    let(:blank_message_params) { { publisher_message: { content: "" } } }

    context "when no conversation exists" do
      it "creates a conversation with the message and redirects with success" do
        expect {
          post messages_path, params: message_params
        }.to change(Conversation, :count).by(1).and change(Message, :count).by(1)

        conversation = job_application.reload.conversations.sole
        expect(conversation.messages.sole.sender).to eq(publisher)
        expect(conversation.last_message_at).to be_present
        expect(response).to redirect_to(messages_organisation_job_job_application_path(vacancy.id, job_application.id))
      end

      it "does not create a conversation when the message is blank" do
        expect {
          post messages_path, params: blank_message_params
        }.not_to(change { [Conversation.count, Message.count] })

        expect(response).to have_http_status(:unprocessable_content)
        expect(assigns(:message).errors[:content]).to include("Please enter your message")
        expect(assigns(:messages)).to eq([])
      end
    end

    context "when a conversation exists" do
      let!(:conversation) { create(:conversation, job_application: job_application) }

      it "adds the message to the existing conversation" do
        expect {
          post messages_path, params: message_params
        }.to change { conversation.messages.count }.by(1)

        expect(Conversation.count).to eq(1)
      end

      it "does not add a blank message" do
        expect {
          post messages_path, params: blank_message_params
        }.not_to(change { conversation.messages.count })

        expect(response).to have_http_status(:unprocessable_content)
        expect(assigns(:messages)).to eq(conversation.messages.to_a)
      end
    end
  end
end
