require "rails_helper"

RSpec.describe Publishers::VacancyFormSequence do
  subject(:sequence) do
    described_class.new(
      vacancy: vacancy,
      organisation: organisation,
    )
  end

  let(:vacancy) do
    create(:vacancy, :no_tv_applications, job_role: nil, key_stages: %w[ks3], phases: %w[secondary])
  end

  let(:organisation) { create(:school) }

  describe "#validate_all_steps" do
    it "uses forms to validate each validatable step" do
      all_steps = %i[
        job_location
        job_role
        education_phases
        job_title
        key_stages
        subjects
        contract_type
        working_patterns
        pay_package
        important_dates
        start_date
        applying_for_the_job
        how_to_receive_applications
        application_link
        application_form
        school_visits
        contact_details
        about_the_role
        include_additional_documents
        documents
        review
      ]

      validatable_steps = all_steps - %i[subjects documents review]
      valid_steps = validatable_steps - [:job_role]

      validated_forms = sequence.validate_all_steps

      valid_steps.each do |step|
        form = validated_forms[step]
        next unless form

        expect(form.errors).to be_none
        expect(form).to be_valid
      end

      invalid_form = validated_forms[:job_role]
      expect(invalid_form.errors).to have_key(:job_role)
      expect(invalid_form).not_to be_valid

      expect(vacancy.errors).to have_key(:job_role)
      expect(vacancy.errors.where(:job_role).first.options[:step]).to eq(:job_role)
    end
  end

  describe "#all_steps_valid?" do
    it "is true if all steps are valid" do
      expect(sequence).not_to be_all_steps_valid
      vacancy.update(job_role: :teacher, ect_status: "ect_suitable")
      expect(sequence).to be_all_steps_valid
    end
  end
end
