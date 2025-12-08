require "rails_helper"

RSpec.describe "Jobseekers can manage their profile" do
  let(:jobseeker) { create(:jobseeker) }
  let(:geocoding_stub) { instance_double(Geocoding) }
  let(:bexleyheath) { %w[0.14606549011864176 51.457814649098104] }
  let(:organisation) do
    create(:school,
           publishers: [build(:publisher)],
           geopoint: RGeo::Geographic.spherical_factory(srid: 4326).point(*bexleyheath))
  end
  let(:publisher) { organisation.publishers.first }

  before do
    allow(Geocoding).to receive(:new).with(anything).and_return(geocoding_stub)
    allow(Geocoding).to receive(:new).with("San Francisco").and_return(instance_double(Geocoding, uk_coordinates?: false))
  end

  context "with a jobseeker" do
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

        context "when on the phone number screen" do
          before do
            fill_in "personal_details_form[first_name]", with: first_name
            fill_in "personal_details_form[last_name]", with: last_name
            click_on I18n.t("buttons.save_and_continue")
            # wait for page to load
            find("label[for='personal-details-form-phone-number-provided-true-field']")
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
              fill_in "personal_details_form[phone_number]", with: phone_number
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
          expect(page).not_to have_content("your details have been imported into your profile")
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
            completed_steps: { "name" => "completed", "phone_number" => "completed" },
          )

          visit jobseekers_profile_path
        end

        it "allows the jobseeker to edit their profile" do
          row = page.find(".govuk-summary-list__key", text: "Name").find(:xpath, "..")

          within(row) do
            click_link "Change"
          end

          fill_in "personal_details_form[first_name]", with: new_first_name
          fill_in "personal_details_form[last_name]", with: new_last_name
          click_on I18n.t("buttons.save_and_continue")

          choose "No"
          click_on I18n.t("buttons.save_and_continue")

          choose "No"
          click_on I18n.t("buttons.save_and_continue")

          expect(page).to have_content("#{new_first_name} #{new_last_name}")
          expect(page).to have_content("Do you want to provide a phone number?No")
          expect(page).not_to have_content(old_phone_number)
          expect(page).to have_content("No, I already have the right to work in the UK")
        end

        it "can be previewed" do
          within "#top_links" do
            click_on "Preview profile"
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
      let!(:previous_application) { create(:job_application, :status_submitted, jobseeker:, first_name:, last_name:, phone_number:) }

      before do
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
        expect(page).not_to have_content(previous_application.phone_number)
      end
    end

    describe "#about_you" do
      let(:jobseeker_about_you) { "I am an amazing teacher" }

      before do
        visit jobseekers_profile_path
        click_link("Add details about you")
      end

      it "allows the jobseeker to add #about_you" do
        fill_in "jobseekers_profile_about_you_form[about_you]", with: jobseeker_about_you
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content(jobseeker_about_you)

        click_link I18n.t("buttons.return_to_profile")
        expect(page).to have_content(jobseeker_about_you)
      end
    end

    describe "changing the jobseekers's QTS status" do
      before do
        visit jobseekers_profile_path
      end

      let(:subject_ages) { "Primary school particle physics" }

      it "allows the jobseeker to edit their QTS status to yes with year achieved" do
        click_link("Add qualified teacher status")
        within(find("fieldset", text: "Do you have qualified teacher status (QTS)?")) do
          choose "Yes"
        end
        fill_in "jobseekers_profiles_qualified_teacher_status_form[qualified_teacher_status_year]", with: "2019"
        fill_in "What is your teacher reference number (TRN)?", with: "1234567"
        fill_in "Age range and subject you trained to teach", with: subject_ages
        choose "No, I have not completed my induction period"
        fill_in "jobseekers-profiles-qualified-teacher-status-form-statutory-induction-complete-details-field", with: "I am working on it."
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content("2019")
        expect(page).to have_content("I am working on it.")
        expect(page).to have_content(subject_ages)
      end

      it "allows the jobseeker to edit their QTS status to no" do
        click_link("Add qualified teacher status")

        choose "I’m on track to receive QTS"
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content("I’m on track to receive QTS")
        expect(page).not_to have_content("2019")
      end
    end

    describe "QTS if the jobseeker has a previous job application" do
      let!(:previous_application) { create(:job_application, :status_submitted, jobseeker:) }

      before do
        visit jobseekers_profile_path
      end

      it "prefills the form with the jobseeker's personal details" do
        expect(page).to have_content("Year QTS gained#{previous_application.qualified_teacher_status_year}")
      end
    end

    describe "work history" do
      describe "adding an employment history entry to a profile" do
        let(:profile) { jobseeker.jobseeker_profile }

        before do
          create(:jobseeker_profile, jobseeker:)
          visit jobseekers_profile_path
        end

        describe "errors" do
          before do
            click_link("Add roles")
          end

          it "raises errors for missing fields" do
            check "I currently work here"
            click_on I18n.t("buttons.save_and_continue")

            expect(page).to have_css("ul.govuk-list.govuk-error-summary__list")

            within "ul.govuk-list.govuk-error-summary__list" do
              expect(all("a").map { |l| [l.text, l[:href]] })
                .to contain_exactly(["Enter a school or other organisation", "#jobseekers-profile-employment-form-organisation-field-error"],
                                    ["Enter your job title", "#jobseekers-profile-employment-form-job-title-field-error"],
                                    ["Enter your main duties for this role", "#jobseekers-profile-employment-form-main-duties-field-error"],
                                    ["Enter your reason for leaving this role", "#jobseekers-profile-employment-form-reason-for-leaving-field-error"],
                                    ["Enter the date you started at this school or organisation", "#jobseekers-profile-employment-form-started-on-field-error"])
            end
          end
        end

        it "associates an 'employment' with their jobseeker profile", :js do
          expect { add_jobseeker_profile_employment }.to change { profile.employments.count }.by(1)
        end

        context "when the form to add a new employment history entry is submitted" do
          it "displays every employment history entry on the review page" do
            add_jobseeker_profile_employment

            expect(page).to have_current_path(review_jobseekers_profile_work_history_index_path, ignore_query: true)

            click_link "Return to profile"

            profile.employments.each do |employment|
              expect(page).to have_content(employment.organisation)
              expect(page).to have_content(employment.job_title)
              expect(page).to have_content(employment.started_on.to_fs(:month_year))
              expect(page).to have_content(employment.ended_on.to_fs(:month_year)) unless employment.is_current_role?
              expect(page).to have_content(employment.main_duties)
              expect(page).to have_content(employment.reason_for_leaving)
            end
          end

          it "asks user to account for any gaps in employment" do
            add_jobseeker_profile_employment
            click_link "Return to profile"
            add_jobseeker_profile_employment_with_a_gap
            click_link "Return to profile"

            expect(page).to have_content "You have a gap in your work history (almost 1 year)"
            expect(page).to have_content "Add another job or add a reason for this gap"
            click_link "add a reason for this gap"

            click_button "Continue"

            expect(page).to have_selector(".govuk-error-summary__list", text: "Enter a reason for this gap")

            fill_in "jobseekers_break_form[reason_for_break]", with: "I was travelling"

            click_button "Continue"

            expect(page).to have_css(".govuk-inset-text", text: "Gap in work history")

            gap = Employment.find_by(employment_type: "break")

            within(".govuk-inset-text") do
              expect(page).to have_content("I was travelling")
              expect(page).to have_content("#{Date::MONTHNAMES[gap.started_on.month]} #{gap.started_on.year} to #{Date::MONTHNAMES[gap.ended_on.month]} #{gap.ended_on.year}")
            end

            click_on "Change Gap in work history #{gap.started_on} to #{gap.ended_on}"

            fill_in "Enter reasons for gap in work history", with: ""
            click_on I18n.t("buttons.continue")

            expect(page).to have_content("There is a problem")

            fill_in "Enter reasons for gap in work history", with: "I was ill"
            click_on I18n.t("buttons.continue")

            expect(page).to have_content("I was ill")

            click_on "Delete Gap in work history #{gap.started_on} to #{gap.ended_on}"
            click_on I18n.t("buttons.confirm_destroy")

            expect(page).not_to have_content("I was ill")
            expect(page).to have_content "You have a gap in your work history (almost 1 year)"
            expect(page).to have_content "Add another job or add a reason for this gap"
          end
        end
      end

      describe "changing an existing employment history entry" do
        let(:profile) { create(:jobseeker_profile, jobseeker:) }
        let(:employment) { create(:employment, :jobseeker_profile_employment, jobseeker_profile: profile) }
        let(:new_employment) { build(:employment, organisation: "NASA", job_title: "Chief ET locator", reason_for_leaving: "Relocating") }

        before do
          visit edit_jobseekers_profile_work_history_path(employment)
        end

        it "successfully changes the employment record" do
          expect(page).to have_content(employment.main_duties)
          expect(page).to have_content(employment.reason_for_leaving)

          fill_in I18n.t("helpers.label.jobseekers_profile_employment_form.organisation"), with: new_employment.organisation
          fill_in I18n.t("helpers.label.jobseekers_profile_employment_form.job_title"), with: new_employment.job_title
          fill_in I18n.t("helpers.label.jobseekers_profile_employment_form.reason_for_leaving"), with: new_employment.reason_for_leaving
          fill_in I18n.t("helpers.label.jobseekers_profile_employment_form.main_duties"), with: new_employment.main_duties
          fill_in I18n.t("helpers.label.jobseekers_profile_employment_form.subjects"), with: new_employment.subjects

          click_on I18n.t("buttons.save_and_continue")
          expect(page).to have_current_path(review_jobseekers_profile_work_history_index_path, ignore_query: true)

          expect(profile.employments.count).to eq(1)
          expect(profile.employments.first).to have_attributes(organisation: new_employment.organisation,
                                                               job_title: new_employment.job_title,
                                                               subjects: new_employment.subjects,
                                                               main_duties: new_employment.main_duties,
                                                               reason_for_leaving: new_employment.reason_for_leaving)
        end
      end

      describe "deleting an employment history entry" do
        let!(:profile) { create(:jobseeker_profile, jobseeker:) }
        let!(:employment) { create(:employment, :jobseeker_profile_employment, jobseeker_profile_id: profile.id) }

        it "deletes the employment record" do
          visit review_jobseekers_profile_work_history_index_path

          within(".govuk-summary-card", match: :first) { click_link I18n.t("buttons.delete") }

          expect(profile.employments.any?).to be false
          expect(page).to have_current_path(review_jobseekers_profile_work_history_index_path, ignore_query: true)
        end
      end

      context "if the jobseeker has a previous job application" do
        let!(:previous_application) { create(:job_application, :status_submitted, jobseeker:, create_details: true) }

        before { visit jobseekers_profile_path }

        it "prefills the form with the jobseeker's work history and qualifications" do
          previous_application.employments.each do |employment|
            if employment.job?
              expect(page).to have_content(employment.organisation)
            elsif employment.break?
              expect(page).to have_content("You have a gap in your work history")
            end
          end

          previous_application.qualifications.each do |qualification|
            expect(page).to have_content(qualification.name)
          end
        end
      end
    end
  end

  context "if the profile does not exist" do
    it "does not appear in search results" do
      run_with_publisher(publisher) do
        visit publishers_jobseeker_profiles_path
        expect(page).not_to have_css(".search-results__item")
      end
    end
  end

  describe "toggling on and off" do
    let!(:profile) { create(:jobseeker_profile, jobseeker:, job_preferences:, active: false) }

    let(:job_preferences) { build(:job_preferences) }

    # beware - bexleyheath here is long/lat which is DB order, however Geocoder API
    # returns lat/long so we have to reverse the order for the stub call
    before do
      allow(geocoding_stub).to receive(:coordinates).and_return(bexleyheath.reverse)
      create(:job_preferences_location, radius: 200, job_preferences: job_preferences)
    end

    context "if the profile is inactive" do
      let!(:profile) { create(:jobseeker_profile, :with_personal_details, jobseeker:, job_preferences:, active: false) }

      it "does not appear in search results" do
        run_with_publisher(publisher) do
          visit publishers_jobseeker_profiles_path
          expect(page).not_to have_content(profile.full_name)
        end
      end
    end

    context "when profile contains minimum information required for publishing" do
      let!(:profile) do
        create(:jobseeker_profile, :with_personal_details,
               :with_qualifications,
               employments: build_list(:employment, 1, :current_role, job_application: nil),
               job_preferences:,
               jobseeker:,
               active: false)
      end

      it "can be toggled on and off" do
        run_with_jobseeker(jobseeker) do
          visit jobseekers_profile_path

          expect(page).to have_content(I18n.t("jobseekers.profiles.show.preview_and_turn_on_profile"))
          expect(page).not_to have_css(".govuk-tag", text: I18n.t("jobseekers.profiles.show.active"))
        end

        run_with_publisher(publisher) do
          visit publishers_jobseeker_profiles_path
          expect(page).not_to have_content(profile.full_name)
        end

        run_with_jobseeker(jobseeker) do
          visit jobseekers_profile_path
          within ".preview-and-turn-on-profile" do
            click_link I18n.t("jobseekers.profiles.show.turn_on_profile")
          end

          click_button I18n.t("jobseekers.profiles.show.turn_on_profile")
          expect(page).to have_content(I18n.t("jobseekers.profiles.show.profile_turned_on"))
          expect(page).to have_css(".govuk-tag", text: I18n.t("jobseekers.profiles.show.active"))
          expect(page).to have_link(I18n.t("jobseekers.profiles.show.turn_off_profile"))
        end

        run_with_publisher(publisher) do
          visit publishers_jobseeker_profiles_path
          expect(page).to have_content(profile.full_name)
        end

        run_with_jobseeker(jobseeker) do
          visit jobseekers_profile_path
          within ".preview-and-turn-on-profile" do
            click_link I18n.t("jobseekers.profiles.show.turn_off_profile")
          end

          click_button I18n.t("jobseekers.profiles.show.turn_off_profile")
          expect(page).to have_content(I18n.t("jobseekers.profiles.show.profile_turned_off"))
          expect(page).not_to have_css(".govuk-tag", text: I18n.t("jobseekers.profiles.show.active"))
          expect(page).to have_link(I18n.t("jobseekers.profiles.show.turn_on_profile"))
        end

        run_with_publisher(publisher) do
          visit publishers_jobseeker_profiles_path
          expect(page).not_to have_content(profile.full_name)

          visit publishers_jobseeker_profile_path(profile)
          expect(page).to have_content("Page not found")
        end
      end
    end

    context "when profile does not contain minimum information required for publishing" do
      let!(:profile) do
        create(:jobseeker_profile, %i[with_personal_details with_job_preferences].sample,
               jobseeker:,
               active: false)
      end

      it "cannot be toggled on" do
        run_with_jobseeker(jobseeker) do
          visit jobseekers_profile_path

          expect(page).to have_content(I18n.t("jobseekers.profiles.show.preview_and_turn_on_profile"))
          expect(page).not_to have_css(".govuk-tag", text: I18n.t("jobseekers.profiles.show.active"))

          within ".preview-and-turn-on-profile" do
            click_link I18n.t("jobseekers.profiles.show.turn_on_profile")
          end

          expect(page).to have_content I18n.t("jobseekers.profiles.toggle.not_ready")
        end
      end
    end
  end

  describe "hiding profile from specific organisations" do
    before do
      allow(geocoding_stub).to receive(:coordinates).and_return(bexleyheath.reverse)
      create(:job_preferences_location, radius: 200, job_preferences: job_preferences)
    end

    let(:bexleyheath_geopoint) do
      RGeo::Geographic.spherical_factory(srid: 4326).point(*bexleyheath)
    end

    let!(:permitted_organisation) do
      create(:school,
             name: "Permitted School",
             publishers: [permitted_publisher],
             geopoint: bexleyheath_geopoint)
    end

    let!(:forbidden_organisation) do
      create(:school,
             name: "Forbidden School",
             postcode: "FB1 1FB",
             publishers: [forbidden_publisher],
             geopoint: bexleyheath_geopoint)
    end

    let(:permitted_publisher) { create(:publisher) }
    let(:forbidden_publisher) { create(:publisher) }

    let!(:profile) { create(:jobseeker_profile, :with_personal_details, jobseeker:, job_preferences:, active: true) }

    let(:job_preferences) { build(:job_preferences) }

    it "allows the jobseeker to hide themselves from specific schools", :js do
      run_with_publisher(permitted_publisher) do
        visit publishers_jobseeker_profiles_path
        expect(page).to have_content(profile.full_name)
      end

      run_with_publisher(forbidden_publisher) do
        visit publishers_jobseeker_profiles_path
        expect(page).to have_content(profile.full_name)
      end

      run_with_jobseeker(jobseeker) do
        visit jobseekers_profile_path
        click_on I18n.t("jobseekers.profiles.show.set_up_profile_visibility")
        choose "Yes", visible: false
        click_on I18n.t("buttons.save_and_continue")

        field = find_field("Name of school or trust")
        field.fill_in(with: forbidden_organisation.name[..5])
        # check that search dropdown works correctly
        expect(page).to have_content "Forbidden School (FB1 1FB)"
        field.fill_in(with: forbidden_organisation.name)
        click_on I18n.t("buttons.save_and_continue")

        choose "Yes", visible: false
        click_on I18n.t("buttons.save_and_continue")

        field = find_field("Name of school or trust")
        field.fill_in(with: forbidden_organisation.name)
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content(I18n.t("jobseekers.profiles.hide_profile.schools.already_hidden", name: forbidden_organisation.name))

        # make sure review page loads ok
        choose "No", visible: false
        click_on I18n.t("buttons.save_and_continue")
        expect(page).to have_content forbidden_organisation.name
      end

      run_with_publisher(forbidden_publisher) do
        visit publishers_jobseeker_profiles_path
        expect(page).not_to have_content(profile.full_name)
      end

      run_with_publisher(permitted_publisher) do
        visit publishers_jobseeker_profiles_path
        expect(page).to have_content(profile.full_name)
      end

      run_with_jobseeker(jobseeker) do
        visit schools_jobseekers_profile_hide_profile_path
        within page.find(".govuk-summary-list__key", text: forbidden_organisation.name).find(:xpath, "..") do
          click_on I18n.t("buttons.delete")
        end
        click_button I18n.t("jobseekers.profiles.hide_profile.delete.delete_school")
      end

      run_with_publisher(forbidden_publisher) do
        visit publishers_jobseeker_profiles_path
        expect(page).to have_content(profile.full_name)
      end
    end

    context "if the organisation is a trust" do
      let!(:forbidden_trust) do
        create(:trust,
               name: "Forbidden Trust",
               publishers: [forbidden_trust_publisher],
               schools: [forbidden_organisation])
      end

      let(:forbidden_trust_publisher) { create(:publisher) }

      it "allows the jobseeker to hide themselves from the trust and its schools" do
        run_with_jobseeker(jobseeker) do
          visit jobseekers_profile_path
          click_on I18n.t("jobseekers.profiles.show.set_up_profile_visibility")
          choose "Yes", visible: false
          click_on I18n.t("buttons.save_and_continue")

          field = find_field("Name of school or trust")
          field.fill_in(with: forbidden_trust.name)
          click_on I18n.t("buttons.save_and_continue")

          expect(page).to have_content(I18n.t("jobseekers.profiles.hide_profile.schools.hidden_from_trust_and_schools"))
        end

        run_with_publisher(forbidden_trust_publisher) do
          visit publishers_jobseeker_profiles_path
          expect(page).not_to have_content(profile.full_name)

          visit publishers_jobseeker_profile_path(profile)
          expect(page).to have_content("Page not found")
        end

        run_with_publisher(forbidden_publisher) do
          visit publishers_jobseeker_profiles_path
          expect(page).not_to have_content(profile.full_name)

          visit publishers_jobseeker_profile_path(profile)
          expect(page).to have_content("Page not found")
        end

        run_with_publisher(permitted_publisher) do
          visit publishers_jobseeker_profiles_path
          expect(page).to have_content(profile.full_name)
        end
      end
    end

    context "if the forbidden organisation is within a trust" do
      let!(:forbidden_trust) do
        create(:trust,
               name: "Forbidden Trust",
               publishers: [forbidden_trust_publisher],
               schools: [forbidden_organisation])
      end

      let(:forbidden_trust_publisher) { create(:publisher) }

      before { login_as(jobseeker, scope: :jobseeker) }

      after { logout }

      it "asks whether to hide from the whole trust or just the specific school" do
        visit jobseekers_profile_path
        click_on I18n.t("jobseekers.profiles.show.set_up_profile_visibility")
        choose "Yes", visible: false
        click_on I18n.t("buttons.save_and_continue")

        field = find_field("Name of school or trust")
        field.fill_in(with: forbidden_organisation.name)
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content(I18n.t("jobseekers.profiles.hide_profile.choose_school_or_trust.page_title", trust_name: forbidden_trust.name))

        choose I18n.t("jobseekers.profiles.hide_profile.choose_school_or_trust.options.trust", trust_name: forbidden_trust.name), visible: false
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content(forbidden_trust.name)

        choose "Yes", visible: false
        click_on I18n.t("buttons.save_and_continue")

        field = find_field("Name of school or trust")
        field.fill_in(with: forbidden_organisation.name)
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content(I18n.t("jobseekers.profiles.hide_profile.choose_school_or_trust.page_title", trust_name: forbidden_trust.name))

        choose I18n.t("jobseekers.profiles.hide_profile.choose_school_or_trust.options.school", school_name: forbidden_organisation.name), visible: false
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content(forbidden_trust.name)
        expect(page).to have_content(forbidden_organisation.name)
      end
    end
  end

  describe "job preferences" do
    let(:profile) { create(:jobseeker_profile, :with_personal_details, jobseeker:) }

    before do
      login_as(jobseeker, scope: :jobseeker)
      visit jobseekers_profile_path
      allow(geocoding_stub).to receive_messages(uk_coordinates?: true, coordinates: Geocoder::DEFAULT_STUB_COORDINATES)
    end

    after { logout }

    it "allows the jobseeker to fill in their job preferences" do
      click_link("Add job preferences")
      expect(page).to have_current_path(jobseekers_job_preferences_step_path(:roles), ignore_query: true)
      expect(page).to have_css("h1", text: "What roles are you interested in?")
      expect(page).to have_css("h2", text: "Teaching")
      expect(page).to have_css("h2", text: "Support")

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_current_path(jobseekers_job_preferences_step_path(:roles), ignore_query: true)
      expect(page).to have_css("h2", text: "There is a problem")

      check "Head of year or phase"
      check "Assistant headteacher"
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_current_path(jobseekers_job_preferences_step_path(:phases), ignore_query: true)
      expect(page).to have_css("h3", text: "Job preferencesEducation phase")

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_current_path(jobseekers_job_preferences_step_path(:phases), ignore_query: true)
      expect(page).to have_css("h2", text: "There is a problem")

      check "Secondary"
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_current_path(jobseekers_job_preferences_step_path(:key_stages), ignore_query: true)
      expect(page).to have_css("h3", text: "Job preferencesKey stages")

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_current_path(jobseekers_job_preferences_step_path(:key_stages), ignore_query: true)
      expect(page).to have_css("h2", text: "There is a problem")

      check "Key stage 3"
      check "Key stage 4"
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_current_path(jobseekers_job_preferences_step_path(:subjects), ignore_query: true)
      expect(page).to have_css("h3", text: "Job preferencesSubjects (optional)")

      # Can move forward without selecting any subject
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_current_path(jobseekers_job_preferences_step_path(:working_patterns), ignore_query: true)
      expect(page).to have_css("h1", text: "Job preferencesWorking patterns")

      # Fill in the Subjects
      click_link "Back"
      expect(page).to have_current_path(jobseekers_job_preferences_step_path(:subjects), ignore_query: true)
      expect(page).to have_css("h3", text: "Job preferencesSubjects (optional)")

      check "Mathematics"
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_current_path(jobseekers_job_preferences_step_path(:working_patterns), ignore_query: true)
      expect(page).to have_css("h1", text: "Job preferencesWorking patterns")

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_current_path(jobseekers_job_preferences_step_path(:working_patterns), ignore_query: true)

      check "Full time"
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_current_path(jobseekers_job_preferences_step_path(:location), ignore_query: true)
      expect(page).to have_css("h1", text: "Job preferencesLocation")

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_current_path(jobseekers_job_preferences_step_path(:location), ignore_query: true)
      expect(page).to have_css("h2", text: "There is a problem")

      fill_in "Location", with: "London"
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_current_path(jobseekers_job_preferences_step_path(:location), ignore_query: true)
      expect(page).to have_css("h2", text: "There is a problem")

      choose "1 mile"
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_current_path(jobseekers_job_preferences_step_path(:locations), ignore_query: true)
      expect(page).to have_css("h1", text: "Job preferencesLocations")
      expect(page).to have_content("London (1 mile)")

      click_link "Change"
      expect(page).to have_css("h1", text: "Job preferencesLocation")
      expect(page).to have_field("Location", with: "London")
      expect(page).to have_checked_field("1 mile")

      choose "5 miles"
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_current_path(jobseekers_job_preferences_step_path(:locations), ignore_query: true)
      expect(page).to have_css("h1", text: "Job preferencesLocations")
      expect(page).to have_content("London (5 miles)")

      click_link "Delete"
      expect(page).to have_css("h1", text: "Delete locationConfirm that you want to delete London (5 miles)")
      click_on "Delete this location"

      expect(page).to have_current_path(jobseekers_job_preferences_step_path(:location), ignore_query: true)
      expect(page).to have_content("Location deleted")
      expect(page).to have_css("h1", text: "Job preferencesLocation")

      fill_in "Location", with: "San Francisco"
      choose "1 mile"
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_css("h2", text: "There is a problem")
      expect(page).to have_content("Enter a city, county or postcode in the UK")

      fill_in "Location", with: "London"
      choose "1 mile"
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_current_path(jobseekers_job_preferences_step_path(:locations), ignore_query: true)
      expect(page).to have_css("h1", text: "Job preferencesLocations")
      expect(page).to have_content("London (1 mile)")
      expect(page).to have_css("h2", text: "Do you want to add another location?")

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_css("h2", text: "There is a problem")

      choose "Yes"
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_current_path(jobseekers_job_preferences_step_path(:location), ignore_query: true)
      expect(page).to have_css("h1", text: "Job preferencesLocation")

      fill_in "Location", with: "Manchester"
      choose "10 miles"
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_current_path(jobseekers_job_preferences_step_path(:locations), ignore_query: true)
      expect(page).to have_css("h1", text: "Job preferencesLocations")
      expect(page).to have_content("London (1 mile)")
      expect(page).to have_content("Manchester (10 miles)")
      expect(page).to have_css("h2", text: "Do you want to add another location?")

      choose "No"
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_current_path(jobseekers_job_preferences_step_path(:review), ignore_query: true)
      expect(page).to have_css("h1", text: "Job preferences")
      expect(page).to have_css("dd", text: "Head of year or phase, Assistant headteacher")
      expect(page).to have_css("dd", text: "Secondary")
      expect(page).to have_css("dd", text: "Key stage 3 (ages 11 to 14), Key stage 4 (ages 14 to 16)")
      expect(page).to have_css("dd", text: "Mathematics")
      expect(page).to have_css("dd", text: "Full time")
      expect(page).to have_content("London (1 mile)")
      expect(page).to have_content("Manchester (10 miles)")

      click_on I18n.t("buttons.return_to_profile")
      expect(page).to have_current_path(jobseekers_profile_path, ignore_query: true)
      expect(page).to have_css("h1", text: "Your profile")
      expect(page).to have_css("dd", text: "Head of year or phase, Assistant headteacher")
      expect(page).to have_css("dd", text: "Secondary")
      expect(page).to have_css("dd", text: "Key stage 3 (ages 11 to 14), Key stage 4 (ages 14 to 16)")
      expect(page).to have_css("dd", text: "Mathematics")
      expect(page).to have_css("dd", text: "Full time")
      expect(page).to have_content("London (1 mile)")
      expect(page).to have_content("Manchester (10 miles)")
    end

    context "when a jobseeker enters non-teacher preferences" do
      it "changes the journey" do
        click_link("Add job preferences")
        expect(page).to have_current_path(jobseekers_job_preferences_step_path(:roles), ignore_query: true)
        expect(page).to have_css("h1", text: "What roles are you interested in?")
        expect(page).to have_css("h2", text: "Teaching")
        expect(page).to have_css("h2", text: "Support")

        # TODO: change when we have non-teaching roles
        check "IT support"
        click_on I18n.t("buttons.save_and_continue")
        expect(page).to have_current_path(jobseekers_job_preferences_step_path(:phases), ignore_query: true)
        expect(page).to have_css("h3", text: "Job preferencesEducation phase")

        check "Secondary"
        click_on I18n.t("buttons.save_and_continue")
        expect(page).to have_current_path(jobseekers_job_preferences_step_path(:key_stages), ignore_query: true)
        expect(page).to have_css("h3", text: "Job preferencesKey stages")

        check "I'm not looking for a teaching job"
        click_on I18n.t("buttons.save_and_continue")

        # Can move forward without selecting any subject
        click_on I18n.t("buttons.save_and_continue")
        expect(page).to have_current_path(jobseekers_job_preferences_step_path(:working_patterns), ignore_query: true)
        expect(page).to have_css("h1", text: "Job preferencesWorking patterns")

        check "Full time"
        click_on I18n.t("buttons.save_and_continue")
        expect(page).to have_current_path(jobseekers_job_preferences_step_path(:location), ignore_query: true)
        expect(page).to have_css("h1", text: "Job preferencesLocation")

        fill_in "Location", with: "Manchester"
        choose "10 miles"
        click_on I18n.t("buttons.save_and_continue")
        expect(page).to have_current_path(jobseekers_job_preferences_step_path(:locations), ignore_query: true)
        expect(page).to have_css("h1", text: "Job preferencesLocations")
        expect(page).to have_content("Manchester (10 miles)")
        expect(page).to have_css("h2", text: "Do you want to add another location?")

        choose "No"
        click_on I18n.t("buttons.save_and_continue")
        expect(page).to have_current_path(jobseekers_job_preferences_step_path(:review), ignore_query: true)
        expect(page).to have_css("h1", text: "Job preferences")
        expect(page).to have_css("dd", text: "IT support")
        expect(page).to have_css("dd", text: "Secondary")
        expect(page).to have_css("dd", text: "I'm not looking for a teaching job")
        expect(page).to have_css("dd", text: "Full time")
        expect(page).to have_css("dd", text: "Manchester (10 miles)")

        click_on I18n.t("buttons.return_to_profile")
        expect(page).to have_current_path(jobseekers_profile_path, ignore_query: true)
        expect(page).to have_css("h1", text: "Your profile")
        expect(page).to have_css("dd", text: "IT support")
        expect(page).to have_css("dd", text: "Secondary")
        expect(page).to have_css("dd", text: "I'm not looking for a teaching job")
        expect(page).to have_css("dd", text: "Full time")
        expect(page).to have_css("dd", text: "Manchester (10 miles)")
      end
    end
  end

  private

  def add_jobseeker_profile_employment
    click_link("Add roles")

    fill_in_current_role(form: "jobseekers_profile_employment_form")

    click_on I18n.t("buttons.save_and_continue")

    # wait for page load
    find(".govuk-summary-card")
  end

  def add_jobseeker_profile_employment_with_a_gap
    click_link("Add roles")

    fill_in I18n.t("helpers.label.jobseekers_profile_employment_form.organisation"), with: "Arsenal"
    fill_in I18n.t("helpers.label.jobseekers_profile_employment_form.job_title"), with: "Number 9"
    fill_in "jobseekers_profile_employment_form[started_on(1i)]", with: "1991"
    fill_in "jobseekers_profile_employment_form[started_on(2i)]", with: "09"
    fill_in "jobseekers_profile_employment_form[ended_on(1i)]", with: "2019"
    fill_in "jobseekers_profile_employment_form[ended_on(2i)]", with: "07"
    fill_in I18n.t("helpers.label.jobseekers_profile_employment_form.main_duties"), with: "Goals and that"
    fill_in I18n.t("helpers.label.jobseekers_profile_employment_form.reason_for_leaving"), with: "I hate it there"

    click_on I18n.t("buttons.save_and_continue")
  end
end
