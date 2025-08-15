require "rails_helper"

module Jobseekers::JobApplications::SelfDisclosure
  RSpec.describe PersonalDetailsForm, type: :model do
    before { allow(Shoulda::Matchers).to receive(:warn) }

    %i[
      name
      address_line_1
      city
      postcode
      phone_number
      date_of_birth
    ].each do |field|
      it { is_expected.to validate_presence_of(field) }
    end

    it { is_expected.to validate_date_or_hash_of(:date_of_birth) }

    %i[
      has_unspent_convictions
      has_spent_convictions
    ].each do |field|
      it { is_expected.to validate_inclusion_of(field).in_array([true, false]) }
    end

    it { is_expected.to allow_value("01234 12345678").for(:phone_number) }
    it { is_expected.not_to allow_value("01234 123456789").for(:phone_number) }

    describe "date_of_birth" do
      subject(:form) { described_class.new(date_of_birth:) }

      before { form.valid? }

      context "when over 18" do
        let(:date_of_birth) { 18.years.ago }

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
