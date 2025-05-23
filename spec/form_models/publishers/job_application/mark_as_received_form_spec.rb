# frozen_string_literal: true

require "rails_helper"

module Publishers
  module JobApplication
    RSpec.describe MarkAsReceivedForm do
      context "with no data" do
        let(:form) { described_class.new }

        it "has correct errors" do
          expect(form).not_to be_valid
          expect(form.errors.messages).to eq({ reference_satisfactory: ["Select yes if the reference received is satisfactory"] })
        end
      end
    end
  end
end
