require "rails_helper"

RSpec.describe "Creating a vacancy" do
  let(:publisher) { create(:publisher) }
  let(:school_group) { create(:trust) }
  let(:school1) { create(:school, name: "First school") }
  let(:school2) { create(:school, name: "Second school") }
  let(:school3) { create(:school, :closed, name: "Closed school") }
  let(:vacancy) { build(:vacancy, :central_office) }
  let(:created_vacancy) { Vacancy.last }

  before do
    login_publisher(publisher: publisher, organisation: school_group)
    SchoolGroupMembership.find_or_create_by(school_id: school1.id, school_group_id: school_group.id)
    SchoolGroupMembership.find_or_create_by(school_id: school2.id, school_group_id: school_group.id)
    SchoolGroupMembership.find_or_create_by(school_id: school3.id, school_group_id: school_group.id)
    allow(PublisherPreference).to receive(:find_by).and_return(instance_double(PublisherPreference))
  end

  scenario "resets session current_step" do
    page.set_rack_session(current_step: :review)

    visit organisation_path
    click_on I18n.t("buttons.create_job")

    fill_in_job_location_form_field(vacancy, "Multi-academy trust")
    click_on I18n.t("buttons.continue")

    expect(page.get_rack_session["current_step"]).to be nil
  end

  context "when job is located at trust central office" do
    let(:vacancy) { build(:vacancy, :central_office) }

    describe "#job_location" do
      scenario "redirects to job details when submitted successfully" do
        visit organisation_path
        click_on I18n.t("buttons.create_job")

        expect(page).to have_content(I18n.t("jobs.current_step", step: 1, total: 8))
        within("h2.govuk-heading-l") do
          expect(page).to have_content(I18n.t("jobs.job_location"))
        end

        fill_in_job_location_form_field(vacancy, "Multi-academy trust")
        click_on I18n.t("buttons.continue")

        expect(page).to have_content(I18n.t("jobs.current_step", step: 2, total: 8))
        within("h2.govuk-heading-l") do
          expect(page).to have_content(I18n.t("jobs.job_details"))
        end
      end
    end
  end

  context "when job is located at a single school in the local authority" do
    let(:vacancy) { build(:vacancy, :at_one_school) }

    describe "#job_location" do
      scenario "displays error message unless a school is selected" do
        visit organisation_path
        click_on I18n.t("buttons.create_job")

        expect(page).to have_content(I18n.t("jobs.current_step", step: 1, total: 8))
        within("h2.govuk-heading-l") do
          expect(page).to have_content(I18n.t("jobs.job_location"))
        end

        fill_in_job_location_form_field(vacancy, "Multi-academy trust")
        click_on I18n.t("buttons.continue")

        expect(page).to have_content(I18n.t("jobs.current_step", step: 1, total: 8))
        within("h2.govuk-heading-l") do
          expect(page).to have_content(I18n.t("jobs.job_location"))
        end

        click_on I18n.t("buttons.continue")

        expect(page).to have_content(I18n.t("jobs.current_step", step: 1, total: 8))
        within("h2.govuk-heading-l") do
          expect(page).to have_content(I18n.t("jobs.job_location"))
        end
        within("div.govuk-error-summary") do
          expect(page).to have_content(I18n.t("schools_errors.organisation_ids.blank"))
        end

        fill_in_school_form_field(school2)
        click_on I18n.t("buttons.continue")

        expect(page).to have_content(I18n.t("jobs.current_step", step: 2, total: 8))
        within("h2.govuk-heading-l") do
          expect(page).to have_content(I18n.t("jobs.job_details"))
        end
      end
    end
  end

  context "when job is located at multiple schools in the trust" do
    let(:vacancy) { build(:vacancy, :at_multiple_schools) }

    describe "#job_location" do
      scenario "displays error message unless at least 2 schools are selected" do
        visit organisation_path
        click_on I18n.t("buttons.create_job")

        expect(page).to have_content(I18n.t("jobs.current_step", step: 1, total: 8))
        within("h2.govuk-heading-l") do
          expect(page).to have_content(I18n.t("jobs.job_location"))
        end

        fill_in_job_location_form_field(vacancy, "Multi-academy trust")
        click_on I18n.t("buttons.continue")

        expect(page).to have_content(I18n.t("jobs.current_step", step: 1, total: 8))
        within("h2.govuk-heading-l") do
          expect(page).to have_content(I18n.t("jobs.job_location"))
        end

        check school1.name, name: "publishers_job_listing_schools_form[organisation_ids][]", visible: false
        click_on I18n.t("buttons.continue")

        expect(page).to have_content(I18n.t("jobs.current_step", step: 1, total: 8))
        within("h2.govuk-heading-l") do
          expect(page).to have_content(I18n.t("jobs.job_location"))
        end
        within("div.govuk-error-summary") do
          expect(page).to have_content(I18n.t("schools_errors.organisation_ids.invalid"))
        end

        check school1.name, name: "publishers_job_listing_schools_form[organisation_ids][]", visible: false
        check school2.name, name: "publishers_job_listing_schools_form[organisation_ids][]", visible: false
        click_on I18n.t("buttons.continue")

        expect(page).to have_content(I18n.t("jobs.current_step", step: 2, total: 8))
        within("h2.govuk-heading-l") do
          expect(page).to have_content(I18n.t("jobs.job_details"))
        end
      end
    end
  end

  scenario "publishes a vacancy" do
    visit organisation_path
    click_on I18n.t("buttons.create_job")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_location))

    click_on I18n.t("buttons.continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_location))

    fill_in_job_location_form_field(vacancy, "Multi-academy trust")
    click_on I18n.t("buttons.continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_details))

    click_on I18n.t("buttons.continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_details))

    fill_in_job_details_form_fields(vacancy)
    click_on I18n.t("buttons.continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :pay_package))

    click_on I18n.t("buttons.continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :pay_package))

    fill_in_pay_package_form_fields(vacancy)
    click_on I18n.t("buttons.continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :important_dates))

    click_on I18n.t("buttons.continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :important_dates))

    fill_in_important_dates_fields(vacancy)
    click_on I18n.t("buttons.continue")
    expect(current_path).to eq(organisation_job_documents_path(created_vacancy.id))

    click_on I18n.t("buttons.continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :applying_for_the_job))

    click_on I18n.t("buttons.continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :applying_for_the_job))

    fill_in_applying_for_the_job_form_fields(vacancy)
    click_on I18n.t("buttons.continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_summary))

    click_on I18n.t("buttons.continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_summary))

    fill_in_job_summary_form_fields(vacancy)
    click_on I18n.t("buttons.continue")
    expect(current_path).to eq(organisation_job_review_path(created_vacancy.id))
    verify_all_vacancy_details(created_vacancy)

    click_on I18n.t("buttons.submit_job_listing")
    expect(current_path).to eq(organisation_job_summary_path(created_vacancy.id))
  end
end
