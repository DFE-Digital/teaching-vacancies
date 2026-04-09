require "rails_helper"

RSpec.describe "Jobseekers can manage their personal details" do
  let(:jobseeker) { create(:jobseeker) }
  let(:organisation) do
    create(:school,
           publishers: [build(:publisher)])
  end
  let(:publisher) { organisation.publishers.first }

  before { login_as(jobseeker, scope: :jobseeker) }

  after { logout }

  describe "changing personal details" do
    context "when filling in the profile for the first time" do
      let(:first_name) { Faker::Fantasy::Tolkien.character }
      let(:last_name) { Faker::Name.last_name }

      before do
        visit jobseekers_profile_path
        click_on "Your profile"
        click_link("Add personal details")
      end

      context "with an error" do
        it "displays an error" do
          expect(page).to have_content("Do you need Skilled Worker visa sponsorship?")
          click_on I18n.t("buttons.save_and_continue")
          expect(page).to have_content("There is a problem")
        end
      end

      it "passes a11y", :a11y do
        expect(page).to have_content("Do you need Skilled Worker visa sponsorship?")
        expect(page).to be_axe_clean
      end

      it "allows the jobseeker to fill in their personal details" do
        expect(page).to have_content("Do you need Skilled Worker visa sponsorship?")
        fill_in "personal_details[first_name]", with: first_name
        fill_in "personal_details[last_name]", with: last_name
        choose "Yes"
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content("#{first_name} #{last_name}")
        expect(page).to have_content("Yes, I will need to apply for a visa giving me the right to work in the UK")
      end
    end

    context "when editing a profile that has already been completed" do
      let(:profile) { create(:jobseeker_profile, :with_personal_details, jobseeker:) }

      let(:new_first_name) { "Samwise" }
      let(:new_last_name) { "Gamgee" }

      before do
        profile.personal_details.update!(
          first_name: "Frodo",
          last_name: "Baggins",
          has_right_to_work_in_uk: right_to_work,
        )

        visit jobseekers_profile_path
      end

      context "with a work completed step" do
        let(:right_to_work) { true }

        it "allows the jobseeker to edit their profile" do
          row = page.find(".govuk-summary-list__key", text: "Name").find(:xpath, "..")

          within(row) do
            click_link "Change"
          end

          fill_in "personal_details[first_name]", with: new_first_name
          fill_in "personal_details[last_name]", with: new_last_name
          click_on I18n.t("buttons.save_and_continue")

          expect(page).to have_content("#{new_first_name} #{new_last_name}")
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
end
