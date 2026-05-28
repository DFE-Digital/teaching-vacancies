require "rails_helper"

RSpec.describe ProfileEmployment do
  let(:profile_employment) { described_class.new(params.merge(employment_type: :job, jobseeker_profile: build(:jobseeker_profile))) }
  let(:params) { valid_params }

  describe "validations" do
    context "when main duties exceeds the word limit" do
      let(:params) { valid_params.merge(main_duties: words(EmploymentRecord::MAIN_DUTIES_MAX_WORDS + 1)) }

      it "is invalid" do
        expect(profile_employment).not_to be_valid
        expect(profile_employment.errors.messages[:main_duties_words]).to eq(["Main duties must be 150 words or less"])
      end
    end

    context "when reason for leaving exceeds the word limit" do
      let(:params) { valid_params.merge(reason_for_leaving: words(EmploymentRecord::REASON_FOR_LEAVING_MAX_WORDS + 1)) }

      it "is invalid" do
        expect(profile_employment).not_to be_valid
        expect(profile_employment.errors.messages[:reason_for_leaving_words]).to eq(["Reason for leaving role must be 50 words or less"])
      end
    end
  end

  def valid_params
    { organisation: "An organisation",
      job_title: "A job title",
      main_duties: "Some main duties",
      is_current_role: false,
      started_on: Date.new(2019, 9, 1),
      ended_on: Date.new(2020, 7, 30),
      reason_for_leaving: "stress" }
  end

  def words(count)
    Array.new(count, "word").join(" ")
  end
end
