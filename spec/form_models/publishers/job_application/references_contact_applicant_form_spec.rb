# frozen_string_literal: true

require "rails_helper"

module Publishers
  module JobApplication
    RSpec.describe ReferencesContactApplicantForm do
      context "with an empty form" do
        let(:form) { described_class.new }

        it "produces correct errors" do
          expect(form).not_to be_valid
          expect(form.errors.messages).to eq({ contact_applicants: ["Select yes if you would like the service to email candidates that you are collecting references."] })
        end
      end

      context "with a full form" do
        let(:form) { described_class.new(contact_applicants: true) }

        it "is valid" do
          expect(form).to be_valid
        end
      end
    end
  end
end
