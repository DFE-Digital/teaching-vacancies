require "rails_helper"

RSpec.describe Jobseekers::JobApplication::PersonalDetailsForm, type: :model do
  subject { described_class.new(params) }

  describe "validations" do
    describe "#first_name" do
      context "when a first_name has not been provided" do
        let(:params) { {} }

        it "is invalid" do
          expect(subject.valid?).to be false
        end

        it "raises correct error message" do
          subject.valid?
          expect(subject.errors.messages[:first_name].first).to eq("Enter your first name")
        end
      end

      context "when a first_name has been provided" do
        let(:params) { { first_name: "John" } }

        it "is valid" do
          expect(subject.valid?).to be true
        end

        it "sets the first_name on the personal details form" do
          expect(subject.first_name).to eq("John")
        end
      end
    end
  end
end
