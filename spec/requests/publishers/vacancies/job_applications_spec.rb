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
    let(:vacancy) { create(:vacancy, job_title: "teacher-job") }
    let(:job_application_2) { create(:job_application, :status_submitted, vacancy: vacancy) }
    let(:job_applications) { [job_application.id, job_application_2.id] }
    let(:tag_params) do
      {
        publishers_job_application_tag_form: { job_applications:, origin: },
      }
    end
    let(:origin) { "new" }

    context "when preparing to tag job applications" do
      it "renders the tag template" do
        get tag_organisation_job_job_applications_path(vacancy.id), params: tag_params
        expect(response).to render_template(:tag)
      end
    end

    context "when no job application selected" do
      let(:job_applications) { [] }

      it "redirects to index when form is invalid" do
        get tag_organisation_job_job_applications_path(vacancy.id), params: tag_params
        expect(response).to redirect_to(organisation_job_job_applications_path(vacancy.id, anchor: origin))
      end
    end

    context "when downloading selected job applications" do
      it "sends zip file with PDFs" do
        get tag_organisation_job_job_applications_path(vacancy.id), params: tag_params.merge(download_selected: "true")

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/zip")
        expect(response.headers["Content-Disposition"]).to include("applications_#{vacancy.job_title}.zip")
      end
    end

    context "when downloading with missing job applications" do
      let(:job_applications) { [] }

      it "renders index when download form is invalid" do
        get tag_organisation_job_job_applications_path(vacancy.id), params: tag_params.merge(download_selected: "true")
        expect(response).to redirect_to(organisation_job_job_applications_path(vacancy.id, anchor: origin))
      end
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

    context "when form missing selected status" do
      before do
        post(update_tag_organisation_job_job_applications_path(vacancy.id), params:)
      end

      it { is_expected.to render_template(:tag) }
    end

    context "when form missing job applications" do
      let(:job_applications) { [] }
      let(:status) { "shortlisted" }

      before do
        post(update_tag_organisation_job_job_applications_path(vacancy.id), params:)
      end

      it { is_expected.to redirect_to organisation_job_job_applications_path(vacancy.id, anchor: origin) }
    end

    context "when form valid" do
      let(:status) { "shortlisted" }

      it "update status and redirects" do
        expect { post(update_tag_organisation_job_job_applications_path(vacancy.id), params:) }
          .to change { job_application.reload.status }.from("submitted").to(status)

        expect(response).to redirect_to organisation_job_job_applications_path(vacancy.id, anchor: origin)
      end
    end
  end
end
