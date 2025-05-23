require "rails_helper"

module Jobseekers::JobApplications::SelfDisclosure
  RSpec.describe PersonalDetailsForm, type: :model do
    subject(:personal_details_form) { described_class.new(params) }

    let(:name) { "name" }
    let(:previous_names) { "name" }
    let(:address_line_1) { "name" } # rubocop:disable RSpec/IndexedLet
    let(:address_line_2) { "name" } # rubocop:disable RSpec/IndexedLet
    let(:city) { "name" }
    let(:country) { "country" }
    let(:postcode) { "name" }
    let(:phone_number) { "name" }
    let(:date_of_birth) { Time.zone.today }
    let(:has_unspent_convictions) { true }
    let(:has_spent_convictions) { true }
    let(:params) do
      {
        name:,
        previous_names:,
        address_line_1:,
        address_line_2:,
        city:,
        country:,
        postcode:,
        phone_number:,
        date_of_birth:,
        has_unspent_convictions:,
        has_spent_convictions:,
      }
    end

    describe "validation" do
      before { personal_details_form.valid? }

      it { is_expected.to be_valid }

      %i[name address_line_1 city postcode phone_number date_of_birth].each do |field|
        context "when ##{field} absent" do
          let(field) { nil }

          it { is_expected.not_to be_valid }
        end
      end

      context "when #has_unspent_convictions absent" do
        let(:has_unspent_convictions) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when #has_spent_convictions absent" do
        let(:has_spent_convictions) { nil }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
