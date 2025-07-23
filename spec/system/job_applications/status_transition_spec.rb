require "rails_helper"

RSpec.describe "check job application after status transition" do
  let(:publisher) { create(:publisher, :with_organisation, accepted_terms_at: 1.day.ago) }
  let(:organisations) { publisher.organisations }
  let(:vacancy) { create(:vacancy, organisations:) }
  let(:jobseeker) { create(:jobseeker) }
  let(:job_application) { jobseeker.reload.job_applications.where(status:).first }
  let(:status) { "" }

  before do
    JobApplication.statuses.each_key do |status|
      create(:job_application, :"status_#{status}", jobseeker:)
    end

    if job_application.present?
      job_application.vacancy = vacancy
      job_application.save!
    end
  end

  describe "jobseeker job applications listing" do
    it "jobseeker can view all its applications", pending: "fix on interviewing display" do
      run_with_jobseeker(jobseeker) do
        jobseeker_applications_page.load

        jobseeker.job_applications.each do |ja|
          tag_text = JobApplicationsHelper::JOBSEEKER_STATUS_MAPPINGS[ja.status.to_sym]
          application = jobseeker_applications_page.job_application(ja.id)
          expect(application).to be_present, "missing job application status #{ja.status}"
          expect(application.tag).to have_text(tag_text)
        end
      end
    end
  end

  describe "transition: no job application to draft" do
    it "jobseeker can start a job application" do
      run_with_jobseeker(jobseeker) do
        #
        # jobseeker starts an application
        #
        jobseeker_application_start_page.load(vacancy_id: vacancy.id)
        jobseeker_application_start_page.btn_start_application.click
        jobseeker.reload

        #
        # jobseeker views all its applications
        #
        jobseeker_applications_page.load
        job_applications_count = jobseeker.job_applications.count
        expect(jobseeker_applications_page.header).to have_text("Applications (#{job_applications_count})")
      end
    end
  end

  describe "view state: draft", :js do
    let(:status) { "draft" }

    it "jobseeker can view draft while publisher cannot" do
      run_with_jobseeker(jobseeker) do
        jobseeker_applications_page.load

        #
        # view draft application        #
        jobseeker_applications_page.click_on_job_application(job_application.id)
        expect(jobseeker_application_apply_page).to be_displayed(id: job_application.id)
        expect(jobseeker_application_apply_page.tag).to have_text("draft")
      end

      run_with_publisher(publisher) do
        publisher_ats_applications_page.load(vacancy_id: vacancy.id)

        #
        # check tab all
        #
        publisher_ats_applications_page.select_tab(:tab_all)
        expect(publisher_ats_applications_page.tab_panel.job_applications.count).to eq(0)

        #
        # check tab new
        #
        publisher_ats_applications_page.select_tab(:tab_submitted)
        expect(publisher_ats_applications_page.tab_panel.job_applications.count).to eq(0)
      end
    end
  end

  describe "transition: submitted to reviewed", :js do
    let(:status) { "submitted" }

    it "jobseeker and publisher can view job application" do
      run_with_jobseeker(jobseeker) do
        #
        # jobseeker views all its applications
        #
        jobseeker_applications_page.load
        job_applications_count = jobseeker.reload.job_applications.count
        expect(jobseeker_applications_page.header).to have_text("Applications (#{job_applications_count})")
        #
        # view submitted application
        #
        jobseeker_applications_page.click_on_job_application(job_application.id)
        expect(jobseeker_application_page).to be_displayed(id: job_application.id)
        expect(jobseeker_application_page.tag).to have_text("submitted")
      end

      run_with_publisher(publisher) do
        publisher_ats_applications_page.load(vacancy_id: vacancy.id)

        #
        # check tab all
        #
        publisher_ats_applications_page.select_tab(:tab_all)
        expect(publisher_ats_applications_page.tab_panel.job_applications.count).to eq(1)

        #
        # check tab new
        #
        publisher_ats_applications_page.select_tab(:tab_submitted)
        expect(publisher_ats_applications_page.tab_panel.job_applications.count).to eq(1)

        display_status = publisher_ats_applications_page.tab_panel.job_applications.first.status
        expect(display_status).to have_text("unread")

        publisher_ats_applications_page.update_status(job_application) do |tag_page|
          tag_page.select_and_submit("reviewed")
        end

        display_status = publisher_ats_applications_page.tab_panel.job_applications.first.status
        expect(display_status).to have_text("reviewed")
      end

      run_with_jobseeker(jobseeker) do
        #
        # jobseeker views all its applications
        #
        jobseeker_applications_page.load
        job_applications_count = jobseeker.reload.job_applications.count
        expect(jobseeker_applications_page.header).to have_text("Applications (#{job_applications_count})")
        #
        # view submitted application
        #
        jobseeker_applications_page.click_on_job_application(job_application.id)
        expect(jobseeker_application_page).to be_displayed(id: job_application.id)
        expect(jobseeker_application_page.tag).to have_text("submitted") # TODO: should the jobseeker view reviewed instead of submitted here
        expect(job_application.reload.status).to eq("reviewed")
      end
    end
  end

  describe "transition: reviewed to unsuccessful", :js do
    let(:status) { "reviewed" }

    it "jobseeker and publisher can view job application" do
      run_with_jobseeker(jobseeker) do
        #
        # jobseeker views all its applications
        #
        jobseeker_applications_page.load
        job_applications_count = jobseeker.reload.job_applications.count
        expect(jobseeker_applications_page.header).to have_text("Applications (#{job_applications_count})")
        #
        # view submitted application
        #
        jobseeker_applications_page.click_on_job_application(job_application.id)
        expect(jobseeker_application_page).to be_displayed(id: job_application.id)
        expect(jobseeker_application_page.tag).to have_text("submitted")
      end

      run_with_publisher(publisher) do
        publisher_ats_applications_page.load(vacancy_id: vacancy.id)

        #
        # check tab all
        #
        publisher_ats_applications_page.select_tab(:tab_all)
        expect(publisher_ats_applications_page.tab_panel.job_applications.count).to eq(1)

        #
        # check tab new
        #
        publisher_ats_applications_page.select_tab(:tab_submitted)
        expect(publisher_ats_applications_page.tab_panel.job_applications.count).to eq(1)

        display_status = publisher_ats_applications_page.tab_panel.job_applications.first.status
        expect(display_status).to have_text("reviewed")

        publisher_ats_applications_page.update_status(job_application) do |tag_page|
          tag_page.select_and_submit("unsuccessful")
        end

        expect(publisher_ats_applications_page.tab_panel.job_applications).to be_empty

        #
        # display not considering tab
        #
        publisher_ats_applications_page.select_tab(:tab_not_considering)

        display_status = publisher_ats_applications_page.tab_panel.job_applications.first.status
        expect(display_status).to have_text("rejected")
      end

      run_with_jobseeker(jobseeker) do
        #
        # jobseeker views all its applications
        #
        jobseeker_applications_page.load
        job_applications_count = jobseeker.reload.job_applications.count
        expect(jobseeker_applications_page.header).to have_text("Applications (#{job_applications_count})")
        #
        # view submitted application
        #
        jobseeker_applications_page.click_on_job_application(job_application.id)
        expect(jobseeker_application_page).to be_displayed(id: job_application.id)
        expect(jobseeker_application_page.tag).to have_text("unsuccessful")
      end
    end
  end

  describe "transition: reviewed to shortlisted", :js do
    let(:status) { "reviewed" }

    it "jobseeker and publisher can view job application" do
      run_with_jobseeker(jobseeker) do
        #
        # jobseeker views all its applications
        #
        jobseeker_applications_page.load
        job_applications_count = jobseeker.reload.job_applications.count
        expect(jobseeker_applications_page.header).to have_text("Applications (#{job_applications_count})")
        #
        # view submitted application
        #
        jobseeker_applications_page.click_on_job_application(job_application.id)
        expect(jobseeker_application_page).to be_displayed(id: job_application.id)
        expect(jobseeker_application_page.tag).to have_text("submitted")
      end

      run_with_publisher(publisher) do
        publisher_ats_applications_page.load(vacancy_id: vacancy.id)

        #
        # check tab all
        #
        publisher_ats_applications_page.select_tab(:tab_all)
        expect(publisher_ats_applications_page.tab_panel.job_applications.count).to eq(1)

        #
        # check tab new
        #
        publisher_ats_applications_page.select_tab(:tab_submitted)
        expect(publisher_ats_applications_page.tab_panel.job_applications.count).to eq(1)

        display_status = publisher_ats_applications_page.tab_panel.job_applications.first.status
        expect(display_status).to have_text("reviewed")

        publisher_ats_applications_page.update_status(job_application) do |tag_page|
          tag_page.select_and_submit("shortlisted")
        end

        expect(publisher_ats_applications_page.tab_panel.job_applications).to be_empty

        #
        # display not considering tab
        #
        publisher_ats_applications_page.select_tab(:tab_shortlisted)

        display_status = publisher_ats_applications_page.tab_panel.job_applications.first.status
        expect(display_status).to have_text("shortlisted")
      end

      run_with_jobseeker(jobseeker) do
        #
        # jobseeker views all its applications
        #
        jobseeker_applications_page.load
        job_applications_count = jobseeker.reload.job_applications.count
        expect(jobseeker_applications_page.header).to have_text("Applications (#{job_applications_count})")
        #
        # view shortlisted application
        #
        jobseeker_applications_page.click_on_job_application(job_application.id)
        expect(jobseeker_application_page).to be_displayed(id: job_application.id)
        expect(jobseeker_application_page.tag).to have_text("shortlisted")
      end
    end
  end

  describe "transition: shortlisted to interviewing", :js do
    let(:status) { "shortlisted" }

    it "jobseeker and publisher can view job application" do
      run_with_jobseeker(jobseeker) do
        #
        # jobseeker views all its applications
        #
        jobseeker_applications_page.load
        job_applications_count = jobseeker.reload.job_applications.count
        expect(jobseeker_applications_page.header).to have_text("Applications (#{job_applications_count})")
        #
        # view submitted application
        #
        jobseeker_applications_page.click_on_job_application(job_application.id)
        expect(jobseeker_application_page).to be_displayed(id: job_application.id)
        expect(jobseeker_application_page.tag).to have_text("shortlisted")
      end

      run_with_publisher(publisher) do
        publisher_ats_applications_page.load(vacancy_id: vacancy.id)

        #
        # check tab all
        #
        publisher_ats_applications_page.select_tab(:tab_all)
        expect(publisher_ats_applications_page.tab_panel.job_applications.count).to eq(1)

        #
        # check tab new
        #
        publisher_ats_applications_page.select_tab(:tab_shortlisted)
        expect(publisher_ats_applications_page.tab_panel.job_applications.count).to eq(1)

        display_status = publisher_ats_applications_page.tab_panel.job_applications.first.status
        expect(display_status).to have_text("shortlisted")

        publisher_ats_applications_page.update_status(job_application) do |tag_page|
          tag_page.select_and_submit("interviewing")
        end

        expect(publisher_ats_applications_page.tab_panel.job_applications).to be_empty

        #
        # display interviewing tab
        #
        publisher_ats_applications_page.select_tab(:tab_interviewing)

        display_status = publisher_ats_applications_page.tab_panel.job_applications.first.status
        expect(display_status).to have_text("interviewing")

        #
        # view job application
        #
        publisher_ats_applications_page.tab_panel.job_applications.first.name.click
        expect(publisher_application_page).to be_displayed(vacancy_id: vacancy.id, job_application_id: job_application.id)
      end

      run_with_jobseeker(jobseeker) do
        #
        # jobseeker views all its applications
        #
        jobseeker_applications_page.load
        job_applications_count = jobseeker.reload.job_applications.count
        expect(jobseeker_applications_page.header).to have_text("Applications (#{job_applications_count})")
        #
        # view application
        #
        jobseeker_applications_page.click_on_job_application(job_application.id)
        expect(jobseeker_application_page).to be_displayed(id: job_application.id)
        expect(jobseeker_application_page.tag).to have_text("interviewing")
      end
    end
  end
end
