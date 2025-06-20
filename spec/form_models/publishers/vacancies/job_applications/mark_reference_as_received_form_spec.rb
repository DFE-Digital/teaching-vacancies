# frozen_string_literal: true

require "rails_helper"

module Publishers
  module Vacancies
    module JobApplications
      RSpec.describe MarkReferenceAsReceivedForm do
        context "with no data" do
          let(:form) { described_class.new }

          it "has correct errors" do
            expect(form).not_to be_valid
            expect(form.errors.messages).to eq({ reference_satisfactory: ["Select yes if the reference received is satisfactory"] })
          end
        end

        context "with correct data" do
          let(:form) { described_class.new(reference_satisfactory: "true") }

          it "is valid" do
            expect(form).to be_valid
          end
        end
      end
    end
  end
end
