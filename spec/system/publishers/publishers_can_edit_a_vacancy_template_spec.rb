require "rails_helper"

RSpec.describe "Editing a vacancy template" do
  let(:publisher) { create(:publisher) }
  let(:template) { create(:vacancy_template, organisation: organisation) }
  let(:organisation) { create(:school) }
  let(:template_name) { Faker::Movie.title }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    visit organisation_vacancy_template_path(template)
  end

  after { logout }

  it "can be deleted" do
    expect(page).to have_content "Change"

    expect {
      click_on "Delete template"
      expect(page).to have_current_path(organisation_vacancy_templates_path)
    }.to change(VacancyTemplate, :count).by(-1)
  end

  describe "accessibility of change pages" do
    it "can have its name edited from the template show page", :a11y do
      expect(page).to have_content "Change"

      within "#name" do
        click_on "Change"
      end

      expect(page).to have_content "Template name"
      expect(page).to be_axe_clean

      fill_in "Template name", with: template_name
      click_on I18n.t("publishers.vacancies.show.heading_component.action.copy")
      expect(page).to have_content "Template details"
      expect(page).to have_content template_name
      expect(template.reload).to have_attributes(name: template_name)
    end

    it "can have its role edited", :a11y do
      expect(page).to have_content "Change"

      within "#job_role" do
        click_on "Change"
      end

      expect(page).to have_content "What type of job is this?"
      expect(page).to be_axe_clean

      check "Headteacher"
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_content "Headteacher"
      expect(template.reload).to have_attributes(job_roles: %w[teacher headteacher])
    end

    it "can have its key_stages edited", :a11y do
      expect(page).to have_content "Change"

      within "#key_stages" do
        click_on "Change"
      end

      expect(page).to have_content "Key stages"
      expect(page).to be_axe_clean

      check "Key stage 2"
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_content "Key stage 2"
      expect(template.reload).to have_attributes(key_stages: %w[ks1 ks2])
    end

    it "can have its contract type edited", :a11y do
      expect(page).to have_content "Change"

      within "#contract_type" do
        click_on "Change"
      end

      expect(page).to have_content "Contract information"
      #  https://github.com/alphagov/govuk-frontend/issues/979
      expect(page).to be_axe_clean.skipping "aria-allowed-attr"

      choose "Permanent"
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_content "Permanent"
      expect(template.reload).to have_attributes(contract_type: "permanent")
    end

    it "can have its salary edited", :a11y do
      expect(page).to have_content "Change"

      within "#salary" do
        click_on "Change"
      end

      expect(page).to have_content "Salary details"
      #  https://github.com/alphagov/govuk-frontend/issues/979
      expect(page).to be_axe_clean.skipping "aria-allowed-attr"

      uncheck "Full-time equivalent salary"

      check "Pay scale"
      fill_in "Pay scale", with: "M1 to M2"
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_content "M1 to M2"
      expect(template.reload).to have_attributes(pay_scale: "M1 to M2")
    end

    it "has an accessible ECT page", :a11y do
      expect(page).to have_content "Change"

      within "#ect_status" do
        click_on "Change"
      end

      expect(page).to have_content "Is this role suitable for an early career teacher"
      #  https://github.com/alphagov/govuk-frontend/issues/979
      expect(page).to be_axe_clean.skipping "aria-allowed-attr"
    end

    it "can have its ect status edited" do
      expect(page).to have_content "Change"

      within "#ect_status" do
        click_on "Change"
      end

      expect(page).to have_content "Is this role suitable for an early career teacher"

      within ".ect-status-radios" do
        choose "No"
      end
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_current_path organisation_vacancy_template_path(template)
      expect(template.reload).to have_attributes(ect_status: "ect_unsuitable")
    end

    it "can have its school visits edited", :a11y do
      expect(page).to have_content "Change"

      within "#school_visits" do
        click_on "Change"
      end

      expect(page).to have_content "Do you want to offer school visits?"
      expect(page).to be_axe_clean.skipping "aria-allowed-attr"

      choose "Yes"
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_current_path organisation_vacancy_template_path(template)
      expect(template.reload).to have_attributes(school_visits: true)
    end

    it "can have its visa_sponsorship_available edited", :a11y do
      expect(page).to have_content "Change"

      within "#visa_sponsorship_available" do
        click_on "Change"
      end

      expect(page).to have_content "Visa sponsorship"
      expect(page).to be_axe_clean.skipping "aria-allowed-attr"

      choose "Yes"
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_current_path organisation_vacancy_template_path(template)
      expect(template.reload).to have_attributes(visa_sponsorship_available: true)
    end

    it "can have its application type edited", :a11y, :retry do
      expect(page).to have_content "Change"

      within "#enable_job_applications" do
        click_on "Change"
      end

      expect(page).to have_content "Choose your application form"
      expect(page).to be_axe_clean.skipping "aria-allowed-attr"

      choose "Use other application form"
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_current_path organisation_vacancy_template_path(template)
      expect(template.reload).to have_attributes(enable_job_applications: false)
    end
  end

  it "bounces blank updates" do
    expect(page).to have_content "Change"

    within "#name" do
      click_on "Change"
    end
    fill_in "Template name", with: ""
    click_on I18n.t("publishers.vacancies.show.heading_component.action.copy")
    expect(page).to have_content "Enter a template name"
  end
end
