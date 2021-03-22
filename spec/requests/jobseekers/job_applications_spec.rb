require "rails_helper"

RSpec.describe "Job applications", type: :request do
  let(:vacancy) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: build(:school) }]) }
  let(:jobseeker) { create(:jobseeker) }

  before do
    allow(JobseekerApplicationsFeature).to receive(:enabled?).and_return(true)
    sign_in(jobseeker, scope: :jobseeker)
  end

  describe "GET #new" do
    context "when the job is not listed" do
      let(:vacancy) { create(:vacancy, :expired, organisation_vacancies_attributes: [{ organisation: build(:school) }]) }

      it "does not trigger a `vacancy_apply_clicked` event and returns not found" do
        expect { get new_jobseekers_job_job_application_path(vacancy.id) }.to not_have_triggered_event(:vacancy_apply_clicked)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the job is listed" do
      it "triggers a `vacancy_apply_clicked` event" do
        expect { get new_jobseekers_job_job_application_path(vacancy.id) }
          .to have_triggered_event(:vacancy_apply_clicked).with_data(vacancy_id: vacancy.id)
      end

      context "when a job application for the job already exists" do
        let!(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy) }

        it "redirects to `jobseekers_job_applications_path`" do
          expect(get(new_jobseekers_job_job_application_path(vacancy.id))).to redirect_to(jobseekers_job_applications_path)
        end
      end
    end
  end

  describe "POST #create" do
    context "when the job is not listed" do
      let(:vacancy) { create(:vacancy, :expired, organisation_vacancies_attributes: [{ organisation: build(:school) }]) }

      it "does not create a job application and returns not found" do
        expect { post new_jobseekers_job_job_application_path(vacancy.id) }.to(not_change { JobApplication.count })

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when a job application for the job already exists" do
      let!(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy) }

      it "redirects to `jobseekers_job_applications_path`" do
        expect(post(jobseekers_job_job_application_path(vacancy.id))).to redirect_to(jobseekers_job_applications_path)
      end
    end
  end

  describe "POST #submit" do
    let!(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy) }
    let(:button) { I18n.t("buttons.submit_application") }
    let(:confirm_data_accurate) { 1 }
    let(:confirm_data_usage) { 1 }
    let(:params) do
      {
        jobseekers_job_application_review_form:
          { confirm_data_accurate: confirm_data_accurate, confirm_data_usage: confirm_data_usage },
        commit: button,
      }
    end

    context "when the job is not listed" do
      let(:vacancy) { create(:vacancy, :expired, organisation_vacancies_attributes: [{ organisation: build(:school) }]) }

      it "raises an error and does not submit the job application or send email" do
        assert_emails 0 do
          expect { post jobseekers_job_application_submit_path(job_application.id), params: params }
            .to not_change { job_application.reload.status }
            .and raise_error(ActionController::RoutingError, /non-listed/)
        end
      end
    end

    context "when the job application is not a draft" do
      let!(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

      it "raises an error and does not submit the job application or send email" do
        assert_emails 0 do
          expect { post jobseekers_job_application_submit_path(job_application.id), params: params }
            .to not_change { job_application.reload.status }
            .and raise_error(ActionController::RoutingError, /non-draft/)
        end
      end
    end

    context "when the commit param is `Save as draft`" do
      let(:button) { I18n.t("buttons.save_as_draft") }

      it "does not submit the job application and redirects to applications dashboard" do
        assert_emails 0 do
          expect { post jobseekers_job_application_submit_path(job_application.id), params: params }
            .to(not_change { job_application.reload.status })

          expect(response).to redirect_to(jobseekers_job_applications_path)
        end
      end
    end

    context "when the commit param is `Submit application`" do
      context "when the review form is invalid" do
        let(:confirm_data_usage) { 0 }

        it "does not submit the job application or send email and renders the review template" do
          assert_emails 0 do
            expect { post jobseekers_job_application_submit_path(job_application.id), params: params }
              .to(not_change { job_application.reload.status })

            expect(response).to render_template(:review)
          end
        end
      end

      context "when the review form is valid" do
        it "submits the job application and sends email" do
          assert_emails 1 do
            expect { post jobseekers_job_application_submit_path(job_application.id), params: params }
              .to change { job_application.reload.status }.from("draft").to("submitted")
          end
        end
      end
    end
  end

  describe "GET #confirm_destroy" do
    context "when the application is a draft" do
      let!(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy) }

      it "shows a confirmation page" do
        expect(get(jobseekers_job_application_confirm_destroy_path(job_application.id))).to render_template(:confirm_destroy)
      end
    end

    context "when the application is not a draft" do
      let!(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

      it "raises an error" do
        expect { get(jobseekers_job_application_confirm_destroy_path(job_application.id)) }.to raise_error(ActionController::RoutingError, /non-draft/)
      end
    end
  end

  describe "DELETE #destroy" do
    context "when the application is a draft" do
      let!(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy) }

      it "deletes the application" do
        expect { delete(jobseekers_job_application_path(job_application.id)) }.to change { JobApplication.count }.by(-1)
      end

      it "redirects back to the index of applications" do
        expect(delete(jobseekers_job_application_path(job_application.id))).to redirect_to(jobseekers_job_applications_path)
      end
    end

    context "when the application is not a draft" do
      let!(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

      it "raises an error and does not delete the application" do
        expect { delete(jobseekers_job_application_path(job_application.id)) }.to raise_error(ActionController::RoutingError, /non-draft/)
        expect(JobApplication.count).to eq(1)
      end
    end
  end
end
