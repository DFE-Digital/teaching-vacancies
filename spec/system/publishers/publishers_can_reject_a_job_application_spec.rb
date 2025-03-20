require "rails_helper"

RSpec.describe "Publishers can reject a job application" do
  include ActiveJob::TestHelper

  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :expired, organisations: [organisation]) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
  end

  after { logout }

  context "with a single job application" do
    let(:jobseeker) { create(:jobseeker, :with_profile) }
    let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy, jobseeker: jobseeker) }

    before do
      visit organisation_job_job_application_path(vacancy.id, job_application.id)
    end

    it "rejects the job application after confirmation", :js do
      click_on "Update application status"
      expect(page).to have_no_css("strong.govuk-tag.govuk-tag--red.application-status", text: "rejected")
      choose "Not considering"
      click_on "Save and continue"

      expect(page).to have_css("strong.govuk-tag.govuk-tag--red.application-status", text: "rejected")
      expect(current_path).to eq(organisation_job_job_applications_path(vacancy.id))
      expect(job_application.reload.status).to eq("unsuccessful")
    end
  end

  context "with mutiple rejected applications", :js do
    # let!(:joe) { create(:job_application, :status_unsuccessful, vacancy: vacancy) }
    # let!(:bill) { create(:job_application, :status_unsuccessful, vacancy: vacancy) }
    # let!(:jimbo) { create(:job_application, :status_unsuccessful, vacancy: vacancy) }
    let!(:email_template) { create(:email_template, publisher: publisher) }

    before do
      create_list(:job_application, 3, :status_unsuccessful, vacancy: vacancy)
      visit organisation_job_job_applications_path(vacancy.id)
    end

    it "handles the rejection email process" do
      select_tab "not_considering"
      click_on "Send rejection emails"
      expect(page).to have_content "You must select an application to reject"
      # annoyingly the govuk tabs component seems to not let you select an active tab
      select_tab "not_considering"
      first(".govuk-checkboxes__item").click
      click_on "Send rejection emails"

      click_on "Edit template"
      fill_in "From", with: ""
      click_on "Save template"
      expect(page).to have_content "Enter a from description"
      fill_in "From", with: Faker::Educator.secondary_school
      click_on "Save template"

      click_on "Create new template"
      fill_in "From", with: Faker::Educator.secondary_school
      fill_in "Subject", with: Faker::WorldCup.stadium
      click_on "Save template"
      expect(page).to have_content "Enter a template name"

      fill_in "Template name", with: Faker::Adjective.positive
      fill_in_trix_editor "email_template_content", with: Faker::Ancient.hero
      click_on "Save template"

      click_on email_template.name
      click_on "Send email to applicants"

      perform_enqueued_jobs
      expect(ActionMailer::Base.deliveries.map(&:to)).to match_array(vacancy.job_applications.map { |ja| [ja.email_address] })

      within("#rejected_emails") do
        within(".govuk-table__body") do
          expect(all("tr").count).to eq(3)
        end
      end
    end

    def select_tab(name)
      find_by_id("tab_#{name}").click
      # wait for tab to be selected
      find("a[tabindex='0'], #tab_#{name}")
    end
  end
end
