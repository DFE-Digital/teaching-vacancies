# frozen_string_literal: true

require "rails_helper"

RSpec.describe Referees::CanShareReferenceForm do
  context "with no data" do
    let(:form) { described_class.new }

    it "has correct errors" do
      expect(form).not_to be_valid
      expect(form.errors.messages).to eq({ is_reference_sharable: ["Select yes if the reference is sharable with the candidate upon request"] })
    end
  end
end
