# frozen_string_literal: true

require "rails_helper"

module Publishers
  module Vacancies
    module JobApplications
      RSpec.describe ChangeEmailAddressForm do
        context "with invalid email" do
          let(:form) { described_class.new(email: "invalid") }

          it "has correct errors" do
            expect(form).not_to be_valid
            expect(form.errors.messages).to eq({ email: ["Enter a valid email address"] })
          end
        end
      end
    end
  end
end
