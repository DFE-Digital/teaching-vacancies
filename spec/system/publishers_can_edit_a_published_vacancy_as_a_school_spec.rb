require "rails_helper"
RSpec.describe "Publishers can edit a vacancy" do
  let(:publisher) { create(:publisher) }
  let(:school) { create(:school) }

  before { login_publisher(publisher: publisher, organisation: school) }

  context "when editing a published vacancy" do
    let(:vacancy) do
      VacancyPresenter.new(
        create(:vacancy, organisations: [school],
                         job_location: "at_one_school",
                         job_roles: %i[teacher send_responsible], working_patterns: %w[full_time part_time],
                         publish_on: Date.current, expires_at: 1.day.from_now.change(hour: 9, minute: 0)),
      )
    end

    scenario "shows all vacancy information" do
      visit organisation_job_path(vacancy.id)

      verify_all_vacancy_details(vacancy)
    end

    scenario "takes you to the show page" do
      visit organisation_job_path(vacancy.id)

      within("h1.govuk-heading-l") do
        expect(page).to have_content(I18n.t("buttons.manage_listing"))
      end
    end

    scenario "create a job sidebar is not present" do
      visit organisation_job_path(vacancy.id)

      expect(page).to_not have_content("Creating a job listing steps")
    end

    scenario "publish buttons are not present" do
      visit organisation_job_path(vacancy.id)

      expect(page).to_not have_content("Confirm and submit job")
    end

    describe "#job_details" do
      scenario "can not be edited when validation fails" do
        visit organisation_job_path(vacancy.id)

        within("h1.govuk-heading-l") do
          expect(page).to have_content(I18n.t("buttons.manage_listing"))
        end
        click_header_link(I18n.t("publishers.vacancies.steps.job_details"))

        fill_in "publishers_job_listing_job_details_form[job_title]", with: ""
        click_on I18n.t("buttons.update_job")

        expect(page).to have_content("Enter a job title")
      end

      scenario "can be successfully edited" do
        visit organisation_job_path(vacancy.id)
        click_header_link(I18n.t("publishers.vacancies.steps.job_details"))

        fill_in "publishers_job_listing_job_details_form[job_title]", with: "Assistant Head Teacher"
        click_on I18n.t("buttons.update_job")

        expect(current_path).to eq(organisation_job_path(vacancy.id))
        expect(page).to have_content("Assistant Head Teacher")
      end

      scenario "ensures the vacancy slug is updated when the title is saved" do
        vacancy = create(:vacancy, :published, slug: "the-vacancy-slug", organisations: [school])
        visit organisation_job_path(vacancy.id)
        click_header_link(I18n.t("publishers.vacancies.steps.job_details"))

        fill_in "publishers_job_listing_job_details_form[job_title]", with: "Assistant Head Teacher"
        click_on I18n.t("buttons.update_job")

        expect(current_path).to eq(organisation_job_path(vacancy.id))
        expect(page).to have_content("Assistant Head Teacher")

        visit job_path(vacancy.reload)
        expect(page.current_path).to eq("/jobs/assistant-head-teacher")
      end

      scenario "notifies the Google index service" do
        expect_any_instance_of(Publishers::Vacancies::BaseController)
          .to receive(:update_google_index).with(vacancy)

        visit organisation_job_path(vacancy.id)
        click_header_link(I18n.t("publishers.vacancies.steps.job_details"))

        fill_in "publishers_job_listing_job_details_form[job_title]", with: "Assistant Head Teacher"
        click_on I18n.t("buttons.update_job")
      end
    end

    describe "#pay_package" do
      scenario "can not be edited when validation fails" do
        visit organisation_job_path(vacancy.id)

        within("h1.govuk-heading-l") do
          expect(page).to have_content(I18n.t("buttons.manage_listing"))
        end

        click_header_link(I18n.t("publishers.vacancies.steps.pay_package"))

        fill_in "publishers_job_listing_pay_package_form[salary]", with: ""
        click_on I18n.t("buttons.update_job")

        within_row_for(text: I18n.t("helpers.label.publishers_job_listing_pay_package_form.salary")) do
          expect(page).to have_content(I18n.t("pay_package_errors.salary.blank"))
        end
      end

      scenario "can be successfully edited" do
        visit organisation_job_path(vacancy.id)
        click_header_link(I18n.t("publishers.vacancies.steps.pay_package"))

        fill_in "publishers_job_listing_pay_package_form[salary]", with: "Pay scale 1 to Pay scale 2"
        click_on I18n.t("buttons.update_job")

        expect(current_path).to eq(organisation_job_path(vacancy.id))
        expect(page).to have_content("Pay scale 1 to Pay scale 2")
      end

      scenario "adds a job to update the Google index in the queue" do
        expect_any_instance_of(Publishers::Vacancies::BaseController)
          .to receive(:update_google_index).with(vacancy)

        visit organisation_job_path(vacancy.id)
        click_header_link(I18n.t("publishers.vacancies.steps.pay_package"))

        fill_in "publishers_job_listing_pay_package_form[salary]", with: "Pay scale 1 to Pay scale 2"
        click_on I18n.t("buttons.update_job")
      end
    end

    describe "#important_dates" do
      def edit_date(date_type, date)
        fill_in "publishers_job_listing_important_dates_form[#{date_type}(3i)]", with: date&.day.presence || ""
        fill_in "publishers_job_listing_important_dates_form[#{date_type}(2i)]", with: date&.month.presence || ""
        fill_in "publishers_job_listing_important_dates_form[#{date_type}(1i)]", with: date&.year.presence || ""
        click_on I18n.t("buttons.update_job")
      end

      scenario "can not be edited when validation fails" do
        visit organisation_job_path(vacancy.id)

        within("h1.govuk-heading-l") do
          expect(page).to have_content(I18n.t("buttons.manage_listing"))
        end
        click_header_link(I18n.t("publishers.vacancies.steps.important_dates"))

        edit_date("expires_at", nil)

        within_row_for(element: "legend",
                       text: strip_tags(I18n.t("helpers.legend.publishers_job_listing_important_dates_form.expires_at"))) do
          expect(page).to have_content(I18n.t("important_dates_errors.expires_at.blank"))
        end
      end

      scenario "can be successfully edited" do
        visit organisation_job_path(vacancy.id)
        click_header_link(I18n.t("publishers.vacancies.steps.important_dates"))

        expiry_date = Date.current + 1.week
        edit_date("expires_at", expiry_date)

        expect(current_path).to eq(organisation_job_path(vacancy.id))
        # Using String#strip to get rid of an initial space in e.g. " 1 July 2020" which caused test failures
        # due to a leading newline in the body ("\n1 July 2020").
        expect(page).to have_content(expiry_date.to_s.strip)
      end

      scenario "adds a job to update the Google index in the queue" do
        expect_any_instance_of(Publishers::Vacancies::BaseController)
          .to receive(:update_google_index).with(vacancy)

        visit organisation_job_path(vacancy.id)
        click_header_link(I18n.t("publishers.vacancies.steps.important_dates"))

        expiry_date = Date.current + 1.week
        edit_date("expires_at", expiry_date)
      end

      context "when the job post has already been published" do
        context "when the publication date is in the past" do
          scenario "renders the publication date as text and does not allow editing" do
            vacancy = build(:vacancy, :published, organisations: [school], slug: "test-slug", publish_on: 1.day.ago)
            vacancy.save(validate: false)
            vacancy = VacancyPresenter.new(vacancy)
            visit organisation_job_path(vacancy.id)

            click_header_link(I18n.t("publishers.vacancies.steps.important_dates"))
            expect(page).to have_content(format_date(vacancy.publish_on))

            fill_in "publishers_job_listing_important_dates_form[expires_at(3i)]", with: vacancy.expires_at.day
            click_on I18n.t("buttons.update_job")

            expect(current_path).to eq(organisation_job_path(vacancy.id))
            verify_all_vacancy_details(vacancy)
          end
        end

        context "when the publication date is in the future" do
          scenario "renders the publication date as text and allows editing" do
            vacancy = create(:vacancy, :future_publish, organisations: [school])
            vacancy = VacancyPresenter.new(vacancy)
            visit organisation_job_path(vacancy.id)
            click_header_link(I18n.t("publishers.vacancies.steps.important_dates"))

            expect(page).to have_css("#publishers_job_listing_important_dates_form_publish_on_3i")

            publish_on = Date.current + 1.week
            edit_date("publish_on", publish_on)

            expect(current_path).to eq(organisation_job_path(vacancy.id))

            vacancy.publish_on = publish_on
            verify_all_vacancy_details(vacancy)
          end
        end
      end
    end

    describe "#supporting_documents" do
      let(:filename) { "blank_job_spec.pdf" }

      scenario "can edit documents" do
        visit organisation_job_path(vacancy.id)

        click_header_link(I18n.t("publishers.vacancies.steps.documents"))

        expect(page).to have_content(I18n.t("helpers.label.publishers_job_listing_documents_form.documents"))

        allow(Publishers::DocumentVirusCheck).to receive(:new).and_return(double(safe?: true))
        upload_document(
          "new_publishers_job_listing_documents_form",
          "publishers-job-listing-documents-form-documents-field",
          "spec/fixtures/files/#{filename}",
        )
        click_on I18n.t("buttons.update_job")

        expect(current_path).to eq(organisation_job_path(vacancy.id))
        expect(page).to have_content(filename)
      end
    end

    describe "#applying_for_the_job" do
      scenario "can not be edited when validation fails" do
        visit organisation_job_path(vacancy.id)

        within("h1.govuk-heading-l") do
          expect(page).to have_content(I18n.t("buttons.manage_listing"))
        end
        click_header_link(I18n.t("publishers.vacancies.steps.applying_for_the_job"))

        fill_in "publishers_job_listing_applying_for_the_job_details_form[contact_email]", with: "some email"
        click_on I18n.t("buttons.update_job")

        expect(page).to have_content("There is a problem")
      end

      scenario "can be successfully edited" do
        visit organisation_job_path(vacancy.id)

        click_header_link(I18n.t("publishers.vacancies.steps.applying_for_the_job"))
        vacancy.contact_email = "new-test@example.net"

        fill_in "publishers_job_listing_applying_for_the_job_details_form[contact_email]", with: vacancy.contact_email
        click_on I18n.t("buttons.update_job")

        expect(current_path).to eq(organisation_job_path(vacancy.id))

        verify_all_vacancy_details(vacancy)
      end

      scenario "adds a job to update the Google index in the queue" do
        expect_any_instance_of(Publishers::Vacancies::BaseController)
          .to receive(:update_google_index).with(vacancy)

        visit organisation_job_path(vacancy.id)
        click_header_link(I18n.t("publishers.vacancies.steps.applying_for_the_job"))
        vacancy.contact_email = "new-test@example.net"

        fill_in "publishers_job_listing_applying_for_the_job_details_form[contact_email]", with: vacancy.contact_email
        click_on I18n.t("buttons.update_job")
      end
    end

    describe "#job_summary" do
      scenario "can not be edited when validation fails" do
        visit organisation_job_path(vacancy.id)

        within("h1.govuk-heading-l") do
          expect(page).to have_content(I18n.t("buttons.manage_listing"))
        end
        click_header_link(I18n.t("publishers.vacancies.steps.job_summary"))

        fill_in "publishers_job_listing_job_summary_form[job_advert]", with: ""
        click_on I18n.t("buttons.update_job")

        within_row_for(text: I18n.t("jobs.job_advert")) do
          expect(page).to have_content(I18n.t("job_summary_errors.job_advert.blank"))
        end
      end

      scenario "can be successfully edited" do
        visit organisation_job_path(vacancy.id)
        click_header_link(I18n.t("publishers.vacancies.steps.job_summary"))

        fill_in "publishers_job_listing_job_summary_form[job_advert]", with: "A summary about the job."
        click_on I18n.t("buttons.update_job")

        expect(current_path).to eq(organisation_job_path(vacancy.id))
        expect(page).to have_content("A summary about the job.")
      end

      scenario "adds a job to update the Google index in the queue" do
        expect_any_instance_of(Publishers::Vacancies::BaseController)
          .to receive(:update_google_index).with(vacancy)

        visit organisation_job_path(vacancy.id)
        click_header_link(I18n.t("publishers.vacancies.steps.job_summary"))

        fill_in "publishers_job_listing_job_summary_form[job_advert]", with: "A summary about the job."
        click_on I18n.t("buttons.update_job")
      end
    end
  end

  context "when a vacancy is external" do
    let!(:vacancy) do
      create(
        :vacancy, :external, :at_one_school, :published, :expires_tomorrow,
        job_title: "Imported vacancy",
        organisations: [school]
      )
    end

    scenario "it is visible on the dashboard but cannot be edited" do
      visit organisation_path
      expect(page).to have_content("Imported vacancy")
      expect(page).not_to have_link("Imported vacancy")

      visit organisation_job_path(vacancy.id)
      expect(page).to have_content(I18n.t("error_pages.not_found"))
    end
  end
end
