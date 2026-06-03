require "rails_helper"
RSpec.describe LandingPagesHelper do
  describe "#landing_page_fe_subjects_list" do
    it "returns FE_SUBJECTS_LIST" do
      expect(helper.landing_page_fe_subjects_list).to eq(LandingPagesHelper::FE_SUBJECTS_LIST)
    end
  end

  describe "landing_page_tallier" do
    let(:subject_list) { { Science: 1, Mathematics: 2, Physics: 1, ICT: 2, Computing: 1 } }

    it "returns the total count for the subject and its child subjects" do
      expect(helper.landing_page_tallier(subject_list)).to eq({ "art-design-technology-teacher-jobs" => [0, {}],
                                                                "dance-drama-music-teacher-jobs" => [0, {}],
                                                                "economics-business-studies-teacher-jobs" => [0, {}],
                                                                "english-media-studies-teacher-jobs" => [0, {}],
                                                                "food-technology-teacher-jobs" => [0, {}],
                                                                "geography-teacher-jobs" => [0, {}],
                                                                "health-relationships-social-care-teacher-jobs" => [0, {}],
                                                                "history-teacher-jobs" => [0, {}],
                                                                "ict-computer-science-teacher-jobs" => [3, {}],
                                                                "maths-teacher-jobs" => [2, {}],
                                                                "mfl-teacher-jobs" => [0, { "classics-latin-teacher-jobs" => 0, "french-teacher-jobs" => 0, "german-teacher-jobs" => 0, "mandarin-teacher-jobs" => 0, "spanish-teacher-jobs" => 0 }],
                                                                "physical-education-teacher-jobs" => [0, {}],
                                                                "politics-humanities-social-sciences-teacher-jobs" => [0, {}],
                                                                "psychology-philosophy-sociology-re-teacher-jobs" => [0, {}],
                                                                "science-teacher-jobs" => [1, { "biology-teacher-jobs" => 0, "chemistry-teacher-jobs" => 0, "physics-teacher-jobs" => 1 }] })
    end
  end
end
