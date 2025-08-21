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

  describe "job applications listing" do
    it "jobseeker can view all its applications" do
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
        expect { jobseeker_application_start_page.btn_start_application.click }.to change { jobseeker.job_applications.draft.count }.by(1)
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
        # view draft application
        jobseeker_applications_page.click_on_job_application(job_application.id)
        expect(jobseeker_application_apply_page).to be_displayed(id: job_application.id)
        expect(jobseeker_application_apply_page.tag).to have_text("draft")
      end

      run_with_publisher(publisher) do
        publisher_ats_applications_page.load(vacancy_id: vacancy.id)

        #
        # check tab new
        #
        publisher_ats_applications_page.select_tab(:tab_submitted)
        expect(publisher_ats_applications_page.tab_panel.job_applications.count).to eq(0)
      end
    end
  end

  describe "transition: submitted to unsuccessful", :js do
    let(:status) { "submitted" }

    it "allows the publisher to reject a submitted job application and the jobseeker to see it as unsuccessful afterwards" do
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
        # check tab new
        #
        publisher_ats_applications_page.select_tab(:tab_submitted)
        expect(publisher_ats_applications_page.tab_panel.job_applications.count).to eq(1)

        display_status = publisher_ats_applications_page.tab_panel.job_applications.first.status
        expect(display_status).to have_text("unread")

        publisher_ats_applications_page.update_status(job_application) do |tag_page|
          tag_page.select_and_submit("unsuccessful")
        end

        expect(publisher_ats_applications_page.tab_panel.job_applications).to be_empty

        #
        # display not considering tab
        #
        publisher_ats_applications_page.select_tab(:tab_unsuccessful)

        display_status = publisher_ats_applications_page.tab_panel.job_applications.first.status
        expect(display_status).to have_text("not progressing")
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

  describe "transition: submitted to shortlisted", :js do
    let(:status) { "submitted" }

    it "allows the publisher to shortlist a submitted job application and the jobseeker to see it as shortlisted afterwards" do
      run_with_publisher(publisher) do
        publisher_ats_applications_page.load(vacancy_id: vacancy.id)

        #
        # check tab new
        #
        publisher_ats_applications_page.select_tab(:tab_submitted)
        expect(publisher_ats_applications_page.tab_panel.job_applications.count).to eq(1)

        display_status = publisher_ats_applications_page.tab_panel.job_applications.first.status
        expect(display_status).to have_text("unread")

        publisher_ats_applications_page.update_status(job_application) do |tag_page|
          tag_page.select_and_submit("shortlisted")
        end

        expect(publisher_ats_applications_page.tab_panel.job_applications).to be_empty

        #
        # display shortlisted tab
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

    it "allows the publisher to set a shortlisted job application as interviewing and the jobseeker to see it as interviewing afterwards" do
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
        # check shortlisted tab
        #
        publisher_ats_applications_page.select_tab(:tab_shortlisted)
        expect(publisher_ats_applications_page.tab_panel.job_applications.count).to eq(1)

        display_status = publisher_ats_applications_page.tab_panel.job_applications.first.status
        expect(display_status).to have_text("shortlisted")

        publisher_ats_applications_page.update_status(job_application) do |tag_page|
          tag_page.select_and_submit("interviewing")
        end

        #
        # without ATS references and self-disclosure collection through TV service
        #
        expect(publisher_ats_collect_references_page).to be_displayed(vacancy_id: vacancy.id)
        publisher_ats_collect_references_page.answer_no
        find("label[for='publishers-job-application-collect-self-disclosure-form-collect-self-disclosure-false-field']").click
        click_on "Save and continue"
        #
        # display interviewing tab
        #
        expect(publisher_ats_applications_page).to be_displayed
        expect(publisher_ats_applications_page.selected_tab).to have_text("Interviewing")
        display_status = publisher_ats_applications_page.tab_panel.job_applications.first.status
        expect(display_status).to have_text("interviewing")

        #
        # view job application
        #
        publisher_ats_applications_page.tab_panel.job_applications.first.name_link.click
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

  describe "transition: interviewing to offered", :js do
    let(:status) { "interviewing" }

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
        expect(jobseeker_application_page.tag).to have_text("interviewing")
      end

      run_with_publisher(publisher) do
        publisher_ats_applications_page.load(vacancy_id: vacancy.id)

        #
        # check interviewing tab
        #
        publisher_ats_applications_page.select_tab(:tab_interviewing)
        expect(publisher_ats_applications_page.tab_panel.job_applications.count).to eq(1)

        display_status = publisher_ats_applications_page.tab_panel.job_applications.first.status
        expect(display_status).to have_text("interviewing")

        publisher_ats_applications_page.update_status(job_application) do |tag_page|
          tag_page.select_and_submit("offered", &:one_day_ago)
        end

        publisher_ats_applications_page.select_tab(:tab_interviewing)
        expect(publisher_ats_applications_page.tab_panel.job_applications).to be_empty

        #
        # display offered tab
        #
        publisher_ats_applications_page.select_tab(:tab_offered)

        display_status = publisher_ats_applications_page.tab_panel.job_applications.first.status
        expect(display_status).to have_text("offered")

        #
        # view job application
        #
        publisher_ats_applications_page.tab_panel.job_applications.first.name_link.click
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
        expect(jobseeker_application_page.tag).to have_text("offered")
      end
    end
  end

  describe "transition: interviewing to unsuccessful_interview", :js do
    let(:status) { "interviewing" }

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
        expect(jobseeker_application_page.tag).to have_text("interviewing")
      end

      run_with_publisher(publisher) do
        publisher_ats_applications_page.load(vacancy_id: vacancy.id)

        #
        # check interviewing tab
        #
        publisher_ats_applications_page.select_tab(:tab_interviewing)
        expect(publisher_ats_applications_page.tab_panel.job_applications.count).to eq(1)

        display_status = publisher_ats_applications_page.tab_panel.job_applications.first.status
        expect(display_status).to have_text("interviewing")

        publisher_ats_applications_page.update_status(job_application) do |tag_page|
          tag_page.select_and_submit("unsuccessful_interview", &:today)
        end

        publisher_ats_applications_page.select_tab(:tab_interviewing)

        candidate_name = jobseeker.job_applications.unsuccessful_interview.where.not(interview_feedback_received_at: nil).first.name
        expect(publisher_ats_applications_page.tab_panel.job_applications.first.name).to have_text(candidate_name)
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
        expect(jobseeker_application_page.tag).to have_text("unsuccessful")
      end
    end
  end

  describe "transition: offered to declined", :js do
    let(:status) { "offered" }

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
        expect(jobseeker_application_page.tag).to have_text("offered")
      end

      run_with_publisher(publisher) do
        publisher_ats_applications_page.load(vacancy_id: vacancy.id)

        #
        # check tab new
        #
        publisher_ats_applications_page.select_tab(:tab_offered)
        expect(publisher_ats_applications_page.tab_panel.job_applications.count).to eq(1)

        display_status = publisher_ats_applications_page.tab_panel.job_applications.first.status
        expect(display_status).to have_text("job offered")

        publisher_ats_applications_page.decline_offer(job_application, &:today)

        publisher_ats_applications_page.select_tab(:tab_offered)
        expect(publisher_ats_applications_page.tab_panel.declined_job_applications.count).to eq(1)
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
        expect(jobseeker_application_page.tag).to have_text("declined")
      end
    end
  end
end
