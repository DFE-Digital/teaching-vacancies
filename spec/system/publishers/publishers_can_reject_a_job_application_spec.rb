require "rails_helper"

RSpec.describe "Publishers can reject a job application" do
  include ActiveJob::TestHelper

  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school, :with_image) }
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

    it "rejects the job application after confirmation" do
      click_on "Update application status"
      expect(page).to have_no_css("strong.govuk-tag.govuk-tag--red.application-status", text: "rejected")
      choose "Not progressing"
      click_on "Save and continue"

      expect(page).to have_current_path(organisation_job_job_applications_path(vacancy.id), ignore_query: true)
      expect(job_application.reload.status).to eq("unsuccessful")
      # default all tab no longer present, so this won't show unless we redirect to not_considering tab
      # expect(page).to have_css("strong.govuk-tag.govuk-tag--red.application-status", text: "rejected")
    end
  end

  describe "rejecting applications" do
    let(:from) { Faker::Educator.secondary_school }
    let!(:email_template) { create(:email_template, publisher: publisher) }

    before do
      create_list(:job_application, 3, :status_unsuccessful, vacancy: vacancy)
    end

    describe "whole rejection flow", :js do
      before do
        visit organisation_job_job_applications_path(vacancy.id)
        publisher_ats_applications_page.select_tab(:tab_unsuccessful)
      end

      let(:batch_email) { JobApplicationBatch.order(:created_at).last }

      it "asks the user to pick at least one item" do
        click_on "Send rejection emails"
        expect(page).to have_content "You must select at least one job application"
      end

      it "continues when items have been selected" do
        first(".govuk-checkboxes__item").click
        click_on "Send rejection emails"
        #  wait for page to load
        find("span", text: "Send rejection emails")

        expect(page).to have_current_path(select_rejection_template_organisation_job_batch_email_path(vacancy.id, batch_email.id))
      end
    end

    describe "template flow" do
      let(:rejected) { JobApplication.first(2) }
      let(:batch_email) do
        create(:job_application_batch, vacancy: vacancy,
                                       batchable_job_applications: rejected.map { |ja| build(:batchable_job_application, job_application: ja) })
      end

      before do
        visit select_rejection_template_organisation_job_batch_email_path(vacancy.id, batch_email.id)
      end

      scenario "updating template" do
        click_on "Edit template"
        fill_in "From", with: ""
        click_on "Save template"
        expect(page).to have_content "Enter a from description"
        fill_in "From", with: from
        click_on "Save template"
        # wait for page to load
        find ".trix-content"
        expect(email_template.reload.from).to eq(from)
      end

      scenario "creating a new template" do
        click_on "Create new template"
        fill_in "From", with: Faker::Educator.secondary_school
        fill_in "Subject", with: Faker::WorldCup.stadium
        click_on "Save template"
        expect(page).to have_content "Enter a template name"

        fill_in "Template name", with: Faker::Adjective.positive
        fill_in_trix_editor "email_template_content", with: Faker::Ancient.hero
        click_on "Save template"
      end

      scenario "deleting a template" do
        find(".govuk-link", text: "Delete template").click
        expect(EmailTemplate.count).to eq(0)
      end

      describe "rejecting applications", :js do
        before do
          click_on email_template.name
        end

        it "handles the rejection email process", :perform_enqueued do
          click_on "Send email to applicants"

          #  wait for page to load
          find_by_id("tab_unsuccessful")
          expect(ActionMailer::Base.deliveries.map(&:to)).to match_array(rejected.map { |ja| [ja.email_address] })

          # check that the rejected applications have moved from the top row to the table below
          expect(all("tr.govuk-table__row.application-unsuccessful").size).to eq(1)

          within("#rejected_emails") do
            within(".govuk-table__body") do
              expect(all("tr").count).to eq(2)
            end
          end
        end

        scenario "copying email to originator", :perform_enqueued do
          check "Email a copy to #{publisher.email}"
          click_on "Send email to applicants"

          #  wait for page to load
          find_by_id("tab_unsuccessful")

          expect(ActionMailer::Base.deliveries.map(&:bcc).uniq).to eq([[publisher.email]])
        end

        scenario "adding a logo" do
          check "Include school or trust logo in email"
          click_on "Send email to applicants"

          expect {
            perform_enqueued_jobs
          }.to change { ActionMailer::Base.deliveries.count }.by(2)
        end
      end
    end
  end
end
