require "rails_helper"

RSpec.describe Shared::EnvironmentBannerComponent, type: :component do
  describe "#render" do
    before do
      allow(Rails.configuration).to receive(:app_role).and_return(ActiveSupport::StringInquirer.new(app_role))
    end

    context "when app_role is production" do
      let(:app_role) { "production" }

      it "does not render" do
        expect(subject.render?).to eq(false)
      end
    end

    context "when app_role is unknown" do
      let(:app_role) { "unknown" }

      it "does not render" do
        expect(subject.render?).to eq(false)
      end
    end

    context "when app_role is anything else" do
      let(:app_role) { "wow" }

      it "renders" do
        expect(subject.render?).to eq(true)
      end
    end
  end
end
