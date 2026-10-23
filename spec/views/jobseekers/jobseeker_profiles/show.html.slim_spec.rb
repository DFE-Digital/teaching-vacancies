require "rails_helper"

RSpec.describe "jobseekers/profiles/show" do
  before do
    assign(:profile, profile)
    assign(:sections, [])
    render
  end

  context "when profile is inactive" do
    let(:profile) do
      build_stubbed(:jobseeker_profile, :with_personal_details,
                    :with_qualifications,
                    employments: build_list(:profile_employment, 1, :current_role),
                    active: false)
    end

    it "is in toggle on state" do
      expect(rendered).to have_content(I18n.t("jobseekers.profiles.show.preview_and_turn_on_profile"))
      expect(rendered).to have_no_css(".govuk-tag", text: I18n.t("jobseekers.profiles.show.active"))
    end
  end

  context "when profile is active" do
    let(:profile) do
      build_stubbed(:jobseeker_profile, :with_personal_details,
                    :with_qualifications,
                    employments: build_list(:profile_employment, 1, :current_role),
                    active: true)
    end

    it "is in toggle off state" do
      expect(rendered).to have_link(I18n.t("jobseekers.profiles.show.turn_off_profile"))
    end
  end
end
