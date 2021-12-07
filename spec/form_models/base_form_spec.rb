require "rails_helper"

class FakeFormForBaseFormSpec < BaseForm
  attr_accessor :some_field

  validates :some_field, presence: true
end

RSpec.describe FakeFormForBaseFormSpec, type: :model do
  describe "#send_errors_to_big_query" do
    it "sends errors to BigQuery" do
      expect { subject.validate }
        .to have_triggered_event(:form_validation_failed)
        .with_data(form_name: "fake_form_for_base_form_spec", some_field: "blank")
    end
  end
end
