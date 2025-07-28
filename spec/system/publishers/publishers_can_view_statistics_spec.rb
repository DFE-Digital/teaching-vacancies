require "rails_helper"

RSpec.describe "Publishers can view statistics" do
  let(:school) { create(:school) }

  let(:publisher) { create(:publisher, publisher_preferences: build_list(:publisher_preference, 1, organisation: school)) }

  before do
    create(:vacancy, organisations: [school], publisher: publisher)
    login_publisher(publisher: publisher, organisation: school)
  end

  after { logout }

  describe "vacancy stats page" do
    before do
      # This old vacancy shouldn't show up in the visible stats as its too old
      create(:vacancy, publisher: publisher, organisations: [school], publish_on: 1.year.ago, expiry_date: 1.year.ago,
                       vacancy_analytics: build(:vacancy_analytics,
                                                referrer_counts: { "google.com" => 600, "magic.co.uk" => 800 }))
      create(:vacancy, publisher: publisher, organisations: [school],
                       vacancy_analytics: build(:vacancy_analytics,
                                                referrer_counts: { "google.com" => 6, "magic.co.uk" => 8 }))
      create(:vacancy, publisher: publisher, organisations: [school],
                       vacancy_analytics: build(:vacancy_analytics,
                                                referrer_counts: { "google.com" => 4, "yahoo.co.uk" => 12, "linkedin.com" => 13 }))
      create(:vacancy, publisher: publisher, organisations: [school],
                       vacancy_analytics: build(:vacancy_analytics,
                                                referrer_counts: { "google.com" => 14, "indeed.co.uk" => 5, "linkedin.com" => 17 }))
    end

    it "adds up the stats for each referrer" do
      visit publishers_current_year_statistics_path

      find_by_id("accessible").click

      within("#analytics") do
        expect(all(".govuk-summary-list__row").map(&:text)).to eq(%w[Linkedin.com30 Google.com24 Yahoo.co.uk12 Magic.co.uk8 Indeed.co.uk5])
      end
    end
  end

  describe "equal opportunities page" do
    before do
      create(:vacancy, publisher: publisher, organisations: [school],
                       equal_opportunities_report: build(:equal_opportunities_report,
                                                         age_twenty_five_to_twenty_nine: 5,
                                                         age_prefer_not_to_say: 10,
                                                         age_thirty_to_thirty_nine: 12,
                                                         age_under_twenty_five: 3,
                                                         age_forty_to_forty_nine: 11,
                                                         age_fifty_to_fifty_nine: 6,
                                                         age_sixty_and_over: 8))
    end

    it "displays age groups with youngest at the top" do
      visit equal_opportunities_publishers_current_year_statistics_path

      within("#age_counts") do
        find(".accessible-button").click

        expect(all(".govuk-summary-list__row").map(&:text))
          .to eq(["Under 253", "25 to 295", "30 to 3912", "40 to 4911", "50 to 596", "60 and over8", "Prefer not to say10"])
      end
    end
  end
end
