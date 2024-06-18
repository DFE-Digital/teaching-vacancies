require "rails_helper"
require "dfe/analytics/rspec/matchers"

RSpec.describe EqualOpportunitiesReport do
  subject { create(:equal_opportunities_report) }

  it { is_expected.to belong_to(:vacancy) }

  describe "#trigger_event" do
    let(:equal_opportunities_report_data_example) { { "table_name" => "equal_opportunities_reports", "total_submissions" => 1 } }

    it "triggers an event with the correct data" do
      subject.trigger_event
      expect(:equal_opportunities_report_published).to have_been_enqueued_as_analytics_events
    end
  end
end
