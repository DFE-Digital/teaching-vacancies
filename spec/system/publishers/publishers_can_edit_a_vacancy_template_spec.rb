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

  describe "change pages" do
    before do
      within "##{change}" do
        click_on "Change"
      end
    end

    context "with name" do
      let(:change) { "name" }

      it "is accessible", :a11y, :retry do
        expect(page).to have_content "What is the template name?"
        expect(page).to be_axe_clean
      end

      it "can be changed" do
        fill_in "What is the template name?", with: template_name
        click_on I18n.t("publishers.vacancies.show.heading_component.action.copy")
        expect(page).to have_content "Template details"
        expect(page).to have_content template_name
        expect(template.reload).to have_attributes(name: template_name)
      end
    end

    context "with role" do
      let(:change) { "job_role" }

      it "is accessible", :a11y, :retry do
        expect(page).to have_content "What type of job is this?"
        expect(page).to be_axe_clean
      end

      it "can have its role edited" do
        check "Headteacher"
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content "Headteacher"
        expect(template.reload).to have_attributes(job_roles: %w[teacher headteacher])
      end
    end

    context "with subjects" do
      let(:change) { "subjects" }

      it "is accessible", :a11y, :retry do
        expect(page).to have_content "Which subject or subjects is this job for? (optional)"
        expect(page).to be_axe_clean
      end

      it "can have its subjects edited to nothing" do
        uncheck "Chemistry"
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_no_content "Chemistry"
        expect(template.reload).to have_attributes(subjects: [])
      end

      it "shows an error when typing in the search bar without selecting a subject" do
        uncheck "Chemistry"
        fill_in "publishers_job_listing_subjects_form[subject_search]", with: "magic"
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content I18n.t("publishers.vacancies.build.subjects.errors.subject_searched_for_but_not_selected")
      end
    end

    context "with key_stages" do
      let(:change) { "key_stages" }

      it "is accessible", :a11y, :retry do
        expect(page).to have_content "Key stages"
        expect(page).to be_axe_clean
      end

      it "can have its key_stages edited" do
        check "Key stage 4"
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content "Key stage 4"
        expect(template.reload).to have_attributes(key_stages: %w[ks3 ks4])
      end
    end

    context "with contract_type" do
      let(:change) { "contract_type" }

      it "is accessible", :a11y, :retry do
        expect(page).to have_content "Contract information"
        #  https://github.com/alphagov/govuk-frontend/issues/979
        expect(page).to be_axe_clean.skipping "aria-allowed-attr"
      end

      it "can have its contract type edited" do
        choose "Permanent"
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content "Permanent"
        expect(template.reload).to have_attributes(contract_type: "permanent")
      end
    end

    context "with salary" do
      let(:change) { "salary" }
      let(:pay_scale) { "M1 to M2" }

      it "is accessible", :a11y, :retry do
        expect(page).to have_content "Salary and allowances"
        #  https://github.com/alphagov/govuk-frontend/issues/979
        expect(page).to be_axe_clean.skipping "aria-allowed-attr"
      end

      it "can have its salary edited" do
        uncheck "Full time equivalent salary"

        check "Pay scale"
        fill_in "Pay scale", with: pay_scale
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content pay_scale
        expect(template.reload).to have_attributes(pay_scale: pay_scale)
      end
    end

    context "with ect status" do
      let(:change) { "ect_status" }

      it "is accessible", :a11y, :retry do
        expect(page).to have_content "Is this role suitable for an early career teacher"
        #  https://github.com/alphagov/govuk-frontend/issues/979
        expect(page).to be_axe_clean.skipping "aria-allowed-attr"
      end

      it "can have its ect status edited" do
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

      it "is accessible", :a11y, :retry do
        expect(page).to have_content "Do you want to offer candidates the opportunity to visit?"
        expect(page).to be_axe_clean.skipping "aria-allowed-attr"
      end

      it "can have its school visits edited" do
        choose "Yes"
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_current_path organisation_vacancy_template_path(template)
        expect(template.reload).to have_attributes(school_visits: true)
      end
    end

    context "with visa_sponsorship_available" do
      let(:change) { "visa_sponsorship_available" }

      it "is accessible", :a11y, :retry do
        expect(page).to have_content "Visa sponsorship"
        expect(page).to be_axe_clean.skipping "aria-allowed-attr"
      end

      it "can have its visa_sponsorship_available edited" do
        choose "Yes"
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_current_path organisation_vacancy_template_path(template)
        expect(template.reload).to have_attributes(visa_sponsorship_available: true)
      end
    end

    context "with application type" do
      let(:change) { "enable_job_applications" }

      it "is accessible", :a11y, :retry do
        expect(page).to have_content "How do you want candidates to apply?"
        expect(page).to be_axe_clean.skipping "aria-allowed-attr"
      end

      it "can have its application type edited" do
        choose "Use your own application form"
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
    fill_in "What is the template name?", with: ""
    click_on I18n.t("publishers.vacancies.show.heading_component.action.copy")
    expect(page).to have_content "Enter a template name"
  end
end
