require "rails_helper"

RSpec.describe BaseForm, type: :model do
  describe "#send_errors_to_big_query" do
    let(:form) { Publishers::JobListing::JobDetailsForm.new }
    let(:event) { instance_double(Event) }
    let(:event_data) { { form_name: "publishers/job_listing/job_details_form", job_title: :blank, contract_type: :inclusion } }

    before do
      expect(Event).to receive(:new).and_return(event)
      expect(event).to receive(:trigger).with(:form_validation_failed, event_data)
    end

    it "sends errors to BigQuery" do
      form.validate
    end
  end
end
