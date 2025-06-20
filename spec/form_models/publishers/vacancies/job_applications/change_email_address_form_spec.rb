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

        context "with valid email" do
          let(:form) { described_class.new(email: Faker::Internet.email(domain: TEST_EMAIL_DOMAIN)) }

          it "is valid" do
            expect(form).to be_valid
          end
        end
      end
    end
  end
end
