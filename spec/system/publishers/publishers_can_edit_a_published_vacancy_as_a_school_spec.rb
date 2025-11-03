require "rails_helper"

RSpec.describe "Publishers can edit a vacancy" do
  let(:publisher) { create(:publisher) }
  let(:school) { create(:school) }

  before { login_publisher(publisher: publisher, organisation: school) }

  after { logout }

  context "when editing a published vacancy" do
    let(:vacancy) { create(:vacancy, organisations: [school]) }

    before do
      publisher_vacancy_page.load(vacancy_id: vacancy.id)
    end

    describe "#job_title" do
      before do
        publisher_vacancy_page.change_job_title_link.click
      end

      it "can not be edited when validation fails" do
        expect(publisher_job_title_page).to be_displayed

        fill_in "publishers_job_listing_job_title_form[job_title]", with: ""
        click_on I18n.t("buttons.save_and_continue")

        expect(publisher_job_title_page.errors.map(&:text)).to eq(["Enter a job title"])
      end

      it "notifies the Google index service" do
        expect(publisher_job_title_page).to be_displayed

        expect_any_instance_of(Publishers::Vacancies::BaseController)
          .to receive(:update_google_index).with(vacancy)

        fill_in "publishers_job_listing_job_title_form[job_title]", with: "Assistant Head Teacher"
        click_on I18n.t("buttons.save_and_continue")

        expect(publisher_vacancy_page).to be_displayed
        expect(page).to have_content("Assistant Head Teacher")

        visit job_path(vacancy.reload)
        # ensures the vacancy slug is updated when the title is saved
        expect(page.current_path).to eq("/jobs/assistant-head-teacher")
      end
    end

    describe "#pay_package" do
      before do
        publisher_vacancy_page.change_salary_link.click
      end

      it "can not be edited when validation fails" do
        expect(publisher_pay_package_page).to be_displayed

        fill_in "publishers_job_listing_pay_package_form[salary]", with: ""
        click_on I18n.t("buttons.save_and_continue")

        expect(publisher_pay_package_page.errors.map(&:text)).to eq([I18n.t("pay_package_errors.salary.blank")])
      end

      it "can be successfully edited and adds a job to update the Google index in the queue" do
        expect(publisher_pay_package_page).to be_displayed

        expect_any_instance_of(Publishers::Vacancies::BaseController)
          .to receive(:update_google_index).with(vacancy)

        fill_in "publishers_job_listing_pay_package_form[salary]", with: "Lotsa monies"
        click_on I18n.t("buttons.save_and_continue")

        expect(publisher_vacancy_page).to be_displayed
        expect(page).to have_content("Lotsa monies")
      end
    end

    describe "#important_dates" do
      def edit_date(date_type, date)
        fill_in "publishers_job_listing_important_dates_form[#{date_type}(3i)]", with: date&.day.presence || ""
        fill_in "publishers_job_listing_important_dates_form[#{date_type}(2i)]", with: date&.month.presence || ""
        fill_in "publishers_job_listing_important_dates_form[#{date_type}(1i)]", with: date&.year.presence || ""
        click_on I18n.t("buttons.save_and_continue")
      end

      describe "expires_at" do
        before do
          publisher_vacancy_page.change_expires_at_link.click
        end

        scenario "can not be edited when validation fails" do
          expect(publisher_important_dates_page).to be_displayed

          edit_date("expires_at", nil)

          expect(publisher_important_dates_page.errors.map(&:text)).to eq([I18n.t("important_dates_errors.expires_at.blank")])
        end

        scenario "can be successfully edited" do
          expect(publisher_important_dates_page).to be_displayed

          expiry_date = Date.current + 1.week
          edit_date("expires_at", expiry_date)

          expect(publisher_vacancy_page).to be_displayed
          expect(vacancy.reload.expires_at.to_date).to eq(expiry_date)
        end
      end

      describe "publish_on" do
        context "when the publication date is in the past" do
          let(:vacancy) { create(:vacancy, organisations: [school], slug: "test-slug", publish_on: 1.day.ago) }
          let(:expiry_time) { vacancy.expires_at + 1.year }

          before do
            publisher_vacancy_page.change_expires_at_link.click
          end

          it "renders the publication date as text and does not allow editing" do
            expect(publisher_important_dates_page).to be_displayed
            expect(publisher_important_dates_page).not_to have_change_publish_day_field
          end
        end

        context "when the publication date is in the future" do
          let(:vacancy) { create(:vacancy, :future_publish, organisations: [school]) }
          let(:publish_on) { Date.current + 1.week }

          before do
            publisher_vacancy_page.change_publish_on_link.click
          end

          it "renders the publication date as text and allows editing" do
            expect(publisher_important_dates_page).to be_displayed
            expect(publisher_important_dates_page).to have_change_publish_day_field

            edit_date("publish_on", publish_on)

            expect(publisher_vacancy_page).to be_displayed
            expect(vacancy.reload.publish_on).to eq(publish_on)
          end
        end
      end
    end

    describe "#application_form" do
      let(:vacancy) { create(:vacancy, :secondary, :with_application_form, organisations: [school], publisher: publisher, contact_email: publisher.email) }

      before do
        publisher_vacancy_page.change_application_form_link.click
      end

      scenario "replacing an application form" do
        expect(publisher_application_form_page).to be_displayed

        click_on I18n.t("jobs.upload_documents_table.actions.delete")

        expect(current_path).to eq(organisation_job_build_path(vacancy.id, :application_form))
        expect(page.has_field?("publishers_job_listing_application_form_form_application_form_staged_for_replacement", type: :hidden, with: "true")).to be true

        old_file_id = vacancy.application_form.id

        allow(Publishers::DocumentVirusCheck).to receive(:new).and_return(double(safe?: true))
        page.attach_file("publishers_job_listing_application_form_form[application_form]", Rails.root.join("spec/fixtures/files/blank_job_spec.pdf"))
        click_on I18n.t("buttons.save_and_continue")

        expect(vacancy.reload.application_form.id).not_to eq(old_file_id)
      end
    end

    describe "#documents" do
      let(:filename) { "blank_job_spec.pdf" }
      let(:vacancy) { create(:vacancy, :secondary, :with_supporting_documents, include_additional_documents: true, organisations: [school]) }

      scenario "can edit documents" do
        publisher_vacancy_page.change_supporting_documents_link.click

        expect(page).to have_content(I18n.t("publishers.vacancies.steps.documents"))

        choose I18n.t("helpers.label.publishers_job_listing_documents_confirmation_form.upload_additional_document_options.true")

        click_on I18n.t("buttons.save_and_continue")

        allow(Publishers::DocumentVirusCheck).to receive(:new).and_return(double(safe?: true))
        upload_file(
          "new_publishers_job_listing_documents_form",
          "publishers-job-listing-documents-form-supporting-documents-field",
          "spec/fixtures/files/#{filename}",
        )
        click_on I18n.t("buttons.save_and_continue")

        choose I18n.t("helpers.label.publishers_job_listing_documents_confirmation_form.upload_additional_document_options.false")

        click_on I18n.t("buttons.save_and_continue")

        expect(publisher_vacancy_page).to be_displayed
        expect(page).to have_content(filename)
      end
    end

    describe "#contact_details" do
      let(:contact_email) { publisher.email }

      before do
        click_review_page_change_link(section: "application_process", row: "contact_email")
      end

      it "can not be edited when validation fails" do
        expect(publisher_contact_details_page).to be_displayed
        choose I18n.t("helpers.label.publishers_job_listing_contact_details_form.contact_email_options.other")
        fill_in "publishers_job_listing_contact_details_form[other_contact_email]", with: ""
        click_on I18n.t("buttons.save_and_continue")

        expect(publisher_contact_details_page.errors.map(&:text)).to eq(["Enter an email address"])
      end

      it "can be successfully edited and adds a job to update the Google index in the queue" do
        expect(publisher_contact_details_page).to be_displayed

        choose I18n.t("helpers.label.publishers_job_listing_contact_details_form.contact_email_options.other")
        fill_in "publishers_job_listing_contact_details_form[other_contact_email]", with: "not_a_publisher_email@contoso.com"
        click_on I18n.t("buttons.save_and_continue")

        expect(publisher_confirm_contact_details_page).to be_displayed

        publisher_confirm_contact_details_page.click_change_email_button

        expect(publisher_contact_details_page).to be_displayed

        expect_any_instance_of(Publishers::Vacancies::BaseController).to receive(:update_google_index).with(vacancy)

        choose publisher.email
        click_on I18n.t("buttons.save_and_continue")

        expect(publisher_vacancy_page).to be_displayed
        expect(vacancy.reload.contact_email).to eq(contact_email)
      end
    end

    describe "#about_the_role" do
      before do
        click_review_page_change_link(section: "about_the_role", row: "skills_and_experience")
      end

      it "can not be edited when validation fails" do
        expect(publisher_about_the_role_page).to be_displayed
        fill_in "publishers_job_listing_about_the_role_form[skills_and_experience]", with: ""
        click_on I18n.t("buttons.save_and_continue")

        expect(publisher_about_the_role_page.errors.map(&:text)).to eq(["Enter the skills and experience you’re looking for"])
      end

      it "can be successfully edited, and adds a job to update the Google index in the queue" do
        expect(publisher_about_the_role_page).to be_displayed

        expect_any_instance_of(Publishers::Vacancies::BaseController)
          .to receive(:update_google_index).with(vacancy)

        fill_in "publishers_job_listing_about_the_role_form[skills_and_experience]", with: "A summary about the job."
        click_on I18n.t("buttons.save_and_continue")

        expect(publisher_vacancy_page).to be_displayed
        expect(page).to have_content("A summary about the job.")
      end
    end
  end

  context "when a vacancy is external" do
    let!(:vacancy) do
      create(
        :vacancy, :external, :expires_tomorrow,
        :secondary,
        job_title: "Imported vacancy",
        organisations: [school]
      )
    end

    it "is visible on the dashboard but cannot be edited" do
      visit organisation_jobs_with_type_path
      expect(page).to have_content("Imported vacancy")
      expect(page).not_to have_link("Imported vacancy")

      visit organisation_job_path(vacancy.id)
      expect(page).to have_content(I18n.t("error_pages.not_found"))
    end
  end
end
