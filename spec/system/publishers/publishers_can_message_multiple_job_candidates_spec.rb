require "rails_helper"

RSpec.describe "Publishers can message multiple job candidates" do
  include ActiveJob::TestHelper

  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school, :with_image) }
  let(:vacancy) { create(:vacancy, :expired, organisations: [organisation]) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
  end

  after { logout }

  describe "bulk messaging" do
    let!(:message_template) { create(:message_template, publisher: publisher) }

    before do
      create_list(:job_application, 3, :status_shortlisted, vacancy: vacancy)
    end

    describe "message flow", :js do
      before do
        visit organisation_job_job_applications_path(vacancy.id)
        publisher_ats_applications_page.select_tab(:tab_shortlisted)
      end

      let(:batch_email) { JobApplicationBatch.order(:created_at).last }

      it "asks the user to pick at least one item" do
        click_on "Send a message"
        expect(page).to have_content "You must select at least one job application"
      end

      it "continues when items have been selected" do
        first(".govuk-checkboxes__item").click
        click_on "Send a message"
        #  wait for page to load
        find("span", text: "Send messages")

        expect(page).to have_current_path(select_template_organisation_job_bulk_message_path(vacancy.id, batch_email.id))
      end
    end

    describe "template flow" do
      let(:to_be_messaged) { JobApplication.first(2) }
      let(:batch_email) do
        create(:job_application_batch, vacancy: vacancy,
                                       batchable_job_applications: to_be_messaged.map { |ja| build(:batchable_job_application, job_application: ja) })
      end
      let(:content) { Faker::Ancient.hero }

      before do
        visit select_template_organisation_job_bulk_message_path(vacancy.id, batch_email.id)
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

      scenario "without using a template", :js, :perform_enqueued do
        click_on "Send message without template"
        fill_in_trix_editor "publisher_message_content", with: Faker::Fantasy::Tolkien.poem
        click_on "Send message"
        # message notifications are sent to jobseeker address not job_application address
        expect(ActionMailer::Base.deliveries.map(&:to)).to match_array(to_be_messaged.map { |ja| [ja.jobseeker.email] })
      end

      describe "sending messages", :js do
        before do
          click_on message_template.name
        end

        it "handles the messaging process", :perform_enqueued do
          click_on "Send message"

          #  wait for page to load
          find_by_id("tab_shortlisted")
          # message notifications are sent to jobseeker address not job_application address
          expect(ActionMailer::Base.deliveries.map(&:to)).to match_array(to_be_messaged.map { |ja| [ja.jobseeker.email] })
        end
      end
    end
  end
end
