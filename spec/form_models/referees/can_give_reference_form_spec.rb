# frozen_string_literal: true

require "rails_helper"

module Referees
  RSpec.describe CanGiveReferenceForm do
    context "with no data" do
      let(:form) { described_class.new }

      it "has correct errors" do
        expect(form).not_to be_valid
        expect(form.errors.messages).to eq({ can_give_reference: ["Select yes if you can give the candidate a reference"] })
      end
    end
  end
end
