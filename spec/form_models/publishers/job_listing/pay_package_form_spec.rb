require "rails_helper"

SALARY_OPTIONS = {
  salary: "full_time",
  actual_salary: "part_time",
  pay_scale: "pay_scale",
}.freeze

RSpec.describe Publishers::JobListing::PayPackageForm, type: :model do
  subject { described_class.new(params, vacancy) }

  let(:vacancy) do
    build_stubbed(:vacancy,
                  salary: nil,
                  actual_salary: nil,
                  pay_scale: nil)
  end

  SALARY_OPTIONS.each do |salary_value, salary_type|
    context "when only #{salary_type} salary is selected" do
      let(:params) { { salary_types: [salary_type], benefits: "false" } }

      it { is_expected.to validate_presence_of(salary_value) }
      it { is_expected.to validate_length_of(salary_value).is_at_least(1).is_at_most(256) }
      it { is_expected.to validate_inclusion_of(:benefits).in_array([true, false, "true", "false"]) }

      (SALARY_OPTIONS.keys - [salary_value]).each do |other_salary_type|
        it { is_expected.not_to validate_presence_of(other_salary_type) }
      end
    end
  end

  context "when there are no benefits" do
    let(:params) { { salary_types: nil, benefits: "false" } }

    it { is_expected.to validate_inclusion_of(:benefits).in_array([true, false, "true", "false"]) }
    it { is_expected.not_to validate_presence_of(:benefits_details) }
  end

  context "when there are benefits" do
    let(:params) { { salary_types: nil, benefits: "true" } }

    it { is_expected.to validate_inclusion_of(:benefits).in_array([true, false, "true", "false"]) }
    it { is_expected.to validate_presence_of(:benefits_details) }
    it { is_expected.to validate_length_of(:benefits_details).is_at_least(1).is_at_most(256) }
  end
end
