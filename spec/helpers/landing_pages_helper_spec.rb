require "rails_helper"

RSpec.describe LandingPagesHelper do
  describe "#linked_working_patterns" do
    before { allow_any_instance_of(LandingPagesHelper).to receive(:landing_page_link_or_text).and_return(full_time_landing_page_link) }

    subject { linked_working_patterns(vacancy) }
    let(:full_time_landing_page_link) { "<a href=\"/full-time-school-jobs\">Full time</a>" }
    let(:vacancy) { double(Vacancy, working_patterns: working_patterns, working_patterns_details: working_patterns_details) }
    let(:working_patterns) { %w[full_time] }
    let(:working_patterns_details) { "Some details" }

    it "returns a list with each item containing landing page links for each working pattern" do
      expect(subject).to include("<li>#{full_time_landing_page_link}</li>")
    end

    it "returns a list item containing the working_patterns_details" do
      expect(subject).to include("<span>#{working_patterns_details}</span>")
    end
  end
end
