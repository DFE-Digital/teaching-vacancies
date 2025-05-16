# frozen_string_literal: true

require "rails_helper"

RSpec.describe Referees::RefereeDetailsForm do
  context "with no data" do
    let(:form) { described_class.new }

    it "has correct errors" do
      expect(form).not_to be_valid
      expect(form.errors.messages)
        .to eq({
          email: ["Enter your email address"],
          job_title: ["Enter your job title"],
          name: ["Enter your name"],
          organisation: ["Enter the name of your organisation"],
          phone_number: ["Enter your phone number"],
        })
    end
  end

  context "with an invalid email address" do
    let(:form) do
      described_class.new(attributes_for(:job_reference).slice(*Referees::RefereeDetailsForm::FIELDS)
                                                                   .merge(email: "fred@example.nowhere"))
    end

    it "has correct errors" do
      expect(form).not_to be_valid
      expect(form.errors.messages)
        .to eq({
          email: ["Enter a valid email address in the correct format, like name@example.com"],
        })
    end
  end
end
