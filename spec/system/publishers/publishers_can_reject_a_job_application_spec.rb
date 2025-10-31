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

  describe "rejecting applications" do
    let!(:message_template) { create(:message_template, publisher: publisher) }

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
        click_on "Send rejection messages"
        expect(page).to have_content "You must select at least one job application"
      end

      it "continues when items have been selected" do
        first(".govuk-checkboxes__item").click
        click_on "Send rejection messages"
        #  wait for page to load
        find("span", text: "Send rejection messages")

        expect(page).to have_current_path(select_rejection_template_organisation_job_bulk_rejection_message_path(vacancy.id, batch_email.id))
      end
    end

    describe "template flow" do
      let(:rejected) { JobApplication.first(2) }
      let(:batch_email) do
        create(:job_application_batch, vacancy: vacancy,
                                       batchable_job_applications: rejected.map { |ja| build(:batchable_job_application, job_application: ja) })
      end
      let(:content) { Faker::Ancient.hero }

      before do
        visit select_rejection_template_organisation_job_bulk_rejection_message_path(vacancy.id, batch_email.id)
        # wait for page load
        find("form[action='/organisation/message_templates/new']")
      end

      scenario "updating template", :js do
        click_on "Edit template"
        fill_in_trix_editor "message_template_content", with: " "
        click_on "Save template"
        expect(page).to have_content "Enter some content"
        fill_in_trix_editor "message_template_content", with: content
        click_on "Save template"
        # wait for page to load
        find ".trix-content"
        expect(message_template.reload.content.body.to_s).to include(content)
      end

      scenario "creating a new template", :js do
        click_on "Create new template"
        click_on "Save template"
        expect(page).to have_content "Enter a template name"

        expect {
          fill_in "Template name", with: Faker::Adjective.positive
          fill_in_trix_editor "message_template_content", with: content
          click_on "Save template"
        }.to change(MessageTemplate, :count).by(1)
      end

      scenario "deleting a template" do
        find(".govuk-link", text: "Delete template").click
        expect(MessageTemplate.count).to eq(0)
      end

      scenario "without using a template", :js do
        click_on "Send message without template"
        fill_in_trix_editor "publisher_message_content", with: Faker::Fantasy::Tolkien.poem
        click_on "Send message"
        # check that the rejected applications have moved from the top row to the table below
        expect(all("tr.govuk-table__row.application-unsuccessful").size).to eq(1)
      end

      describe "rejecting applications", :js do
        before do
          click_on message_template.name
        end

        it "handles the rejection email process", :perform_enqueued do
          click_on "Send message"

          #  wait for page to load
          find_by_id("tab_unsuccessful")
          # message notifications are sent to jobseeker address not job_application address
          expect(ActionMailer::Base.deliveries.map(&:to)).to match_array(rejected.map { |ja| [ja.jobseeker.email] })

          # check that the rejected applications have moved from the top row to the table below
          expect(all("tr.govuk-table__row.application-unsuccessful").size).to eq(1)

          within("#rejected_emails") do
            within(".govuk-table__body") do
              expect(all("tr").count).to eq(2)
            end
          end
        end
      end
    end
  end
end
