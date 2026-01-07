require "rails_helper"

RSpec.describe "Jobseekers can submit a job application" do
  include ActiveJob::TestHelper

  let(:jobseeker) { create(:jobseeker, jobseeker_profile: jobseeker_profile) }
  let(:jobseeker_profile) { create(:jobseeker_profile, :with_trn) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, organisations: [organisation]) }

  before do
    login_as(jobseeker, scope: :jobseeker)
  end

  after { logout }

  context "when it is native job application" do
    before do
      visit jobseekers_job_application_review_path(job_application)
    end

    context "when the application is complete" do
      let(:job_application) { create(:job_application, create_details: true, jobseeker:, vacancy:) }

      it "allows jobseekers to submit application and receive confirmation email" do
        click_on I18n.t("buttons.submit_application")
        expect(page).to have_content("There is a problem")

        check I18n.t("helpers.label.jobseekers_job_application_review_form.confirm_data_accurate_options.1")
        check I18n.t("helpers.label.jobseekers_job_application_review_form.confirm_data_usage_options.1")

        expect { perform_enqueued_jobs { click_on I18n.t("buttons.submit_application") } }
          .to change { JobApplication.first.status }.from("draft").to("submitted")
          .and change { delivered_emails.count }.by(1)

        expect(page).to have_content(I18n.t("jobseekers.job_applications.post_submit.panel.title"))

        visit ActionMailer::Base.deliveries.last.personalisation.fetch(:job_application_link)
        expect(current_path).to eq(jobseekers_job_applications_path)
      end
    end

    context "when the application is incomplete" do
      let(:job_application) { create(:job_application, :status_draft, jobseeker:, vacancy:) }

      it "does not allow jobseekers to submit application" do
        check I18n.t("helpers.label.jobseekers_job_application_review_form.confirm_data_accurate_options.1")
        check I18n.t("helpers.label.jobseekers_job_application_review_form.confirm_data_usage_options.1")

        click_on I18n.t("buttons.submit_application")

        expect(JobApplication.first.status).to eq("draft")
        expect(page).to have_content("There is a problem")
      end

      it "allows jobseekers to cancel and go to my applications tab" do
        click_on I18n.t("buttons.cancel_and_return_to_account")

        expect(JobApplication.first.status).to eq("draft")
        expect(current_path).to eq(jobseekers_job_applications_path)
      end
    end

    context "when the application is complete but invalid" do
      let(:job_application) { create(:job_application, jobseeker:, vacancy:, is_statutory_induction_complete: nil) }

      it "does not allow jobseekers to submit application, and informs jobseeker of invalid value" do
        check I18n.t("helpers.label.jobseekers_job_application_review_form.confirm_data_accurate_options.1")
        check I18n.t("helpers.label.jobseekers_job_application_review_form.confirm_data_usage_options.1")

        click_on I18n.t("buttons.submit_application")

        expect(JobApplication.first.status).to eq("draft")
        expect(page).not_to have_content("There is a problem")
        expect(page).to have_content(I18n.t("messages.jobs.action_required.message.jobseeker"))
        expect(page).to have_link(I18n.t("activemodel.errors.models.jobseekers/job_application/professional_status_form.attributes.is_statutory_induction_complete.inclusion"),
                                  href: "#is_statutory_induction_complete")
      end
    end
  end

  context "when it is uploaded job application" do
    let(:vacancy) { create(:vacancy, :with_uploaded_application_form, job_roles: %w[it_support], organisations: [organisation]) }
    let(:uploaded_job_application) { create(:uploaded_job_application, :with_uploaded_application_form, jobseeker: jobseeker, vacancy: vacancy, completed_steps: %w[personal_details upload_application_form]) }

    before do
      visit jobseekers_job_application_review_path(uploaded_job_application)
    end

    context "when the application is complete" do
      it "allows jobseekers to submit application and receive confirmation email" do
        click_on I18n.t("buttons.submit_application")
        expect(page).to have_content("There is a problem")

        check I18n.t("helpers.label.jobseekers_job_application_review_form.confirm_data_accurate_options.1")
        check I18n.t("helpers.label.jobseekers_job_application_review_form.confirm_data_usage_options.1")

        expect { perform_enqueued_jobs { click_on I18n.t("buttons.submit_application") } }
          .to change { JobApplication.first.status }.from("draft").to("submitted")
          .and change { delivered_emails.count }.by(1)

        expect(page).to have_content(I18n.t("jobseekers.job_applications.post_submit.panel.title"))

        visit ActionMailer::Base.deliveries.last.personalisation.fetch(:job_application_link)
        expect(current_path).to eq(jobseekers_job_applications_path)
      end
    end

    context "when the application is incomplete" do
      let(:uploaded_job_application) { create(:uploaded_job_application, :status_draft, jobseeker:, vacancy:) }

      it "does not allow jobseekers to submit application" do
        check I18n.t("helpers.label.jobseekers_job_application_review_form.confirm_data_accurate_options.1")
        check I18n.t("helpers.label.jobseekers_job_application_review_form.confirm_data_usage_options.1")

        click_on I18n.t("buttons.submit_application")

        expect(JobApplication.first.status).to eq("draft")
        within(".govuk-error-summary__body") do
          expect(page).to have_link("Complete your personal details")
        end
      end

      it "allows jobseekers to cancel and go to my applications tab" do
        click_on I18n.t("buttons.cancel_and_return_to_account")

        expect(JobApplication.first.status).to eq("draft")
        expect(current_path).to eq(jobseekers_job_applications_path)
      end
    end

    context "when the application is complete but invalid" do
      let(:uploaded_job_application) { create(:uploaded_job_application, :status_draft, jobseeker:, vacancy:, completed_steps: %w[personal_details upload_application_form], first_name: nil) }

      it "does not allow jobseekers to submit application, and informs jobseeker of invalid value" do
        check I18n.t("helpers.label.jobseekers_job_application_review_form.confirm_data_accurate_options.1")
        check I18n.t("helpers.label.jobseekers_job_application_review_form.confirm_data_usage_options.1")

        click_on I18n.t("buttons.submit_application")

        expect(JobApplication.first.status).to eq("draft")
        expect(page).not_to have_content("There is a problem")
        within(".govuk-error-summary__body") do
          expect(page).to have_link("Enter your first name")
        end
      end
    end
  end
end
