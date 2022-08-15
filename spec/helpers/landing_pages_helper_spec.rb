require "rails_helper"

RSpec.describe LandingPagesHelper do
  describe "#linked_working_patterns" do
    before { allow_any_instance_of(LandingPagesHelper).to receive(:landing_page_link_or_text).and_return(full_time_landing_page_link) }

    subject { linked_working_patterns(vacancy) }
    let(:full_time_landing_page_link) { "<a href=\"/full-time-school-jobs\">Full time</a>" }
    let(:vacancy) { double(Vacancy, working_patterns: working_patterns, working_patterns_details: working_patterns_details) }

    # TODO Working Patterns: Remove this context once all vacancies with legacy working patterns & working_pattern_details have expired
    context "when the vacancy was created before the addition of full_time_details and part_time_details" do
      before do
        allow(vacancy).to receive(:full_time_details?).and_return(false)
        allow(vacancy).to receive(:part_time_details?).and_return(false)
      end

      let(:working_patterns) { %w[full_time] }
      let(:working_patterns_details) { "Some details" }

      it "returns a list with each item containing landing page links for each working pattern" do
        expect(subject).to include("<li>#{full_time_landing_page_link}</li>")
      end

      it "returns a list item containing the working_patterns_details" do
        expect(subject).to include("<span>#{working_patterns_details}</span>")
      end
    end

    context "when the vacancy was created after the addition of full_time_details and part_time_details" do
      let(:vacancy) { build(:vacancy, working_patterns: %w[full_time]) }

      it "returns a list containing each working pattern and its details" do
        expect(subject).to include("<li>#{full_time_landing_page_link} - #{vacancy.full_time_details}</li>")
      end
    end
  end
end