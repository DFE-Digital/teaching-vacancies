require "rails_helper"
require "dfe/analytics/rspec/matchers"

RSpec.describe "dfe analytics integration" do
  context "events being sent from creating new entities" do
    it "sends a DFE Analytics web request event" do
      expect {  create(:vacancy) }.to have_sent_analytics_event_types(:create_entity)
    end
  end

  context "events being sent from updating entities" do
    let(:vacancy) { create(:vacancy) }

    it "sends a DFE Analytics web request event" do
      expect { vacancy.update!(job_title: "test") }.to have_sent_analytics_event_types(:update_entity)
    end
  end

  context "events being sent from deleting entities" do
    let(:vacancy) { create(:vacancy) }

    it "sends a DFE Analytics web request event" do
      expect { vacancy.destroy! }.to have_sent_analytics_event_types(:delete_entity)
    end
  end

  context "events being sent for Web requests" do
    it "sends a DFE Analytics web request event" do
      expect { get "/api/test" }.to have_sent_analytics_event_types(:web_request)
    end

    it "does not send health check requests to DFE Analytics" do
      expect { get "/check" }.not_to have_sent_analytics_event_types(:web_request)
    end
  end
end
