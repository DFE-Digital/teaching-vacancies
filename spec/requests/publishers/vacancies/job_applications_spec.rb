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
          .to redirect_to(organisation_job_job_application_terminal_path(vacancy.id, job_application.id))
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
  end

  describe "GET #download" do
    context "when the job application status is not draft or withdrawn" do
      it "sends a PDF file" do
        get organisation_job_job_application_download_path(vacancy.id, job_application.id)

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/pdf")
        expect(response.headers["Content-Disposition"]).to include("inline")
        expect(response.headers["Content-Disposition"]).to include("application_form.pdf")
      end
    end
  end

  describe "GET #download_messages" do
    context "when messages exist for the job application" do
      let(:conversation) { create(:conversation, job_application: job_application) }

      before do
        create(:publisher_message, conversation: conversation, sender: publisher)
        create(:jobseeker_message, conversation: conversation, sender: job_application.jobseeker)
      end

      it "sends a PDF file with messages" do
        get download_messages_organisation_job_job_application_path(vacancy.id, job_application.id)

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/pdf")
        expect(response.headers["Content-Disposition"]).to include("attachment")
        expect(response.headers["Content-Disposition"]).to include("messages_#{job_application.first_name}_#{job_application.last_name}_#{vacancy.job_title.parameterize}.pdf")
      end
    end

    context "when no messages exist for the job application" do
      it "sends a PDF file with no messages text" do
        get download_messages_organisation_job_job_application_path(vacancy.id, job_application.id)

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/pdf")
        expect(response.headers["Content-Disposition"]).to include("attachment")
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
        tag_action: target,
      }
    end
    let(:job_applications) { [job_application.id, job_application_2.id] }
    let(:origin) { "submitted" }
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

      it "sends bundle zip file" do
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/zip")
        expect(response.headers["Content-Disposition"]).to include("applications_offered_#{vacancy.job_title}.zip")
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

    context "when add interview datetime" do
      let(:target) { "interview_datetime" }

      it { is_expected.to render_template(:interview_datetime) }
    end
  end

  describe "POST #update_tag" do
    subject { response }

    let(:vacancy) { create(:vacancy, job_title: "teacher-job") }
    let(:job_application_2) { create(:job_application, :status_submitted, vacancy: vacancy) }
    let(:job_applications) { [job_application.id, job_application_2.id] }
    let(:origin) { "submitted" }
    let(:status) { nil }
    let(:form_params) { { origin:, status:, job_applications: } }
    let(:form_name) { "TagForm" }
    let(:params) { { form_name:, publishers_job_application_tag_form: form_params } }
    let(:request) do
      post(update_tag_organisation_job_job_applications_path(vacancy.id), params:)
    end

    describe "validations" do
      context "when form missing selected status" do
        before { request }

        it { is_expected.to render_template(:tag) }
      end

      context "when form missing job applications" do
        let(:job_applications) { [] }
        let(:status) { "shortlisted" }

        before { request }

        it { is_expected.to redirect_to organisation_job_job_applications_path(vacancy.id, anchor: origin) }
      end
    end

    context "when progressing to status other than interviewing" do
      let(:status) { "shortlisted" }

      it "update status and redirects" do
        expect { request }.to change { job_application.reload.status }.from("submitted").to(status)

        expect(response).to redirect_to organisation_job_job_applications_path(vacancy.id, anchor: origin)
      end
    end

    context "when progressing to interviewing" do
      let(:status) { "interviewing" }
      let(:batch) { JobApplicationBatch.last }

      it "creates a batch and redirect" do
        expect { request }.to change(JobApplicationBatch, :count).by(1)

        expect(response).to redirect_to organisation_job_job_application_batch_references_and_self_disclosure_path(vacancy.id, batch.id, Wicked::FIRST_STEP)
      end
    end

    context "when progressing to offered" do
      let(:status) { "offered" }

      before { request }

      it { is_expected.to render_template(:offered_date) }
    end

    context "when declined_at invalid" do
      let(:status) { "declined" }
      let(:params) do
        {
          form_name: "DeclinedForm",
          publishers_job_application_declined_form: form_params,
        }
      end
      let(:form_params) do
        { origin:, status:, job_applications: }.merge(
          "declined_at(1i)" => 2025,
          "declined_at(2i)" => 120,
          "declined_at(3i)" => 11,
        )
      end

      before { request }

      it { is_expected.to render_template(:declined_date) }
    end

    context "when declined date is before offered date" do
      let(:job_application) { create(:job_application, :status_offered, vacancy: vacancy, offered_at: Date.new(2025, 12, 15)) }
      let(:status) { "declined" }
      let(:params) do
        {
          form_name: "DeclinedForm",
          publishers_job_application_declined_form: form_params,
        }
      end
      let(:form_params) do
        { origin:, status:, job_applications: [job_application.id] }.merge(
          "declined_at(1i)" => 2025,
          "declined_at(2i)" => 12,
          "declined_at(3i)" => 10,
        )
      end

      before { request }

      it { is_expected.to render_template(:declined_date) }
    end

    context "when declining without an offered date" do
      let(:job_application) { create(:job_application, :status_offered, vacancy: vacancy, offered_at: nil) }
      let(:status) { "declined" }
      let(:params) do
        {
          form_name: "DeclinedForm",
          publishers_job_application_declined_form: form_params,
        }
      end
      let(:form_params) do
        { origin:, status:, job_applications: [job_application.id] }.merge(
          "declined_at(1i)" => 2025,
          "declined_at(2i)" => 12,
          "declined_at(3i)" => 15,
        )
      end

      it "updates status successfully" do
        expect { request }.to change { job_application.reload.status }.from("offered").to("declined")
        expect(response).to redirect_to organisation_job_job_applications_path(vacancy.id, anchor: origin)
      end
    end

    context "when progressing to unsuccessful_interview" do
      let(:status) { "unsuccessful_interview" }

      before { request }

      it { is_expected.to render_template(:feedback_date) }
    end
  end

  describe "POST #offer" do
    subject { response }

    let(:vacancy) { create(:vacancy, job_title: "teacher-job") }
    let(:job_application) { create(:job_application, :status_interviewing, vacancy: vacancy) }
    let(:job_application_2) { create(:job_application, :status_interviewing, vacancy: vacancy) }
    let(:job_applications) { [job_application.id, job_application_2.id] }
    let(:form_params) do
      { origin:, status:, job_applications: }
    end

    describe "offered form" do
      let(:origin) { "interviewing" }
      let(:params) do
        {
          form_name: "OfferedForm",
          publishers_job_application_offered_form: form_params,
        }
      end
      let(:status) { "offered" }

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
            .to change { job_application.reload.status }.from("interviewing").to(status)
          expect(response).to redirect_to organisation_job_job_applications_path(vacancy.id, anchor: origin)
        end

        it "does not update date" do
          expect { post(offer_organisation_job_job_applications_path(vacancy.id), params:) }
            .to not_change { job_application.reload.offered_at }.from(nil)
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
        let(:offer_date) { Date.current }
        let(:form_params) do
          { origin:, status:, job_applications: }.merge(
            "offered_at(1i)" => offer_date.year,
            "offered_at(2i)" => offer_date.month,
            "offered_at(3i)" => offer_date.day,
          )
        end

        it "update job application" do
          expect { post(offer_organisation_job_job_applications_path(vacancy.id), params:) }
            .to change { job_application.reload.status }.from("interviewing").to(status)
          expect(response).to redirect_to organisation_job_job_applications_path(vacancy.id, anchor: origin)
        end

        it "update date" do
          expect { post(offer_organisation_job_job_applications_path(vacancy.id), params:) }
            .to change { job_application.reload.offered_at }.from(nil).to(offer_date)
        end
      end

      context "when offered date is before interview date" do
        let(:interview_date) { Date.current }
        let(:offer_date) { interview_date - 1.day }
        let(:job_application) { create(:job_application, :status_interviewing, vacancy: vacancy, interviewing_at: interview_date) }
        let(:form_params) do
          { origin:, status:, job_applications: [job_application.id] }.merge(
            "offered_at(1i)" => offer_date.year,
            "offered_at(2i)" => offer_date.month,
            "offered_at(3i)" => offer_date.day,
          )
        end

        before do
          post(offer_organisation_job_job_applications_path(vacancy.id), params:)
        end

        it { is_expected.to render_template("offered_date") }
      end

      context "when offering without an interview date" do
        let(:job_application) { create(:job_application, :status_interviewing, vacancy: vacancy, interviewing_at: nil) }
        let(:form_params) do
          { origin:, status:, job_applications: [job_application.id] }.merge(
            "offered_at(1i)" => 2025,
            "offered_at(2i)" => 12,
            "offered_at(3i)" => 15,
          )
        end

        it "updates status and date successfully" do
          expect { post(offer_organisation_job_job_applications_path(vacancy.id), params:) }
            .to change { job_application.reload.status }.from("interviewing").to("offered")
            .and change { job_application.reload.offered_at }.from(nil).to(Date.new(2025, 12, 15))
          expect(response).to redirect_to organisation_job_job_applications_path(vacancy.id, anchor: origin)
        end
      end
    end

    describe "feedback form" do
      let(:feedback_date) { Date.current }
      let(:origin) { "interviewing" }
      let(:params) do
        {
          form_name: "FeedbackForm",
          publishers_job_application_feedback_form: form_params,
        }
      end
      let(:status) { "unsuccessful_interview" }

      context "when params valid" do
        let(:form_params) do
          { origin:, status:, job_applications: }.merge(
            "interview_feedback_received_at(1i)" => feedback_date.year,
            "interview_feedback_received_at(2i)" => feedback_date.month,
            "interview_feedback_received_at(3i)" => feedback_date.day,
            "interview_feedback_received" => "true",
          )
        end

        it "update job application" do
          expect { post(offer_organisation_job_job_applications_path(vacancy.id), params:) }
            .to change { job_application.reload.status }.from("interviewing").to(status)
          expect(response).to redirect_to organisation_job_job_applications_path(vacancy.id, anchor: origin)
        end

        it "update date" do
          expect { post(offer_organisation_job_job_applications_path(vacancy.id), params:) }
            .to change { job_application.reload.interview_feedback_received_at }.from(nil).to(feedback_date)
        end
      end

      context "when params invalid" do
        let(:form_params) do
          { origin:, status:, job_applications: }.merge(
            "interview_feedback_received_at(1i)" => 111,
            "interview_feedback_received" => "true",
          )
        end

        before do
          post(offer_organisation_job_job_applications_path(vacancy.id), params:)
        end

        it { is_expected.to render_template("feedback_date") }
      end

      context "when feedback date is before interview date" do
        let(:job_application) { create(:job_application, :status_interviewing, vacancy: vacancy, interviewing_at: Date.new(2025, 12, 15)) }
        let(:form_params) do
          { origin:, status:, job_applications: [job_application.id] }.merge(
            "interview_feedback_received_at(1i)" => 2025,
            "interview_feedback_received_at(2i)" => 12,
            "interview_feedback_received_at(3i)" => 10,
            "interview_feedback_received" => "true",
          )
        end

        before do
          post(offer_organisation_job_job_applications_path(vacancy.id), params:)
        end

        it { is_expected.to render_template("feedback_date") }
      end

      context "when providing feedback without an interview date" do
        let(:job_application) { create(:job_application, :status_interviewing, vacancy: vacancy, interviewing_at: nil) }
        let(:form_params) do
          { origin:, status:, job_applications: [job_application.id] }.merge(
            "interview_feedback_received_at(1i)" => 2025,
            "interview_feedback_received_at(2i)" => 12,
            "interview_feedback_received_at(3i)" => 20,
            "interview_feedback_received" => "true",
          )
        end

        it "updates status and date successfully" do
          expect { post(offer_organisation_job_job_applications_path(vacancy.id), params:) }
            .to change { job_application.reload.status }.from("interviewing").to("unsuccessful_interview")
            .and change { job_application.reload.interview_feedback_received_at }.from(nil).to(Date.new(2025, 12, 20))
          expect(response).to redirect_to organisation_job_job_applications_path(vacancy.id, anchor: origin)
        end
      end
    end

    describe "interview datetime form" do
      let(:origin) { "interviewing" }
      let(:params) do
        {
          form_name: "InterviewDatetimeForm",
          publishers_job_application_interview_datetime_form: form_params,
        }
      end
      let(:status) { "interviewing" }

      context "when params valid" do
        let(:form_params) do
          { origin:, job_applications: }.merge(
            "interview_date(1i)" => 2025,
            "interview_date(2i)" => 9,
            "interview_date(3i)" => 1,
            "interview_time"     => "10:45am", # rubocop:disable Layout/HashAlignment
          )
        end

        it "update interviewing_at" do
          old_interviewing_at = job_application.interviewing_at
          expect { post(offer_organisation_job_job_applications_path(vacancy.id), params:) }
            .to change { job_application.reload.interviewing_at }.from(old_interviewing_at).to(Time.zone.local(2025, 9, 1, 10, 45))
          expect(response).to redirect_to organisation_job_job_applications_path(vacancy.id, anchor: origin)
        end
      end

      context "when params invalid date" do
        let(:form_params) do
          { origin:, job_applications: }.merge(
            "interview_date(1i)" => 2025,
            "interview_date(2i)" => 9,
            "interview_date(3i)" => "badday",
            "interview_time"     => "10:45am", # rubocop:disable Layout/HashAlignment
          )
        end

        before do
          post(offer_organisation_job_job_applications_path(vacancy.id), params:)
        end

        it { is_expected.to render_template("interview_datetime") }
      end

      context "when params invalid time" do
        let(:form_params) do
          { origin:, job_applications: }.merge(
            "interview_date(1i)" => 2025,
            "interview_date(2i)" => 9,
            "interview_date(3i)" => 1,
            "interview_time"     => "45:99am", # rubocop:disable Layout/HashAlignment
          )
        end

        before do
          post(offer_organisation_job_job_applications_path(vacancy.id), params:)
        end

        it { is_expected.to render_template("interview_datetime") }
      end

      context "when job_application is not interviewing" do
        let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }
        let(:form_params) do
          { origin:, job_applications: [job_application.id] }.merge(
            "interview_date(1i)" => 2025,
            "interview_date(2i)" => 9,
            "interview_date(3i)" => 1,
            "interview_time"     => "11:30am", # rubocop:disable Layout/HashAlignment
          )
        end

        before do
          post(offer_organisation_job_job_applications_path(vacancy.id), params:)
        end

        it { is_expected.to render_template("interview_datetime") }
      end
    end
  end
end
