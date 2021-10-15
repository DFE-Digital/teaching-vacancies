require "rails_helper"

RSpec.describe EqualOpportunitiesReport do
  subject { create(:equal_opportunities_report) }
  it { is_expected.to belong_to(:vacancy) }

  describe "#trigger_event" do
    let(:equal_opportunities_report_data_example) { { "table_name" => "equal_opportunities_reports", "total_submissions" => 1 } }

    it "triggers an event with the correct data" do
      expect { subject.trigger_event }.to have_triggered_event(:equal_opportunities_report_published).with_data(equal_opportunities_report_data_example)
    end
  end
end
