require "rails_helper"

RSpec.describe "Job applications self disclosure" do
  let(:jobseeker) { create(:jobseeker) }
  let(:organisations) { [create(:school)] }
  let(:vacancy) { create(:vacancy, organisations:) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy:, jobseeker:) }
  let(:self_disclosure_request) { create(:self_disclosure_request, status:, job_application:) }
  let(:self_disclosure) { create(:self_disclosure, :pending, self_disclosure_request:) }

  before do
    sign_in(jobseeker, scope: :jobseeker)
  end

  after { sign_out(jobseeker) }

  describe "GET #show" do
    before do
      self_disclosure
      get jobseekers_job_application_self_disclosure_path(job_application, :personal_details)
    end

    context "when the self disclosure has not been enabled" do
      let(:self_disclosure) { nil }

      it { expect(response).to redirect_to(jobseekers_job_application_path(job_application)) }
    end

    context "when the self disclosure is managed outside TV" do
      let(:status) { "manual" }

      it { expect(response).to redirect_to(jobseekers_job_application_path(job_application)) }
    end

    context "when the self disclosure is pending" do
      let(:status) { "sent" }

      it { expect(response).to have_http_status(:ok) }
    end

    context "when the self disclosure has been completed" do
      let(:status) { "received" }

      it { expect(response).to redirect_to(jobseekers_job_application_path(job_application)) }
    end
  end

  describe "PATCH #update" do
    before { self_disclosure }

    let(:request) do
      patch jobseekers_job_application_self_disclosure_path(job_application, :personal_details), params:
    end
    let(:status) { "sent" }
    let(:params) do
      {
        jobseekers_job_applications_self_disclosure_personal_details_form: {
          "name" => "jobseeker name",
          "address_line_1" => "long street",
          "city" => "london",
          "postcode" => "ec1 2aa",
          "country" => "uk",
          "phone_number" => "1243235234",
          "date_of_birth(1i)" => "1930",
          "date_of_birth(2i)" => "1",
          "date_of_birth(3i)" => "19",
          "has_unspent_convictions" => "true",
          "has_spent_convictions" => "false",
        },
      }
    end

    context "when valid" do
      it { expect { request }.to change { self_disclosure.reload.name }.to("jobseeker name") }
      it { expect { request }.to change { self_disclosure.reload.address_line_1 }.to("long street") }
      it { expect { request }.to change { self_disclosure.reload.city }.to("london") }
      it { expect { request }.to change { self_disclosure.reload.postcode }.to("ec1 2aa") }
      it { expect { request }.to change { self_disclosure.reload.phone_number }.to("1243235234") }
      it { expect { request }.to change { self_disclosure.reload.date_of_birth }.to(Date.new(1930, 1, 19)) }
      it { expect { request }.to change { self_disclosure.reload.has_unspent_convictions }.to(true) }
      it { expect { request }.to change { self_disclosure.reload.has_spent_convictions }.to(false) }
      it { expect(request).to redirect_to jobseekers_job_application_self_disclosure_path(job_application, :barred_list) }
    end

    context "when last step" do
      let(:request) do
        patch jobseekers_job_application_self_disclosure_path(job_application, :confirmation), params:
      end
      let(:params) do
        {
          jobseekers_job_applications_self_disclosure_confirmation_form: {
            "agreed_for_processing" => "true",
            "agreed_for_criminal_record" => "true",
            "agreed_for_organisation_update" => "true",
            "agreed_for_information_sharing" => "true",
          },
        }
      end

      it { expect { request }.to change { self_disclosure_request.reload.status }.from("sent").to("received") }
      it { expect(request).to redirect_to completed_jobseekers_job_application_self_disclosure_index_path(job_application) }
    end

    context "when invalid" do
      let(:params) { {} }

      it { expect { request }.not_to change(self_disclosure, :reload) }
      it { expect(request).to render_template(:personal_details) }
    end
  end
end
