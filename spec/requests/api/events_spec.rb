require "rails_helper"

RSpec.describe "Events API" do
  describe "#create" do
    let(:event_type) { :tracked_link_clicked }
    let(:event_data) { { link_type: "foo" } }

    let(:request) do
      post api_events_path,
           params: { event: { type: event_type, data: event_data } },
           headers: { "Referer" => "http://example.com/foo?bar" }
    end

    it "triggers an event" do
      expect { request }.to have_triggered_event(:tracked_link_clicked)
        .with_data(link_type: "foo")
    end

    it "requires a CSRF token", with_csrf_protection: true do
      expect { request }.not_to have_triggered_event(:invalid_event)
      expect(response).to have_http_status(:bad_request)
    end

    context "when given an invalid event type" do
      let(:event_type) { :invalid_event }

      it "does not accept the event" do
        expect { request }.not_to have_triggered_event(:invalid_event)
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
