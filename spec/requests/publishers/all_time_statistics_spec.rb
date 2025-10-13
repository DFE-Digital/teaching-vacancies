require "rails_helper"

RSpec.describe "Publisher all-time statistics" do
  let(:school) { create(:school) }

  let(:publisher) { create(:publisher, publisher_preferences: build_list(:publisher_preference, 1, organisation: school)) }

  # rubocop:disable RSpec/AnyInstance
  before do
    allow_any_instance_of(Publishers::BaseController).to receive(:current_organisation).and_return(school)
    sign_in(publisher, scope: :publisher)
  end
  # rubocop:enable RSpec/AnyInstance

  after { sign_out(publisher) }

  describe "GET #index" do
    before do
      create(:vacancy, publisher: publisher, organisations: [school], publish_on: 1.year.ago,
                       vacancy_analytics: build(:vacancy_analytics,
                                                referrer_counts: { "google" => 6, "magic" => 8 }))
      create(:vacancy, publisher: publisher, organisations: [school],
                       vacancy_analytics: build(:vacancy_analytics,
                                                referrer_counts: { "google" => 6, "magic" => 8 }))
      create(:vacancy, publisher: publisher, organisations: [school],
                       vacancy_analytics: build(:vacancy_analytics,
                                                referrer_counts: { "google" => 4, "yahoo" => 12, "linkedin" => 13 }))
      create(:vacancy, publisher: publisher, organisations: [school],
                       vacancy_analytics: build(:vacancy_analytics,
                                                referrer_counts: { "google" => 14, "indeed" => 5, "linkedin" => 15 }))
    end

    it "includes old data in its calculations" do
      get(publishers_all_time_statistics_path(format: :csv))

      expect(response.body.split("\n")).to eq(["Google,Linkedin,Magic,Yahoo,Indeed", "30,28,16,12,5"])
    end
  end

  describe "GET #equal_opportunities" do
    before do
      create(:vacancy, publisher: publisher, organisations: [school], publish_on: 1.year.ago,
                       equal_opportunities_report: build(:equal_opportunities_report,
                                                         age_twenty_five_to_twenty_nine: 5,
                                                         age_prefer_not_to_say: 10,
                                                         age_thirty_to_thirty_nine: 12,
                                                         age_under_twenty_five: 3,
                                                         age_forty_to_forty_nine: 11,
                                                         age_fifty_to_fifty_nine: 6,
                                                         age_sixty_and_over: 8))
      create(:vacancy, publisher: publisher, organisations: [school],  publish_on: 1.year.ago,
                       equal_opportunities_report: build(:equal_opportunities_report,
                                                         disability_no: 34,
                                                         disability_prefer_not_to_say: 21,
                                                         disability_yes: 18))
      create(:vacancy, publisher: publisher, organisations: [school],  publish_on: 1.year.ago,
                       equal_opportunities_report: build(:equal_opportunities_report,
                                                         ethnicity_asian: 1,
                                                         ethnicity_black: 4, ethnicity_mixed: 9,
                                                         ethnicity_other: 16, ethnicity_prefer_not_to_say: 25, ethnicity_white: 36))
      create(:vacancy, publisher: publisher, organisations: [school],  publish_on: 1.year.ago,
                       equal_opportunities_report: build(:equal_opportunities_report,
                                                         gender_man: 11,
                                                         gender_other: 1, gender_prefer_not_to_say: 3, gender_woman: 7))
      create(:vacancy, publisher: publisher, organisations: [school],  publish_on: 1.year.ago,
                       equal_opportunities_report: build(:equal_opportunities_report,
                                                         orientation_bisexual: 8,
                                                         orientation_gay_or_lesbian: 25, orientation_heterosexual: 16,
                                                         orientation_other: 9, orientation_prefer_not_to_say: 64))
      create(:vacancy, publisher: publisher, organisations: [school],  publish_on: 1.year.ago,
                       equal_opportunities_report: build(:equal_opportunities_report,
                                                         religion_buddhist: 87,
                                                         religion_christian: 37, religion_hindu: 46,
                                                         religion_jewish: 5, religion_muslim: 144, religion_none: 77,
                                                         religion_other: 66, religion_prefer_not_to_say: 14, religion_sikh: 12))
    end

    it "includes old data in its calculations" do
      allow(CSV).to receive(:generate).and_call_original

      get(equal_opportunities_publishers_all_time_statistics_path(format: :csv))

      expect(CSV).to have_received(:generate).with(headers: false)

      expect(response.body.split("\n"))
        .to eq(
          ["age_group,under_twenty_five,twenty_five_to_twenty_nine,thirty_to_thirty_nine,forty_to_forty_nine,fifty_to_fifty_nine,sixty_and_over,prefer_not_to_say",
           "age_group_count,3,5,12,11,6,8,10",
           "disability_status,no,prefer_not_to_say,yes",
           "disability_status_count,34,21,18",
           "ethnicity,white,prefer_not_to_say,other,mixed,black,asian",
           "ethnicity_count,36,25,16,9,4,1",
           "gender_identity,man,woman,other,prefer_not_to_say",
           "gender_identity_count,11,7,6,3",
           "sexual_orientation,prefer_not_to_say,gay_or_lesbian,heterosexual,other,bisexual",
           "sexual_orientation_count,64,25,16,14,8",
           "faith_group,muslim,buddhist,none,other,hindu,christian,prefer_not_to_say,sikh,jewish",
           "faith_group_count,144,87,77,71,46,37,14,12,5"],
        )
      expect(response.media_type).to eq("text/csv")
      expect(response.headers["Content-Disposition"]).to include("equal_opportunities.csv")
    end
  end
end
