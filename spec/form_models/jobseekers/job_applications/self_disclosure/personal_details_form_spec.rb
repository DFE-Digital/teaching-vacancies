require "rails_helper"

module Jobseekers::JobApplications::SelfDisclosure
  RSpec.describe PersonalDetailsForm, type: :model do
    context "with an empty form" do
      let(:form) { described_class.new }

      it "has the correct errors" do
        expect(form).not_to be_valid
        expect(form.errors.messages).to eq(
          {
            name: [
              "Enter your name",
            ],
            address_line_1: ["Enter your building and street"],
            city: ["Enter your town or city"],
            postcode: ["Enter your postcode"],
            phone_number: ["Enter your phone number"],
            date_of_birth: ["Enter your date of birth"],
            has_unspent_convictions: ["Select no if you have no unspent conditional cautions or convictions in the UK or overseas"],
            has_spent_convictions: ["Select no if you have no spent conditional cautions or convictions in the UK or overseas"],
          },
        )
      end
    end

    it { is_expected.to validate_date_or_hash_of(:date_of_birth) }

    it { is_expected.to allow_value("01234 12345678").for(:phone_number) }
    it { is_expected.not_to allow_value("01234 123456789").for(:phone_number) }

    describe "date_of_birth" do
      subject(:form) { described_class.new(date_of_birth:) }

      before { form.valid? }

      context "when over 18" do
        let(:date_of_birth) { Date.current - 18.years }

        it { expect(form.errors[:date_of_birth]).to be_blank }
      end

      context "when below 18" do
        let(:date_of_birth) { 17.years.ago }

        it { expect(form.errors[:date_of_birth]).not_to be_blank }
      end

      context "when in the future" do
        let(:date_of_birth) { 1.year.from_now }

        it { expect(form.errors[:date_of_birth]).not_to be_blank }
      end
    end
  end
end
