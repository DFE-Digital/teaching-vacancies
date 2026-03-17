require "rails_helper"

RSpec.describe "Jobseekers can manage their personal details" do
  let(:jobseeker) { create(:jobseeker) }
  let(:bexleyheath) { %w[0.14606549011864176 51.457814649098104] }
  let(:organisation) do
    create(:school,
           publishers: [build(:publisher)],
           geopoint: RGeo::Geographic.spherical_factory(srid: 4326).point(*bexleyheath))
  end
  let(:publisher) { organisation.publishers.first }

  before { login_as(jobseeker, scope: :jobseeker) }

  after { logout }

  describe "changing personal details" do
    context "when filling in the profile for the first time" do
      let(:first_name) { "Frodo" }
      let(:last_name) { "Baggins" }
      let(:phone_number) { "07777777777" }

      before do
        visit jobseekers_profile_path
        click_on "Your profile"
        click_link("Add personal details")
      end

      it "passes a11y", :a11y do
        expect(page).to be_axe_clean
      end

      context "with an error" do
        before do
          click_on I18n.t("buttons.save_and_continue")
        end

        it "displays an error" do
          expect(page).to have_content("There is a problem")
        end
      end

      describe "phone number screen" do
        before do
          fill_in "jobseekers_profiles_personal_details_form_names_form[first_name]", with: first_name
          fill_in "jobseekers_profiles_personal_details_form_names_form[last_name]", with: last_name
          click_on I18n.t("buttons.save_and_continue")
          # wait for page to load
          find("label[for='jobseekers-profiles-personal-details-form-phone-number-form-phone-number-provided-true-field']")
        end

        it "passes a11y", :a11y do
          #  https://github.com/alphagov/govuk-frontend/issues/979
          expect(page).to be_axe_clean.skipping "aria-allowed-attr"
        end

        it "asks for a phone number" do
          expect(page).to have_content("Do you want to provide a phone number?")
        end

        context "when asking for visa sponsorship" do
          before do
            choose "Yes"
            fill_in "jobseekers_profiles_personal_details_form_phone_number_form[phone_number]", with: phone_number
            click_on I18n.t("buttons.save_and_continue")
          end

          it "passes a11y", :a11y do
            expect(page).to be_axe_clean
          end

          it "allows the jobseeker to fill in their personal details" do
            expect(page).to have_content("Do you need Skilled Worker visa sponsorship?")
            choose "Yes"
            click_on I18n.t("buttons.save_and_continue")

            click_on I18n.t("buttons.return_to_profile")

            expect(page).to have_content("#{first_name} #{last_name}")
            expect(page).to have_content(phone_number)
            expect(page).to have_content("Yes, I will need to apply for a visa giving me the right to work in the UK")
          end
        end
      end

      it "does not display a notice to inform the user about prefilling" do
        expect(page).to have_no_content("your details have been imported into your profile")
      end
    end

    context "when editing a profile that has already been completed" do
      let(:profile) { create(:jobseeker_profile, :with_personal_details, jobseeker:) }

      let(:new_first_name) { "Samwise" }
      let(:new_last_name) { "Gamgee" }
      let(:old_phone_number) { "07777777777" }

      before do
        profile.personal_details.update!(
          first_name: "Frodo",
          last_name: "Baggins",
          phone_number_provided: true,
          phone_number: old_phone_number,
          completed_steps: completed_steps,
          has_right_to_work_in_uk: right_to_work,
        )

        visit jobseekers_profile_path
      end

      context "without a work completed step" do
        let(:completed_steps) { { "name" => "completed", "phone_number" => "completed" } }
        let(:right_to_work) { nil }

        it "has an edit link" do
          expect(page).to have_link("Complete personal details", href: jobseekers_profile_personal_details_step_path(:work))
        end
      end

      context "with a work completed step" do
        let(:completed_steps) { { "name" => "completed", "phone_number" => "completed", "work" => "completed" } }
        let(:right_to_work) { true }

        it "allows the jobseeker to edit their profile" do
          row = page.find(".govuk-summary-list__key", text: "Name").find(:xpath, "..")

          within(row) do
            click_link "Change"
          end

          fill_in "jobseekers_profiles_personal_details_form_names_form[first_name]", with: new_first_name
          fill_in "jobseekers_profiles_personal_details_form_names_form[last_name]", with: new_last_name
          click_on I18n.t("buttons.save_and_continue")

          phone_row = page.find(".govuk-summary-list__key", text: "Phone number").find(:xpath, "..")
          within(phone_row) do
            click_link "Change"
          end

          choose "No"
          click_on I18n.t("buttons.save_and_continue")

          expect(page).to have_content("#{new_first_name} #{new_last_name}")
          expect(page).to have_content("Do you want to provide a phone number?No")
          expect(page).to have_no_content(old_phone_number)
          expect(page).to have_content("No, I already have the right to work in the UK")
        end

        it "can be previewed" do
          within "#top_links" do
            click_on "Preview profile"
          end
        end
      end
    end
  end

  describe "personal details if the jobseeker has a previous job application" do
    let(:previous_application) { jobseeker.job_applications.last }

    before do
      create(:job_application, :status_submitted, jobseeker:)
      visit jobseekers_profile_path
    end

    it "prefills the form with the jobseeker's personal details" do
      expect(page).to have_content(previous_application.first_name)
      expect(page).to have_content(previous_application.last_name)
      expect(page).to have_content(previous_application.phone_number)
    end

    it "adds a notice to inform the user" do
      expect(page).to have_content("your details have been imported into your profile")
    end
  end

  describe "personal details if the jobseeker has a previously submitted job application" do
    let(:first_name) { "Alfred" }
    let(:last_name) { "Accelsior" }
    let(:phone_number) { "01234567890" }

    before do
      create(:job_application, :status_submitted, jobseeker:, first_name:, last_name:, phone_number:)
      visit jobseekers_profile_path
    end

    it "prefills the form with the jobseeker's provided personal details" do
      expect(page).to have_content(first_name)
      expect(page).to have_content(last_name)
      expect(page).to have_content(phone_number)
    end
  end

  describe "personal details if the jobseeker has a blank previous draft job application" do
    let!(:previous_application) { create(:job_application, :status_draft, jobseeker:, first_name: nil, last_name: nil, phone_number: "01234567890") }

    before do
      visit jobseekers_profile_path
    end

    it "does not prefill the form with the personal details from the draft application" do
      expect(page).to have_no_content(previous_application.phone_number)
    end
  end
end
