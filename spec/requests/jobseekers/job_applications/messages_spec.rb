require "rails_helper"

RSpec.describe "Jobseekers::JobApplications::Messages" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, :live) }
  let(:job_application) { create(:job_application, :submitted, jobseeker: jobseeker, vacancy: vacancy, status: "interviewing") }

  before do
    sign_in(jobseeker, scope: :jobseeker)
  end

  describe "POST /jobseekers/job_applications/:job_application_id/messages" do
    let(:message_params) do
      {
        publishers_job_application_messages_form: { content: "Test message content" },
      }
    end

    context "when conversation exists" do
      let!(:conversation) { create(:conversation, job_application: job_application) }

      it "creates a message and redirects with success" do
        expect {
          post jobseekers_job_application_messages_path(job_application), params: message_params
        }.to change(Message, :count).by(1)

        message = Message.last
        expect(message.content.to_plain_text).to eq("Test message content")
        expect(message.sender).to eq(jobseeker)
        expect(message.conversation).to eq(conversation)

        expect(response).to redirect_to(jobseekers_job_application_path(job_application, tab: "messages"))
        expect(flash[:success]).to be_present
      end

      context "with blank message content" do
        let(:message_params) do
          {
            publishers_job_application_messages_form: { content: "" },
          }
        end

        it "does not create a message and renders show with validation errors" do
          expect {
            post jobseekers_job_application_messages_path(job_application), params: message_params
          }.not_to change(Message, :count)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template("jobseekers/job_applications/show")
          expect(assigns(:message).errors[:content]).to include("Please enter your message")
          expect(assigns(:messages)).to eq([])
        end

        context "when conversation has existing messages" do
          let!(:existing_message) { create(:jobseeker_message, conversation: conversation, content: "Previous message") }

          it "renders show with existing messages and validation errors" do
            expect {
              post jobseekers_job_application_messages_path(job_application), params: message_params
            }.not_to change(Message, :count)

            expect(response).to have_http_status(:unprocessable_entity)
            expect(response).to render_template("jobseekers/job_applications/show")
            expect(assigns(:message).errors[:content]).to include("Please enter your message")
            expect(assigns(:messages)).to include(existing_message)
          end
        end
      end
    end
  end
end
