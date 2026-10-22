require "rails_helper"

RSpec.describe "publishers/jobseeker_profiles/index" do
  include Pagy::Backend

  before do
    pagy, profiles = pagy_array(jobseeker_profiles)
    assign(:jobseeker_profiles, profiles)
    assign(:pagy, pagy)
    current_organisation = build_stubbed(:school)
    assign(:form, Publishers::JobseekerProfileSearchForm.new(current_organisation: current_organisation))
    assign(:jobseeker_profile_search, Search::JobseekerProfileSearch.new(current_organisation: current_organisation, filters: {}))
    allow(view).to receive_messages(current_organisation: current_organisation)
    render
  end

  context "when the profile does not exist" do
    let(:jobseeker_profiles) { [] }

    it "does not appear in search results" do
      expect(rendered).to have_no_css(".search-results__item")
    end
  end

  context "with an active profile" do
    let(:profile) do
      build_stubbed(:jobseeker_profile, :with_personal_details,
                    :with_qualifications,
                    employments: build_list(:profile_employment, 1, :current_role),
                    active: true)
    end

    let(:jobseeker_profiles) { [profile] }

    it "displays user name" do
      expect(rendered).to have_content(profile.full_name)
    end
  end
end
