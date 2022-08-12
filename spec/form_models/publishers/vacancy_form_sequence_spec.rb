require "rails_helper"

RSpec.describe Publishers::VacancyFormSequence do
  subject(:sequence) do
    described_class.new(
      vacancy: vacancy,
      organisation: organisation,
    )
  end

  let(:vacancy) do
    create(:vacancy, job_title: nil, phases: %w[secondary])
  end

  let(:organisation) { create(:school) }

  describe "#validate_all_steps" do
    it "uses forms to validate each validatable step" do
      all_steps = %i[
        applying_for_the_job
        documents
        education_phases
        important_dates
        job_details
        job_role
        job_role_details
        job_summary
        pay_package
        review
        working_patterns
      ]

      validatable_steps = all_steps - %i[documents review]
      valid_steps = validatable_steps - [:job_details]

      validated_forms = sequence.validate_all_steps

      valid_steps.each do |step|
        form = validated_forms[step]
        next unless form

        expect(form.errors).to be_none
        expect(form).to be_valid
      end

      invalid_form = validated_forms[:job_details]
      expect(invalid_form.errors).to have_key(:job_title)
      expect(invalid_form).not_to be_valid

      expect(vacancy.errors).to have_key(:job_title)
      expect(vacancy.errors.where(:job_title).first.options[:step]).to eq(:job_details)
    end
  end

  describe "#all_steps_valid?" do
    it "is true if all steps are valid" do
      expect(sequence).not_to be_all_steps_valid
      vacancy.update(job_title: "Job title")
      expect(sequence).to be_all_steps_valid
    end
  end
end
