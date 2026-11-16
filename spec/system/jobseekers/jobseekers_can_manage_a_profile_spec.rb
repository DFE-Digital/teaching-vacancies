require "rails_helper"

RSpec.describe "Jobseekers can manage their profile", :geocode do
  let(:jobseeker) { create(:jobseeker) }
  let(:bexleyheath) { %w[0.14606549011864176 51.457814649098104] }
  let(:organisation) do
    create(:school,
           publishers: [build(:publisher)],
           geopoint: RGeo::Geographic.spherical_factory(srid: 4326).point(*bexleyheath))
  end
  let(:publisher) { organisation.publishers.first }

  context "with a jobseeker" do
    before { login_as(jobseeker, scope: :jobseeker) }

    after { logout }

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
        fill_in "What is your teacher reference number?", with: "1234567"
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

    describe "work history" do
      describe "adding an employment history entry to a profile" do
        let(:profile) { jobseeker.jobseeker_profile }

        before do
          create(:jobseeker_profile, jobseeker:)
          visit jobseekers_profile_path
        end

        describe "errors" do
          before do
            click_link("Add a job or voluntary role")
          end

          it "raises errors for missing fields" do
            check "I currently work here"
            click_on I18n.t("buttons.save_and_continue")

            expect(page).to have_css("ul.govuk-list.govuk-error-summary__list")

            within "ul.govuk-list.govuk-error-summary__list" do
              expect(all("a").map { |l| [l.text, l[:href]] })
                .to contain_exactly(["Enter a school or other organisation", "#jobseekers-profile-employment-form-organisation-field-error"],
                                    ["Enter your job title", "#jobseekers-profile-employment-form-job-title-field-error"],
                                    ["Enter the date you started at this school or organisation", "#jobseekers-profile-employment-form-started-on-field-error"])
            end
          end
        end

        it "associates an 'employment' with their jobseeker profile" do
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
            end
          end

          it "asks user to account for any gaps in employment" do
            add_jobseeker_profile_employment
            click_link "Return to profile"
            add_jobseeker_profile_employment_with_a_gap
            click_link "Return to profile"

            expect(page).to have_content "You have a gap in your work history of almost 1 year"
            expect(page).to have_content "Add another job or explain this gap"
            click_link "explain this gap"

            click_button "Continue"

            expect(page).to have_selector(".govuk-error-summary__list", text: "Enter a reason for this gap")

            fill_in "jobseekers_break_form[reason_for_break]", with: "I was travelling"

            click_button "Continue"

            expect(page).to have_css(".govuk-inset-text", text: "Gap in work history")

            gap = Employment.find_by!(employment_type: "break")

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
            expect(page).to have_content "You have a gap in your work history of almost 1 year"
            expect(page).to have_content "Add another job or explain this gap"
          end
        end
      end

      describe "changing an existing employment history entry" do
        let(:profile) { create(:jobseeker_profile, jobseeker:) }
        let(:employment) { create(:profile_employment, jobseeker_profile: profile) }
        let(:new_employment) { build(:employment, organisation: "NASA", job_title: "Chief ET locator", reason_for_leaving: "Relocating") }

        before do
          visit edit_jobseekers_profile_work_history_path(employment)
        end

        it "successfully changes the employment record" do
          expect(page).to have_content("Your previous roles")

          fill_in I18n.t("helpers.label.jobseekers_profile_employment_form.organisation"), with: new_employment.organisation
          fill_in I18n.t("helpers.label.jobseekers_profile_employment_form.job_title"), with: new_employment.job_title

          click_on I18n.t("buttons.save_and_continue")
          expect(page).to have_current_path(review_jobseekers_profile_work_history_index_path, ignore_query: true)

          expect(profile.employments.count).to eq(1)
          expect(profile.employments.first).to have_attributes(organisation: new_employment.organisation,
                                                               job_title: new_employment.job_title)
        end
      end

      describe "deleting an employment history entry" do
        let!(:profile) { create(:jobseeker_profile, jobseeker:) }
        let!(:employment) { create(:profile_employment, jobseeker_profile_id: profile.id) }

        it "deletes the employment record" do
          visit review_jobseekers_profile_work_history_index_path

          within(".govuk-summary-card", match: :first) { click_link I18n.t("buttons.delete") }

          expect(profile.employments.any?).to be false
          expect(page).to have_current_path(review_jobseekers_profile_work_history_index_path, ignore_query: true)
        end
      end
    end
  end

  private

  def add_jobseeker_profile_employment
    click_link("Add a job or voluntary role")

    fill_in_current_role(form: "jobseekers_profile_employment_form")

    click_on I18n.t("buttons.save_and_continue")

    # wait for page load
    find(".govuk-summary-card")
  end

  def add_jobseeker_profile_employment_with_a_gap
    click_link("Add a job or voluntary role")

    fill_in I18n.t("helpers.label.jobseekers_profile_employment_form.organisation"), with: "Arsenal"
    fill_in I18n.t("helpers.label.jobseekers_profile_employment_form.job_title"), with: "Number 9"
    fill_in "jobseekers_profile_employment_form[started_on(1i)]", with: "1991"
    fill_in "jobseekers_profile_employment_form[started_on(2i)]", with: "09"
    fill_in "jobseekers_profile_employment_form[ended_on(1i)]", with: "2019"
    fill_in "jobseekers_profile_employment_form[ended_on(2i)]", with: "07"

    click_on I18n.t("buttons.save_and_continue")
  end
end
