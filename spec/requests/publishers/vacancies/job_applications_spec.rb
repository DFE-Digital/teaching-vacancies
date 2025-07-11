require "rails_helper"

RSpec.describe "Job applications" do
  let(:vacancy) { create(:vacancy) }
  let(:organisation) { vacancy.organisations.first }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }
  let(:publisher) { create(:publisher, accepted_terms_at: 1.day.ago) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_organisation).and_return(organisation)
    sign_in(publisher, scope: :publisher)
  end

  after { sign_out(publisher) }

  describe "GET #show" do
    context "when the job application status is not draft or withdrawn" do
      it "renders the show page" do
        expect(get(organisation_job_job_application_path(vacancy.id, job_application.id))).to render_template(:show)
      end
    end

    context "when the job application status is submitted" do
      it "updates the job application status to reviewed" do
        expect { get(organisation_job_job_application_path(vacancy.id, job_application.id)) }
          .to change { job_application.reload.status }.from("submitted").to("reviewed")
      end
    end

    context "when the job application status is not submitted" do
      let(:job_application) { create(:job_application, :status_shortlisted, vacancy: vacancy) }

      it "does not update the job application status" do
        expect { get(organisation_job_job_application_path(vacancy.id, job_application.id)) }
          .to(not_change { job_application.reload.status })
      end
    end

    context "when the job application status is draft" do
      let(:job_application) { create(:job_application, :status_draft, vacancy: vacancy) }

      it "raises an error" do
        expect { get(organisation_job_job_application_path(vacancy.id, job_application.id)) }
          .to raise_error(ActionController::RoutingError, /Cannot view/)
      end
    end

    context "when the job application status is withdrawn" do
      let(:job_application) { create(:job_application, :status_withdrawn, vacancy: vacancy) }

      it "redirects to the withdrawn page" do
        expect(get(organisation_job_job_application_path(vacancy.id, job_application.id)))
          .to redirect_to(organisation_job_job_application_withdrawn_path(vacancy.id, job_application.id))
      end
    end
  end

  describe "GET #index" do
    context "when the vacancy does not belong to the current organisation" do
      let(:other_organisation) { create(:school) }
      let(:vacancy) { create(:vacancy) }

      before do
        allow_any_instance_of(ApplicationController)
          .to receive(:current_organisation).and_return(other_organisation)
      end

      it "returns not_found" do
        get organisation_job_job_applications_path(vacancy.id)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the vacancy is not listed" do
      let(:vacancy) { create(:vacancy, publish_on: 1.day.from_now) }

      it "returns not_found" do
        get organisation_job_job_applications_path(vacancy.id)

        expect(response).to have_http_status(:not_found)
      end
    end

    it "renders the index page" do
      expect(get(organisation_job_job_applications_path(vacancy.id))).to render_template(:index)
    end
  end

  describe "GET #download_pdf" do
    context "when the job application status is not draft or withdrawn" do
      it "sends a PDF file" do
        get organisation_job_job_application_download_pdf_path(vacancy.id, job_application.id)

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/pdf")
        expect(response.headers["Content-Disposition"]).to include("inline")
        expect(response.headers["Content-Disposition"]).to include("job_application_#{job_application.id}.pdf")
      end
    end
  end

  describe "GET #tag" do
    subject { response }

    let(:vacancy) { create(:vacancy, job_title: "teacher-job") }
    let(:job_application_2) { create(:job_application, :status_submitted, vacancy: vacancy) }
    let(:params) do
      {
        publishers_job_application_tag_form: {
          job_applications:,
          origin:,
        },
        target:,
      }
    end
    let(:job_applications) { [job_application.id, job_application_2.id] }
    let(:origin) { "new" }
    let(:target) { nil }

    before do
      get(tag_organisation_job_job_applications_path(vacancy.id), params:)
    end

    context "when preparing to tag job applications" do
      it { is_expected.to render_template(:tag) }

      context "when no job application selected" do
        let(:job_applications) { [] }

        it { is_expected.to redirect_to(organisation_job_job_applications_path(vacancy.id, anchor: origin)) }
      end
    end

    context "when downloading selected job applications" do
      let(:target) { "download" }

      it "sends zip file with PDFs" do
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/zip")
        expect(response.headers["Content-Disposition"]).to include("applications_#{vacancy.job_title}.zip")
      end

      context "when no job application selected" do
        let(:job_applications) { [] }

        it { is_expected.to redirect_to(organisation_job_job_applications_path(vacancy.id, anchor: origin)) }
      end
    end

    context "when exporting selected job applications" do
      let(:target) { "export" }

      it "sends csv file" do
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("text/csv")
        expect(response.headers["Content-Disposition"]).to include("applications_offered_#{vacancy.job_title}.csv")
      end

      context "when no job application selected" do
        let(:job_applications) { [] }

        it { is_expected.to redirect_to(organisation_job_job_applications_path(vacancy.id, anchor: origin)) }
      end
    end

    context "when copying emails" do
      let(:target) { "emails" }

      it "sends json files with emails" do
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/json")
        expect(response.headers["Content-Disposition"]).to include("applications_emails_#{vacancy.job_title}.json")
      end

      context "when no job application selected" do
        let(:job_applications) { [] }

        it { is_expected.to redirect_to(organisation_job_job_applications_path(vacancy.id, anchor: origin)) }
      end
    end

    context "when declining job offer" do
      let(:target) { "declined" }

      it { is_expected.to render_template(:declined_date) }
    end
  end

  describe "POST #update_tag" do
    subject { response }

    let(:vacancy) { create(:vacancy, job_title: "teacher-job") }
    let(:job_application_2) { create(:job_application, :status_submitted, vacancy: vacancy) }
    let(:job_applications) { [job_application.id, job_application_2.id] }
    let(:origin) { "new" }
    let(:status) { nil }
    let(:form_params) { { origin:, status:, job_applications: } }
    let(:params) { { publishers_job_application_tag_form: form_params } }
    let(:request) do
      post(update_tag_organisation_job_job_applications_path(vacancy.id), params:)
    end

    before { request }

    context "when no status selected" do
      it { is_expected.to render_template(:tag) }
    end

    context "when progressing to interviewing" do
      let(:request) { nil }
      let(:status) { "interviewing" }
      let(:batch) { JobApplicationBatch.last }

      it "creates a batch and redirect" do
        expect { post(update_tag_organisation_job_job_applications_path(vacancy.id), params:) }
          .to change(JobApplicationBatch, :count).by(1)

        expect(response).to redirect_to organisation_job_job_application_batch_references_and_declaration_path(vacancy.id, batch.id, Wicked::FIRST_STEP)
      end
    end

    context "when progressing to offered" do
      let(:status) { "offered" }

      it { is_expected.to render_template(:offered_date) }
    end

    context "when declined_at invalid" do
      let(:status) { "declined" }
      let(:form_params) do
        { origin:, status:, job_applications: }.merge(
          "declined_at(1i)" => 2025,
          "declined_at(2i)" => 120,
          "declined_at(3i)" => 11,
        )
      end

      it { is_expected.to render_template(:declined_date) }
    end

    context "when progressing to other status" do
      let(:request) { nil }
      let(:status) { "shortlisted" }

      it "update status and redirects" do
        expect { post(update_tag_organisation_job_job_applications_path(vacancy.id), params:) }
          .to change { job_application.reload.status }.from("submitted").to(status)

        expect(response).to redirect_to organisation_job_job_applications_path(vacancy.id, anchor: origin)
      end
    end
  end

  describe "POST #offer" do
    subject { response }

    let(:params) do
      { publishers_job_application_tag_form: form_params }
    end
    let(:vacancy) { create(:vacancy, job_title: "teacher-job") }
    let(:job_application_2) { create(:job_application, :status_submitted, vacancy: vacancy) }
    let(:job_applications) { [job_application.id, job_application_2.id] }
    let(:origin) { "new" }
    let(:status) { nil }
    let(:form_params) do
      { origin:, status:, job_applications: }
    end

    context "when offered_at invalid" do
      let(:status) { "offered" }
      let(:field) { :offered_at }

      context "when job applications ommitted" do
        let(:job_applications) { nil }

        before do
          post(offer_organisation_job_job_applications_path(vacancy.id), params:)
        end

        it { is_expected.to redirect_to organisation_job_job_applications_path(vacancy.id, anchor: origin) }
      end

      context "when date ommitted" do
        it "update job application status" do
          expect { post(offer_organisation_job_job_applications_path(vacancy.id), params:) }
            .to change { job_application.reload.status }.from("submitted").to(status)
          expect(response).to redirect_to organisation_job_job_applications_path(vacancy.id, anchor: origin)
        end

        it "does not update date" do
          expect { post(offer_organisation_job_job_applications_path(vacancy.id), params:) }
            .to not_change { job_application.reload.public_send(field) }.from(nil)
        end
      end

      context "when date is invalid" do
        let(:form_params) do
          { origin:, status:, job_applications: }.merge("offered_at(1i)" => 111)
        end

        before do
          post(offer_organisation_job_job_applications_path(vacancy.id), params:)
        end

        it { is_expected.to render_template("offered_date") }
      end

      context "when date is valid" do
        let(:form_params) do
          { origin:, status:, job_applications: }.merge(
            "offered_at(1i)" => 2025,
            "offered_at(2i)" => 12,
            "offered_at(3i)" => 11,
          )
        end

        it "update job application" do
          expect { post(offer_organisation_job_job_applications_path(vacancy.id), params:) }
            .to change { job_application.reload.status }.from("submitted").to(status)
          expect(response).to redirect_to organisation_job_job_applications_path(vacancy.id, anchor: origin)
        end

        it "update date" do
          expect { post(offer_organisation_job_job_applications_path(vacancy.id), params:) }
            .to change { job_application.reload.public_send(field) }.from(nil).to(Date.new(2025, 12, 11))
        end
      end
    end
  end
end
