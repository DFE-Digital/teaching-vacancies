require "rails_helper"
require "dfe/analytics/rspec/matchers"

RSpec.describe "Job applications" do
  let(:vacancy) { create(:vacancy, visa_sponsorship_available: visa_sponsorship, organisations: [build(:school)]) }
  let(:jobseeker) { create(:jobseeker) }
  let(:visa_sponsorship) { false }

  describe "GET #new" do
    before { create(:jobseeker_profile, jobseeker: jobseeker) }

    context "when the jobseeker is not signed in" do
      before { get(new_jobseekers_job_job_application_path(vacancy.id)) }

      it "redirects to the sign in page" do
        expect(response.location).to match(a_string_matching(new_jobseeker_session_path))
      end
    end
  end

  context "when signed in" do
    before { sign_in(jobseeker, scope: :jobseeker) }

    after { sign_out(jobseeker) }

    describe "POST #create" do
      let!(:jobseeker_profile) { create(:jobseeker_profile, jobseeker: jobseeker) }

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
          .to redirect_to(jobseekers_job_application_apply_path(jobseeker.job_applications.first))
      end

      context "when there are non-draft applications" do
        let(:old_vacancy) { create(:vacancy, organisations: [build(:school)]) }
        let!(:recent_job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: old_vacancy) }

        context "when the job is not listed" do
          let(:vacancy) { create(:vacancy, :expired, organisations: [build(:school)]) }

          it "returns not found" do
            post jobseekers_job_job_application_path(vacancy.id)

            expect(response).to have_http_status(:not_found)
          end
        end

        it "creates a job application and redirects to the review path" do
          expect { post(jobseekers_job_job_application_path(vacancy.id)) }
            .to change { jobseeker.job_applications.count }.by(1)

          expect(response)
            .to redirect_to(jobseekers_job_application_apply_path(jobseeker.job_applications.draft.first.id))
        end
      end
    end

    describe "GET #new" do
      context "when the job is live" do
        it "triggers a `vacancy_apply_clicked` event", :dfe_analytics do
          get new_jobseekers_job_job_application_path(vacancy.id)

          expect(:vacancy_apply_clicked).to have_been_enqueued_as_analytics_event(with_data: { vacancy_id: vacancy.id }) # rubocop:disable RSpec/ExpectActual
        end
      end

      context "when a job application for the job already exists" do
        let!(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy) }

        it "redirects to `jobseekers_job_applications_path`" do
          expect(get(new_jobseekers_job_job_application_path(vacancy.id)))
            .to redirect_to(jobseekers_job_applications_path)
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
            get new_jobseekers_job_job_application_path(vacancy.id)

            expect(response).to have_http_status(:not_found)
          end
        end

        it "renders the 'new' template" do
          get new_jobseekers_job_job_application_path(vacancy.id)

          expect(response).to render_template(:new)
        end
      end
    end

    describe "POST #submit" do
      let!(:job_application) { create(:job_application, create_details: true, jobseeker: jobseeker, vacancy: vacancy) }
      let(:button) { I18n.t("buttons.submit_application") }
      let(:confirm_data_accurate) { 1 }
      let(:confirm_data_usage) { 1 }
      let(:params) do
        {
          jobseekers_job_application_review_form:
            { confirm_data_accurate: confirm_data_accurate, confirm_data_usage: confirm_data_usage },
        }
      end

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
          let!(:jobseeker_profile) { create(:jobseeker_profile, jobseeker: jobseeker) }
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
          let!(:jobseeker_profile) { create(:jobseeker_profile, :with_trn, jobseeker: jobseeker) }

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
      let!(:jobseeker_profile) { create(:jobseeker_profile, jobseeker: jobseeker) }

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

    describe "GET #download" do
      let(:vacancy) { create(:vacancy, anonymise_applications: true) }
      let(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }
      let(:pdf_text) { PDF::Inspector::Text.analyze(response.body).strings }

      context "when the job application status is not draft or withdrawn" do
        it "sends a PDF file" do
          get jobseekers_job_application_download_path(job_application)

          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eq("application/pdf")
          expect(response.headers["Content-Disposition"]).to include("inline")
          expect(response.headers["Content-Disposition"]).to include("application_form.pdf")

          expect(pdf_text).to include(job_application.first_name)
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

    describe "GET #review" do
      let!(:jobseeker_profile) { create(:jobseeker_profile, jobseeker: jobseeker) }

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
      context "when the application is submitted" do
        let!(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

        it "shows a confirmation page" do
          expect(get(jobseekers_job_application_confirm_withdraw_path(job_application.id))).to render_template(:confirm_withdraw)
        end
      end

      context "when the application is shortlisted" do
        let!(:job_application) { create(:job_application, :status_shortlisted, jobseeker: jobseeker, vacancy: vacancy) }

        it "shows a confirmation page" do
          expect(get(jobseekers_job_application_confirm_withdraw_path(job_application.id))).to render_template(:confirm_withdraw)
        end
      end

      context "when the application is interviewing" do
        let!(:job_application) { create(:job_application, :status_interviewing, jobseeker: jobseeker, vacancy: vacancy) }

        it "shows a confirmation page" do
          expect(get(jobseekers_job_application_confirm_withdraw_path(job_application.id))).to render_template(:confirm_withdraw)
        end
      end

      context "when the application is offered" do
        let!(:job_application) { create(:job_application, :status_offered, jobseeker: jobseeker, vacancy: vacancy) }

        it "shows a confirmation page" do
          expect(get(jobseekers_job_application_confirm_withdraw_path(job_application.id))).to render_template(:confirm_withdraw)
        end
      end

      context "when the application is not in a withdrawable state" do
        let!(:job_application) { create(:job_application, :status_declined, jobseeker: jobseeker, vacancy: vacancy) }

        it "raises an error" do
          expect { get(jobseekers_job_application_confirm_withdraw_path(job_application.id)) }
            .to raise_error(ActionController::RoutingError, "Cannot withdraw application in this state")
        end
      end
    end

    describe "GET #about_your_application" do
      before do
        create(:job_application, :status_submitted, jobseeker: jobseeker)
      end

      context "without a profile" do
        it "renders 'new'" do
          expect(get(new_jobseekers_job_job_application_path(vacancy.id)))
            .to  render_template(:new)
        end
      end

      context "with an empty profile" do
        before do
          create(:jobseeker_profile, jobseeker: jobseeker)
        end

        it "renders 'new'" do
          expect(get(new_jobseekers_job_job_application_path(vacancy.id)))
            .to  render_template(:new)
        end
      end

      context "with a non-visa-seeking profile" do
        before do
          create(:jobseeker_profile, jobseeker: jobseeker, personal_details: build(:personal_details, has_right_to_work_in_uk: true))
        end

        it "renders 'new'" do
          expect(get(new_jobseekers_job_job_application_path(vacancy.id)))
            .to  render_template(:new)
        end
      end

      context "with a visa-seeking profile but vacancy is sponsored" do
        before do
          create(:jobseeker_profile, jobseeker: jobseeker, personal_details: build(:personal_details, has_right_to_work_in_uk: false))
        end

        let(:visa_sponsorship) { true }

        it "renders 'new'" do
          expect(get(new_jobseekers_job_job_application_path(vacancy.id)))
            .to  render_template(:new)
        end
      end

      context "with a visa-seeking profile" do
        before do
          create(:jobseeker_profile, jobseeker: jobseeker, personal_details: build(:personal_details, has_right_to_work_in_uk: false))
        end

        let(:visa_sponsorship) { false }

        it "shows the page" do
          expect(get(new_jobseekers_job_job_application_path(vacancy.id)))
            .to render_template(:about_your_application)
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

      context "when the application is interviewing" do
        let!(:job_application) { create(:job_application, :status_interviewing, jobseeker: jobseeker, vacancy: vacancy) }

        context "when the withdraw form is valid" do
          it "withdraws the job application and redirects to the applications dashboard" do
            expect { post jobseekers_job_application_withdraw_path(job_application.id), params: params }
              .to change { job_application.reload.status }.from("interviewing").to("withdrawn")

            expect(response).to redirect_to(jobseekers_job_applications_path)
            expect(flash[:success]).to include(vacancy.job_title)
          end
        end
      end

      context "when the application is offered" do
        let!(:job_application) { create(:job_application, :status_offered, jobseeker: jobseeker, vacancy: vacancy) }

        context "when the withdraw form is valid" do
          it "withdraws the job application and redirects to the applications dashboard" do
            expect { post jobseekers_job_application_withdraw_path(job_application.id), params: params }
              .to change { job_application.reload.status }.from("offered").to("withdrawn")

            expect(response).to redirect_to(jobseekers_job_applications_path)
          end
        end
      end

      context "when the application is not in a withdrawable state" do
        let!(:job_application) { create(:job_application, :status_declined, jobseeker: jobseeker, vacancy: vacancy) }

        it "raises an error" do
          expect { post(jobseekers_job_application_withdraw_path(job_application.id)) }
            .to raise_error(ActionController::RoutingError, "Cannot withdraw application in this state")
        end
      end
    end
  end
end
