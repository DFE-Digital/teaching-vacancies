require "rails_helper"

RSpec.describe EqualOpportunitiesReport do
  it { is_expected.to belong_to(:vacancy) }

  describe "#trigger_event" do
    it "triggers an event of the correct type" do
      expect { described_class.new.trigger_event }.to have_triggered_event(:equal_opportunities_report_published).with_data({ table_name: "equal_opportunities_reports" })
    end
  end
end
