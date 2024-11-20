require "rails_helper"

RSpec.describe Jobseekers::JobApplication::PersonalDetailsForm, type: :model do
  let(:valid_params) do
    {
      city: "city",
      postcode: "postcode",
      street_address: "address",
      country: "country",
      first_name: "Bob",
      last_name: "Bobbins",
      phone_number: "01234 12345678",
      email_address: "david@gmail.com",
      right_to_work_in_uk: "yes",
    }
  end

  it { is_expected.to validate_presence_of(:street_address) }
  it { is_expected.to validate_presence_of(:postcode) }
  it { is_expected.to validate_presence_of(:city) }
  it { is_expected.to validate_presence_of(:country) }

  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }

  context "with national_insurance_number" do
    let(:form) do
      described_class.new(valid_params.merge(
                                       has_ni_number: "yes", national_insurance_number: national_insurance_number,
                                     ))
    end

    context "with valid NI number" do
      let(:national_insurance_number) { "AB 12 12 12 A" }

      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "with invalid NI number" do
      let(:national_insurance_number) { "AB 12 12 12 A 12" }

      it "is not valid" do
        expect(form).not_to be_valid
        expect(form.errors.messages).to eq(national_insurance_number: ["Enter a National Insurance number in the correct format"])
      end
    end
  end

  context "without national_insurance_number" do
    let(:form) { described_class.new(valid_params.merge(has_ni_number: has_ni_number)) }

    context "without an NI number" do
      let(:has_ni_number) { "no" }

      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "with an invalid entry" do
      let(:has_ni_number) { "" }

      it "is not valid" do
        expect(form).not_to be_valid
        expect(form.errors.messages).to eq(has_ni_number: ["Select yes if you have a National Insurance number"])
      end
    end
  end

  it { is_expected.to validate_presence_of(:email_address) }
  it { is_expected.to allow_value("david@gmail.com").for(:email_address) }
  it { is_expected.not_to allow_value("david at example.com").for(:email_address) }

  it { is_expected.to validate_presence_of(:phone_number) }
  it { is_expected.to allow_value("01234 12345678").for(:phone_number) }
  it { is_expected.not_to allow_value("01234 123456789").for(:phone_number) }

  it { is_expected.to validate_inclusion_of(:right_to_work_in_uk).in_array(%w[yes no]) }
end
