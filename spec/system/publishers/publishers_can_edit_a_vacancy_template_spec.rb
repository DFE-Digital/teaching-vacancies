require "rails_helper"

RSpec.describe "Editing a vacancy template" do
  let(:publisher) { create(:publisher) }
  let(:template) { create(:vacancy_template, :secondary, organisation: organisation, subjects: %w[Chemistry]) }
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

  describe "accessibility of change pages", :a11y do
    before do
      within "##{change}" do
        click_on "Change"
      end
    end

    context "with name" do
      let(:change) { "name" }

      it "can have its name edited from the template show page", :retry do
        expect(page).to have_content "Template name"
        expect(page).to be_axe_clean

        fill_in "Template name", with: template_name
        click_on I18n.t("publishers.vacancies.show.heading_component.action.copy")
        expect(page).to have_content "Template details"
        expect(page).to have_content template_name
        expect(template.reload).to have_attributes(name: template_name)
      end
    end

    context "with role" do
      let(:change) { "job_role" }

      it "can have its role edited", :retry do
        expect(page).to have_content "What type of job is this?"
        expect(page).to be_axe_clean

        check "Headteacher"
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content "Headteacher"
        expect(template.reload).to have_attributes(job_roles: %w[teacher headteacher])
      end
    end

    context "with subjects" do
      let(:change) { "subjects" }

      it "can have its subjects edited to nothing", :retry do
        expect(page).to have_content "Subjects (optional)"
        expect(page).to be_axe_clean

        uncheck "Chemistry"
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_no_content "Chemistry"
        expect(template.reload).to have_attributes(subjects: [])
      end
    end

    context "with key_stages" do
      let(:change) { "key_stages" }

      it "can have its key_stages edited", :retry do
        expect(page).to have_content "Key stages"
        expect(page).to be_axe_clean

        check "Key stage 4"
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content "Key stage 4"
        expect(template.reload).to have_attributes(key_stages: %w[ks3 ks4])
      end
    end

    context "with contract_type" do
      let(:change) { "contract_type" }

      it "can have its contract type edited", :retry do
        expect(page).to have_content "Contract information"
        #  https://github.com/alphagov/govuk-frontend/issues/979
        expect(page).to be_axe_clean.skipping "aria-allowed-attr"

        choose "Permanent"
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content "Permanent"
        expect(template.reload).to have_attributes(contract_type: "permanent")
      end
    end

    context "with salary" do
      let(:change) { "salary" }
      let(:pay_scale) { "M1 to M2" }

      it "can have its salary edited", :retry do
        expect(page).to have_content "Salary details"
        #  https://github.com/alphagov/govuk-frontend/issues/979
        expect(page).to be_axe_clean.skipping "aria-allowed-attr"

        uncheck "Full-time equivalent salary"

        check "Pay scale"
        fill_in "Pay scale", with: pay_scale
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content pay_scale
        expect(template.reload).to have_attributes(pay_scale: pay_scale)
      end
    end

    context "with ect status" do
      let(:change) { "ect_status" }

      it "can have its ect status edited", :retry do
        expect(page).to have_content "Is this role suitable for an early career teacher"
        #  https://github.com/alphagov/govuk-frontend/issues/979
        expect(page).to be_axe_clean.skipping "aria-allowed-attr"

        within ".ect-status-radios" do
          choose "No"
        end
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_current_path organisation_vacancy_template_path(template)
        expect(template.reload).to have_attributes(ect_status: "ect_unsuitable")
      end
    end

    context "with school visits" do
      let(:change) { "school_visits" }

      it "can have its school visits edited", :retry do
        expect(page).to have_content "Do you want to offer candidates a visit?"
        expect(page).to be_axe_clean.skipping "aria-allowed-attr"

        choose "Yes"
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_current_path organisation_vacancy_template_path(template)
        expect(template.reload).to have_attributes(school_visits: true)
      end
    end

    context "with visa_sponsorship_available" do
      let(:change) { "visa_sponsorship_available" }

      it "can have its visa_sponsorship_available edited", :a11y do
        expect(page).to have_content "Visa sponsorship"
        expect(page).to be_axe_clean.skipping "aria-allowed-attr"

        choose "Yes"
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_current_path organisation_vacancy_template_path(template)
        expect(template.reload).to have_attributes(visa_sponsorship_available: true)
      end
    end

    context "with application type" do
      let(:change) { "enable_job_applications" }

      it "can have its application type edited", :retry do
        expect(page).to have_content "Choose your application form"
        expect(page).to be_axe_clean.skipping "aria-allowed-attr"

        choose "Use other application form"
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_current_path organisation_vacancy_template_path(template)
        expect(template.reload).to have_attributes(enable_job_applications: false)
      end
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
