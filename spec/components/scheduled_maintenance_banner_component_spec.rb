require "rails_helper"

RSpec.describe ScheduledMaintenanceBannerComponent, type: :component do
  describe "#render" do
    RSpec.shared_examples "does not render" do
      it "does not render" do
        expect(component.render?).to eq(false)
      end
    end

    subject(:component) { described_class.new(date:, start_time:, end_time:) }

    let(:app_role) { "production" }
    let(:date) { "5th October 2023" }
    let(:start_time) { "8:00" }
    let(:end_time) { "11:00" }

    before do
      allow(Rails.configuration).to receive(:app_role).and_return(ActiveSupport::StringInquirer.new(app_role))
    end

    context "when the maintenance date is not present" do
      let(:date) { nil }

      it_behaves_like "does not render"
    end

    context "when the maintenance start time is not present" do
      let(:start_time) { nil }

      it_behaves_like "does not render"
    end

    context "when the maintenance end time is not present" do
      let(:end_time) { nil }

      it_behaves_like "does not render"
    end

    context "when app_role is unknown" do
      let(:app_role) { "unknown" }

      it_behaves_like "does not render"
    end

    context "when app_role is anything else" do
      let(:app_role) { "wow" }

      it_behaves_like "does not render"
    end

    context "when app_role is production" do
      let(:app_role) { "production" }

      it "does render" do
        expect(component.render?).to eq(true)
      end
    end
  end
end
