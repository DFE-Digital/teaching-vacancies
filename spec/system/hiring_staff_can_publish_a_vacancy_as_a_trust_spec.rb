require "rails_helper"

RSpec.describe "Creating a vacancy" do
  let(:school_group) { create(:trust) }
  let(:school_1) { create(:school, name: "First school") }
  let(:school_2) { create(:school, name: "Second school") }
  let(:school_3) { create(:school, :closed, name: "Closed school") }
  let(:oid) { SecureRandom.uuid }
  let(:vacancy) { build(:vacancy, :at_central_office, :complete) }

  before do
    SchoolGroupMembership.find_or_create_by(school_id: school_1.id, school_group_id: school_group.id)
    SchoolGroupMembership.find_or_create_by(school_id: school_2.id, school_group_id: school_group.id)
    SchoolGroupMembership.find_or_create_by(school_id: school_3.id, school_group_id: school_group.id)
    allow(PublisherPreference).to receive(:find_by).and_return(instance_double(PublisherPreference))
    stub_publishers_auth(uid: school_group.uid, oid: oid)
  end

  scenario "resets session current_step" do
    page.set_rack_session(current_step: :review)

    visit organisation_path
    click_on I18n.t("buttons.create_job")

    fill_in_job_location_form_field(vacancy)
    click_on I18n.t("buttons.continue")

    expect(page.get_rack_session["current_step"]).to be nil
  end

  context "when job is located at trust central office" do
    let(:vacancy) { build(:vacancy, :at_central_office, :complete) }

    describe "#job_location" do
      scenario "redirects to job details when submitted successfully" do
        visit organisation_path
        click_on I18n.t("buttons.create_job")

        expect(page).to have_content(I18n.t("jobs.current_step", step: 1, total: 8))
        within("h2.govuk-heading-l") do
          expect(page).to have_content(I18n.t("jobs.job_location"))
        end

        fill_in_job_location_form_field(vacancy)
        click_on I18n.t("buttons.continue")

        expect(page).to have_content(I18n.t("jobs.current_step", step: 2, total: 8))
        within("h2.govuk-heading-l") do
          expect(page).to have_content(I18n.t("jobs.job_details"))
        end
      end
    end
  end

  context "when job is located at a single school in the local authority" do
    let(:vacancy) { build(:vacancy, :at_one_school, :complete) }

    describe "#job_location" do
      scenario "displays error message unless a school is selected" do
        visit organisation_path
        click_on I18n.t("buttons.create_job")

        expect(page).to have_content(I18n.t("jobs.current_step", step: 1, total: 8))
        within("h2.govuk-heading-l") do
          expect(page).to have_content(I18n.t("jobs.job_location"))
        end

        fill_in_job_location_form_field(vacancy)
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

        fill_in_school_form_field(school_2)
        click_on I18n.t("buttons.continue")

        expect(page).to have_content(I18n.t("jobs.current_step", step: 2, total: 8))
        within("h2.govuk-heading-l") do
          expect(page).to have_content(I18n.t("jobs.job_details"))
        end
      end
    end
  end

  context "when job is located at multiple schools in the trust" do
    let(:vacancy) { build(:vacancy, :at_multiple_schools, :complete) }

    describe "#job_location" do
      scenario "displays error message unless at least 2 schools are selected" do
        visit organisation_path
        click_on I18n.t("buttons.create_job")

        expect(page).to have_content(I18n.t("jobs.current_step", step: 1, total: 8))
        within("h2.govuk-heading-l") do
          expect(page).to have_content(I18n.t("jobs.job_location"))
        end

        fill_in_job_location_form_field(vacancy)
        click_on I18n.t("buttons.continue")

        expect(page).to have_content(I18n.t("jobs.current_step", step: 1, total: 8))
        within("h2.govuk-heading-l") do
          expect(page).to have_content(I18n.t("jobs.job_location"))
        end

        check school_1.name, name: "schools_form[organisation_ids][]", visible: false
        click_on I18n.t("buttons.continue")

        expect(page).to have_content(I18n.t("jobs.current_step", step: 1, total: 8))
        within("h2.govuk-heading-l") do
          expect(page).to have_content(I18n.t("jobs.job_location"))
        end
        within("div.govuk-error-summary") do
          expect(page).to have_content(I18n.t("schools_errors.organisation_ids.invalid"))
        end

        check school_1.name, name: "schools_form[organisation_ids][]", visible: false
        check school_2.name, name: "schools_form[organisation_ids][]", visible: false
        click_on I18n.t("buttons.continue")

        expect(page).to have_content(I18n.t("jobs.current_step", step: 2, total: 8))
        within("h2.govuk-heading-l") do
          expect(page).to have_content(I18n.t("jobs.job_details"))
        end
      end
    end
  end
end
