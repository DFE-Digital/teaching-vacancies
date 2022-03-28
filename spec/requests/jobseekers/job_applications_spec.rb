require "rails_helper"

RSpec.describe "Job applications" do
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let(:jobseeker) { create(:jobseeker) }

  describe "GET #new" do
    context "when the jobseeker is not signed in" do
      before { get(new_jobseekers_job_job_application_path(vacancy.id)) }

      it "redirects to the sign in page with a flash message explaining why" do
        follow_redirect!

        expect(flash[:alert]).to be_present
      end
    end

    context "when the jobseeker is signed in " do
      before { sign_in(jobseeker, scope: :jobseeker) }

      context "when the job is not live" do
        let(:vacancy) { create(:vacancy, :expired, organisations: [build(:school)]) }

        it "does not trigger a `vacancy_apply_clicked` event and returns not found" do
          expect { get new_jobseekers_job_job_application_path(vacancy.id) }.to not_have_triggered_event(:vacancy_apply_clicked)

          expect(response).to have_http_status(:not_found)
        end
      end

      context "when the job is live" do
        it "triggers a `vacancy_apply_clicked` event" do
          expect { get new_jobseekers_job_job_application_path(vacancy.id) }
            .to have_triggered_event(:vacancy_apply_clicked).with_data(vacancy_id: anonymised_form_of(vacancy.id))
        end

        context "when a job application for the job already exists" do
          let!(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy) }

          it "redirects to `jobseekers_job_applications_path`" do
            expect(get(new_jobseekers_job_job_application_path(vacancy.id))).to redirect_to(jobseekers_job_applications_path)
          end
        end

        context "when a non-draft job application already exists" do
          let!(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }
          let(:new_vacancy) { create(:vacancy, organisations: [build(:school)]) }

          it "redirects to `new_quick_apply_jobseekers_job_job_application_path`" do
            expect(get(new_jobseekers_job_job_application_path(new_vacancy.id)))
              .to redirect_to(new_quick_apply_jobseekers_job_job_application_path(new_vacancy.id))
          end
        end

        context "when the vacancy does not enable job applications" do
          let(:vacancy) { create(:vacancy, enable_job_applications: false, organisations: [build(:school)]) }

          it "raises an error" do
            expect { get new_jobseekers_job_job_application_path(vacancy.id) }
              .to raise_error(ActionController::RoutingError, /Cannot apply for this vacancy/)
          end
        end
      end
    end
  end

  describe "POST #create" do
    before { sign_in(jobseeker, scope: :jobseeker) }

    context "when the job is not live" do
      let(:vacancy) { create(:vacancy, :expired, organisations: [build(:school)]) }

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

    context "when the vacancy does not enable job applications" do
      let(:vacancy) { create(:vacancy, enable_job_applications: false, organisations: [build(:school)]) }

      it "raises an error" do
        expect { post(jobseekers_job_job_application_path(vacancy.id)) }
          .to raise_error(ActionController::RoutingError, /Cannot apply for this vacancy/)
      end
    end

    it "creates a job application and redirects to the build path" do
      expect { post(jobseekers_job_job_application_path(vacancy.id)) }
        .to change { jobseeker.job_applications.count }.by(1)

      expect(response)
        .to redirect_to(jobseekers_job_application_build_path(jobseeker.job_applications.first.id, :personal_details))
    end
  end

  describe "GET #new_quick_apply" do
    before { sign_in(jobseeker, scope: :jobseeker) }

    context "when a job application for the job already exists" do
      let!(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy) }

      it "redirects to `jobseekers_job_applications_path`" do
        expect(get(new_quick_apply_jobseekers_job_job_application_path(vacancy.id)))
          .to redirect_to(jobseekers_job_applications_path)
      end
    end

    context "when there are no non-draft applications" do
      let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }

      it "raises an error" do
        expect { get new_quick_apply_jobseekers_job_job_application_path(vacancy.id) }
          .to raise_error(ActionController::RoutingError, /non-draft/)
      end
    end

    context "when the vacancy does not enable job applications" do
      let(:vacancy) { create(:vacancy, enable_job_applications: false, organisations: [build(:school)]) }

      it "raises an error" do
        expect { get new_jobseekers_job_job_application_path(vacancy.id) }
          .to raise_error(ActionController::RoutingError, /Cannot apply for this vacancy/)
      end
    end

    context "when there are non-draft applications" do
      let(:old_vacancy) { create(:vacancy, organisations: [build(:school)]) }
      let!(:recent_job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: old_vacancy) }

      context "when the job is not listed" do
        let(:vacancy) { create(:vacancy, :expired, organisations: [build(:school)]) }

        it "returns not found" do
          get new_quick_apply_jobseekers_job_job_application_path(vacancy.id)

          expect(response).to have_http_status(:not_found)
        end
      end

      it "renders the new_quick_apply template" do
        get new_quick_apply_jobseekers_job_job_application_path(vacancy.id)

        expect(response).to render_template(:new_quick_apply)
      end
    end
  end

  describe "POST #quick_apply" do
    before { sign_in(jobseeker, scope: :jobseeker) }

    context "when a job application for the job already exists" do
      let!(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy) }

      it "redirects to `jobseekers_job_applications_path`" do
        expect(post(quick_apply_jobseekers_job_job_application_path(vacancy.id)))
          .to redirect_to(jobseekers_job_applications_path)
      end
    end

    context "when there are no non-draft applications" do
      let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }

      it "raises an error" do
        expect { post quick_apply_jobseekers_job_job_application_path(vacancy.id) }
          .to raise_error(ActionController::RoutingError, /non-draft/)
      end
    end

    context "when the vacancy does not enable job applications" do
      let(:vacancy) { create(:vacancy, enable_job_applications: false, organisations: [build(:school)]) }

      it "raises an error" do
        expect { post quick_apply_jobseekers_job_job_application_path(vacancy.id) }
          .to raise_error(ActionController::RoutingError, /Cannot apply for this vacancy/)
      end
    end

    context "when there are non-draft applications" do
      let(:old_vacancy) { create(:vacancy, organisations: [build(:school)]) }
      let!(:recent_job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: old_vacancy) }

      context "when the job is not listed" do
        let(:vacancy) { create(:vacancy, :expired, organisations: [build(:school)]) }

        it "returns not found" do
          post quick_apply_jobseekers_job_job_application_path(vacancy.id)

          expect(response).to have_http_status(:not_found)
        end
      end

      it "creates a job application and redirects to the review path" do
        expect { post(quick_apply_jobseekers_job_job_application_path(vacancy.id)) }
          .to change { jobseeker.job_applications.count }.by(1)

        expect(response)
          .to redirect_to(jobseekers_job_application_review_path(jobseeker.job_applications.draft.first.id))
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
      }
    end

    before { sign_in(jobseeker, scope: :jobseeker) }

    context "when the job is not listed" do
      let(:vacancy) { create(:vacancy, :expired, organisations: [build(:school)]) }

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

    context "when `Submit application`" do
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

  describe "GET #show" do
    before { sign_in(jobseeker, scope: :jobseeker) }

    context "when the application is not a draft" do
      let!(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

      it "shows the application page" do
        expect(get(jobseekers_job_application_path(job_application.id))).to render_template(:show)
      end
    end

    context "when the application is a draft" do
      let!(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy) }

      it "raises an error" do
        expect { get(jobseekers_job_application_path(job_application.id)) }.to raise_error(ActionController::RoutingError, /draft/)
      end
    end
  end

  describe "GET #confirm_destroy" do
    before { sign_in(jobseeker, scope: :jobseeker) }

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

  describe "GET #review" do
    before { sign_in(jobseeker, scope: :jobseeker) }

    context "when the application is not a draft" do
      let!(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

      it "redirects to the application page" do
        expect(get(jobseekers_job_application_review_path(job_application.id))).to redirect_to(jobseekers_job_application_path(job_application.id))
      end
    end

    context "when the application is a draft" do
      let!(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy) }

      it "shows the review page" do
        expect(get(jobseekers_job_application_review_path(job_application.id))).to render_template(:review)
      end
    end
  end

  describe "DELETE #destroy" do
    before { sign_in(jobseeker, scope: :jobseeker) }

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

  describe "GET #confirm_withdraw" do
    before { sign_in(jobseeker, scope: :jobseeker) }

    context "when the application is submitted" do
      let!(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

      it "shows a confirmation page" do
        expect(get(jobseekers_job_application_confirm_withdraw_path(job_application.id))).to render_template(:confirm_withdraw)
      end
    end

    context "when the application is not reviewed, submitted or shortlisted" do
      let!(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy) }

      it "raises an error" do
        expect { get(jobseekers_job_application_confirm_withdraw_path(job_application.id)) }
          .to raise_error(ActionController::RoutingError, %r{non-reviewed/shortlisted/submitted})
      end
    end
  end

  describe "POST #withdraw" do
    let(:withdraw_reason) { "other" }
    let(:origin) { "" }
    let(:params) do
      { jobseekers_job_application_withdraw_form: { withdraw_reason: withdraw_reason },
        origin: origin }
    end

    before { sign_in(jobseeker, scope: :jobseeker) }

    context "when the application is submitted" do
      let!(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }
      let(:button) { I18n.t("buttons.withdraw_application") }

      context "when the withdraw form is invalid" do
        let(:withdraw_reason) { "invalid" }

        it "does not withdraw the job application and redirects to the confirm withdraw template" do
          expect { post jobseekers_job_application_withdraw_path(job_application.id), params: params }
            .to(not_change { job_application.reload.status })

          expect(response).to render_template(:confirm_withdraw)
        end
      end

      context "when the withdraw form is valid" do
        it "withdraws the job application and redirects to the applications dashboard" do
          expect { post jobseekers_job_application_withdraw_path(job_application.id), params: params }
            .to change { job_application.reload.status }.from("submitted").to("withdrawn")
        end
      end
    end

    context "when the application is not reviewed, submitted or shortlisted" do
      let!(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy) }

      it "raises an error" do
        expect { post(jobseekers_job_application_withdraw_path(job_application.id)) }
          .to raise_error(ActionController::RoutingError, %r{non-reviewed/shortlisted/submitted})
      end
    end
  end
end
