require "rails_helper"

RSpec.describe "Publishers can view statistics" do
  let(:school) { create(:school) }

  let(:publisher) { create(:publisher) }

  before do
    # travel_to Time.zone.local(2025, 1, 6, 12, 0, 0)
    create(:vacancy, publisher: publisher)
    login_publisher(publisher: publisher, organisation: school)
  end

  after { logout }

  describe "vacancy stats page" do
    before do
      # This old vacancy shouldn't show up in the visible stats as its too old
      create(:vacancy, publisher: publisher, publish_on: 1.year.ago,
                       vacancy_analytics: build(:vacancy_analytics,
                                                referrer_counts: { "Google" => 6, "Magic" => 8 }))
      create(:vacancy, publisher: publisher,
                       vacancy_analytics: build(:vacancy_analytics,
                                                referrer_counts: { "Google" => 6, "Magic" => 8 }))
      create(:vacancy, publisher: publisher,
                       vacancy_analytics: build(:vacancy_analytics,
                                                referrer_counts: { "Google" => 4, "Yahoo" => 12, "LinkedIn" => 13 }))
      create(:vacancy, publisher: publisher,
                       vacancy_analytics: build(:vacancy_analytics,
                                                referrer_counts: { "Google" => 14, "Indeed" => 5, "LinkedIn" => 17 }))
    end

    it "adds up the stats for each referrer", :js do
      visit publishers_statistics_path

      find_by_id("accessible").click

      within("#analytics") do
        within(".govuk-summary-list__row:nth-child(1)") do
          expect(page).to have_content("LinkedIn")
          expect(page).to have_content("30")
        end
        within(".govuk-summary-list__row:nth-child(2)") do
          expect(page).to have_content("Google")
          expect(page).to have_content("24")
        end
      end
    end
  end

  describe "equal opportunities page" do
    before do
      create(:vacancy, publisher: publisher,
                       equal_opportunities_report: build(:equal_opportunities_report,
                                                         age_twenty_five_to_twenty_nine: 5,
                                                         age_prefer_not_to_say: 10,
                                                         age_thirty_to_thirty_nine: 12,
                                                         age_under_twenty_five: 3,
                                                         age_forty_to_forty_nine: 11,
                                                         age_fifty_to_fifty_nine: 6,
                                                         age_sixty_and_over: 8))
      create(:vacancy, publisher: publisher,
                       equal_opportunities_report: build(:equal_opportunities_report,
                                                         disability_no: 34,
                                                         disability_prefer_not_to_say: 21,
                                                         disability_yes: 18))
      create(:vacancy, publisher: publisher,
                       equal_opportunities_report: build(:equal_opportunities_report,
                                                         ethnicity_asian: 1,
                                                         ethnicity_black: 4, ethnicity_mixed: 9, ethnicity_other: 16, ethnicity_prefer_not_to_say: 25, ethnicity_white: 36))
      create(:vacancy, publisher: publisher,
                       equal_opportunities_report: build(:equal_opportunities_report,
                                                         gender_man: 11,
                                                         gender_other: 1, gender_prefer_not_to_say: 3, gender_woman: 7))
      create(:vacancy, publisher: publisher,
                       equal_opportunities_report: build(:equal_opportunities_report,
                                                         orientation_bisexual: 8,
                                                         orientation_gay_or_lesbian: 25, orientation_heterosexual: 16,
                                                         orientation_other: 9, orientation_prefer_not_to_say: 64))
      create(:vacancy, publisher: publisher,
                       equal_opportunities_report: build(:equal_opportunities_report,
                                                         religion_buddhist: 87,
                                                         religion_christian: 37, religion_hindu: 46,
                                                         religion_jewish: 5, religion_muslim: 144, religion_none: 77,
                                                         religion_other: 66, religion_prefer_not_to_say: 12, religion_sikh: 12))
    end

    it "displays age groups with youngest at the top", :js do
      visit equal_opportunities_publishers_statistics_path

      within("#age_counts") do
        find(".accessible-button").click

        within(".govuk-summary-list__row:nth-child(1)") do
          expect(page).to have_content("Under 25")
          expect(page).to have_content("3")
        end
        within(".govuk-summary-list__row:nth-child(2)") do
          expect(page).to have_content("25 to 29")
          expect(page).to have_content("5")
        end
      end
    end
  end
end
