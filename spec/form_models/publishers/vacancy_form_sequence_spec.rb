require "rails_helper"

RSpec.describe Publishers::VacancyFormSequence do
  subject(:sequence) do
    described_class.new(
      vacancy: vacancy,
      organisation: organisation,
      step_process: step_process,
    )
  end

  let(:vacancy) { create(:vacancy, :no_tv_applications, school_visits: nil, key_stages: %w[ks3], phases: %w[secondary], organisations: [organisation]) }
  let(:organisation) { create(:school) }
  let(:step_process) { double(:step_process, steps: all_steps) }
  let(:all_steps) do
    %i[
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
      school_visits
      contact_details
      about_the_role
      include_additional_documents
      documents
      review
    ]
  end

  describe "#validate_all_steps" do
    it "uses forms to validate each validatable step" do
      validatable_steps = all_steps - %i[subjects review]
      valid_steps = validatable_steps - [:school_visits]

      validated_forms = sequence.validate_all_steps

      valid_steps.each do |step|
        form = validated_forms[step]
        next unless form

        expect(form.errors).to be_none
        expect(form).to be_valid
      end

      invalid_form = validated_forms[:school_visits]
      expect(invalid_form.errors).to have_key(:school_visits)
      expect(invalid_form).not_to be_valid

      expect(vacancy.errors).to have_key(:school_visits)
      expect(vacancy.errors.where(:school_visits).first.options[:step]).to eq(:school_visits)
    end
  end

  describe "#all_steps_valid?" do
    it "is true if all steps are valid" do
      expect(sequence).not_to be_all_steps_valid
      vacancy.update(school_visits: true)
      expect(sequence).to be_all_steps_valid
    end
  end

  describe "#invalid_dependent_steps?" do
    before { allow(step_process).to receive(:current_step).and_return(current_step) }

    context "when current step has no dependent steps" do
      let(:current_step) { :school_visits }

      it "returns false" do
        expect(sequence.invalid_dependent_steps?).to be false
      end
    end

    context "when current step has dependent steps" do
      before { vacancy.update(application_link: nil) }

      let(:current_step) { :how_to_receive_applications }

      it "returns true" do
        expect(sequence.invalid_dependent_steps?).to be true
      end
    end
  end

  describe "#next_invalid_step" do
    context "when the next incomplete step is subjects" do
      before { allow(sequence).to receive(:next_incomplete_step_subjects?).and_return(true) }

      it "returns subjects" do
        expect(sequence.next_invalid_step).to be(:subjects)
      end
    end

    context "when the next incomplete step is not subjects" do
      before { allow(step_process).to receive(:current_step).and_return(:application_link) }

      it "returns the correct step" do
        expect(sequence.next_invalid_step).to be(:school_visits)
      end
    end
  end

  describe "#next_invalid_dependent_step" do
    before do
      vacancy.update(application_link: nil)
      allow(step_process).to receive(:current_step).and_return(current_step)
    end

    context "when the current step has dependent steps" do
      let(:current_step) { :how_to_receive_applications }

      it "returns the correct invalid dependent step" do
        expect(sequence.next_invalid_dependent_step).to eq(:application_link)
      end
    end

    context "when the current step has no dependent steps" do
      let(:current_step) { :subjects }

      it "returns nil" do
        expect(sequence.next_invalid_dependent_step).to be_nil
      end
    end
  end
end
