require "rails_helper"

RSpec.describe Jobseekers::Qualifications::Secondary::CommonForm, type: :model do
  subject { described_class.new(params) }
  let(:params) { {} }

  it { is_expected.to validate_presence_of(:category) }
  it { is_expected.to validate_presence_of(:institution) }
  it { is_expected.to validate_numericality_of(:year).is_less_than_or_equal_to(Time.current.year) }

  describe "qualification result validations" do
    context "when no qualification results are given" do
      let(:params) do
        {
          qualification_results_attributes: {
            "0" => { "subject" => "", "grade" => "" },
            "1" => { "subject" => "", "grade" => "" },
            "2" => { "subject" => "", "grade" => "" },
          },
        }
      end

      it "is not valid" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages_for(:qualification_results_attributes_0_subject)).to include(I18n.t("qualification_errors.qualification_results_attributes_0_subject.at_least_one_result_required"))
      end
    end

    context "when some nested qualification results fail validation" do
      let(:params) do
        {
          qualification_results_attributes: {
            "0" => { "subject" => "Clarinet", "grade" => "A+" },
            "1" => { "subject" => "Potions", "grade" => "" },
            "2" => { "subject" => "", "grade" => "A-" },
          },
        }
      end

      it "is not valid and hoists the nested forms' errors" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages_for(:qualification_results_attributes_1_grade)).to include(I18n.t("errors.messages.incomplete_qualification_result", attribute: "grade", result_idx: 2))
        expect(subject.errors.messages_for(:qualification_results_attributes_2_subject)).to include(I18n.t("errors.messages.incomplete_qualification_result", attribute: "subject", result_idx: 3))
      end
    end

    context "when all required params are given" do
      let(:params) do
        {
          category: :gcse,
          year: 1999,
          institution: "Hogwarts",
          qualification_results_attributes: {
            "0" => { "subject" => "Clarinet", "grade" => "A+" },
            "1" => { "subject" => "Potions", "grade" => "X-" },
            "2" => { "subject" => "", "grade" => "" },
          },
        }
      end

      it "is valid" do
        expect(subject).to be_valid
      end
    end
  end
end
