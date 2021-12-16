require "rails_helper"

RSpec.describe EventContext do
  subject { described_class.new }

  describe "#trigger_event" do
    let(:event_double) { double(Event) }
    let(:event_type) { :entity_updated }

    before { allow(Event).to receive(:new).and_return(event_double) }

    context "when entity is included in analytics.yml" do
      let(:event_data) { { "table_name" => "vacancies", job_title: "Job title" } }

      it "invokes trigger method on event" do
        expect(event_double).to receive(:trigger).with(event_type, event_data)

        subject.trigger_event(event_type, event_data)
      end
    end

    context "when entity is not included in analytics.yml" do
      let(:event_data) { { "table_name" => "location_polygons", name: "London" } }

      it "does not invoke trigger method on event" do
        expect(event_double).not_to receive(:trigger).with(event_type, event_data)

        subject.trigger_event(event_type, event_data)
      end
    end
  end
end
