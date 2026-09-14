require "rails_helper"

RSpec.describe "Shortlist shares" do
  let(:vacancy) { create(:vacancy) }
  let(:organisation) { vacancy.organisations.first }
  let(:publisher) { create(:publisher, accepted_terms_at: 1.day.ago) }
  let(:job_applications) { create_list(:job_application, 2, :status_shortlisted, vacancy:) }
  let(:job_application_ids) { job_applications.map(&:id) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_organisation).and_return(organisation) # rubocop:disable RSpec/AnyInstance
    sign_in(publisher, scope: :publisher)
  end

  after { sign_out(publisher) }

  describe "GET #new" do
    subject(:request) do
      get new_organisation_job_shortlist_share_path(vacancy.id), params: {
        publishers_job_application_tag_form: { job_applications: job_application_ids },
      }
    end

    it "shows the recipient email form and selected applications" do
      request
      page = Capybara.string(response.body)

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
      expect(page).to have_field("Hiring manager's email address")
      job_applications.each { |job_application| expect(page).to have_content(job_application.name) }
    end

    it "does not create a job application batch" do
      expect { request }.not_to change(JobApplicationBatch, :count)
    end

    context "without an application" do
      let(:job_application_ids) { [] }

      it "returns to the shortlisted tab with an error" do
        request

        expect(response).to redirect_to(organisation_job_job_applications_path(vacancy.id, anchor: :shortlisted))
        expect(flash[:shortlisted]).to eq("Select at least one application to share")
      end
    end

    context "with more than 8 applications" do
      let(:job_application_ids) { Array.new(9) { create(:job_application, :status_shortlisted, vacancy:).id } }

      it "returns to the shortlisted tab with an error" do
        request

        expect(response).to redirect_to(organisation_job_job_applications_path(vacancy.id, anchor: :shortlisted))
        expect(flash[:shortlisted]).to eq("Select no more than 8 applications to share")
      end
    end

    context "with an application that is not shortlisted" do
      let(:job_application_ids) { [create(:job_application, :status_submitted, vacancy:).id] }

      it "returns to the shortlisted tab with an error" do
        request

        expect(response).to redirect_to(organisation_job_job_applications_path(vacancy.id, anchor: :shortlisted))
        expect(flash[:shortlisted]).to eq("Select shortlisted applications only")
      end
    end

    context "when the vacancy uses uploaded application forms" do
      before { vacancy.update!(receive_applications: :uploaded_form) }

      it "returns to the shortlisted tab with an error" do
        request

        expect(response).to redirect_to(organisation_job_job_applications_path(vacancy.id, anchor: :shortlisted))
        expect(flash[:shortlisted]).to eq("Sharing uploaded application forms is not currently supported")
      end
    end
  end

  describe "POST #review" do
    subject(:request) do
      post review_organisation_job_shortlist_share_path(vacancy.id), params: {
        publishers_job_application_shortlist_share_form: { email:, job_application_ids: },
      }
    end

    context "with a valid email" do
      let(:email) { "hiring.manager@example.com" }

      it "shows the review screen without sending anything" do
        expect { request }.not_to have_enqueued_job

        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:review)
        expect(response.body).to include(email)
        expect(Capybara.string(response.body)).to have_button("Send applications")
        job_applications.each { |job_application| expect(response.body).to include(job_application.name) }
      end
    end

    context "with an invalid email" do
      let(:email) { "not-an-email" }

      it "shows the form error" do
        request

        expect(response).to have_http_status(:unprocessable_content)
        expect(response).to render_template(:new)
        expect(Capybara.string(response.body)).to have_content("Enter a valid email address in the correct format, like name@example.com")
      end
    end
  end

  describe "POST #create" do
    subject(:request) do
      post organisation_job_shortlist_share_path(vacancy.id), params: {
        publishers_job_application_shortlist_share_form: { email:, job_application_ids: },
      }
    end

    let(:email) { "hiring.manager@example.com" }
    let(:delivery) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

    before do
      allow(Publishers::ShortlistShareMailer).to receive(:shortlist).and_return(delivery)
    end

    it "queues the shortlist email and redirects to the shortlisted tab" do
      request

      expect(Publishers::ShortlistShareMailer)
        .to have_received(:shortlist)
        .with(vacancy.id, job_application_ids, email, publisher.id)
      expect(delivery).to have_received(:deliver_later)
      expect(response).to redirect_to(organisation_job_job_applications_path(vacancy.id, anchor: :shortlisted))
      expect(flash[:success]).to eq("The selected applications are being sent to the hiring manager")
    end

    context "with an invalid email" do
      let(:email) { "not-an-email" }

      it "does not queue the shortlist email" do
        request

        expect(Publishers::ShortlistShareMailer).not_to have_received(:shortlist)
        expect(response).to have_http_status(:unprocessable_content)
        expect(response).to render_template(:new)
      end
    end
  end
end
