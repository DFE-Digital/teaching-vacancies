require "rails_helper"

RSpec.describe "Publishers::Vacancies::JobApplications::Messages" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :expired, organisations: [organisation]) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }

  before do
    sign_in(publisher, scope: :publisher)
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(Publishers::BaseController).to receive(:current_organisation).and_return(organisation)
    # rubocop:enable RSpec/AnyInstance
  end

  after { sign_out publisher }

  describe "POST /organisation/jobs/:vacancy_id/job_applications/:job_application_id/messages" do
    let(:messages_path) { organisation_job_job_application_messages_path(vacancy.id, job_application.id) }
    let(:message_params) do
      {
        publishers_job_application_messages_form: { content: "Test message content" },
      }
    end

    context "with valid message content" do
      it "creates a message and redirects with success" do
        expect {
          post messages_path, params: message_params
        }.to change(Message, :count).by(1)

        message = Message.last
        expect(message.content.to_plain_text).to eq("Test message content")
        expect(message.sender).to eq(publisher)

        expect(response).to redirect_to(organisation_job_job_application_path(vacancy.id, job_application.id, tab: "messages"))
        expect(flash[:success]).to be_present
      end
    end

    context "with blank message content" do
      let(:message_params) do
        {
          publishers_job_application_messages_form: { content: "" },
        }
      end

      it "does not create a message and renders show with validation errors" do
        expect {
          post messages_path, params: message_params
        }.not_to change(Message, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template("publishers/vacancies/job_applications/show")
        expect(assigns(:message_form).errors[:content]).to include("Please enter your message")
        expect(assigns(:messages)).to eq([])
      end

      context "when conversation has existing messages" do
        let!(:conversation) { create(:conversation, job_application: job_application) }
        let!(:existing_message) { create(:message, conversation: conversation, content: "Previous message") }

        it "renders show with existing messages and validation errors" do
          expect {
            post messages_path, params: message_params
          }.not_to change(Message, :count)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template("publishers/vacancies/job_applications/show")
          expect(assigns(:message_form).errors[:content]).to include("Please enter your message")
          expect(assigns(:messages)).to include(existing_message)
        end
      end
    end
  end
end
