require "rails_helper"

RSpec.describe Publishers::VacancyFormSequence do
  subject(:sequence) do
    described_class.new(
      vacancy: vacancy,
      step_names: all_steps,
    )
  end

  let(:vacancy) { create(:draft_vacancy, :secondary, :apply_via_website, school_visits: nil, organisations: [organisation]) }
  let(:organisation) { build(:school) }
  let(:all_steps) do
    %i[
      job_location
      job_role
      education_phases
      job_title
      confirm_job_address
      key_stages
      subjects
      contract_information
      pay_package
      important_dates
      start_date
      applying_for_the_job
      how_to_receive_applications
      application_link
      school_visits
      contact_details
      confirm_contact_details
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
      vacancy.assign_attributes(school_visits: true)
      expect(sequence).to be_all_steps_valid
    end
  end

  describe "#next_invalid_step" do
    it "returns the next invalid step" do
      expect(sequence.next_invalid_step).to eq(:school_visits)
    end

    context "when the next incomplete step is subjects" do
      let(:vacancy) { build_stubbed(:vacancy, :secondary, completed_steps: %w[job_location job_role education_phases job_title key_stages]) }

      before { allow(vacancy).to receive(:allow_key_stages?).and_return(true) }

      it "returns subjects" do
        expect(sequence.next_invalid_step).to be(:subjects)
      end
    end

    context "when the vacancy has been published" do
      let(:current_step) { :job_location }
      let(:vacancy) { build_stubbed(:vacancy, phases: nil, organisations: [organisation]) }

      context "when a dependent step is invalid" do
        it "returns the first invalid dependent step" do
          expect(sequence.next_invalid_step).to eq(:education_phases)
        end
      end
    end

    context "when confirm_job_address step is included and has missing fields" do
      let(:organisation) { create(:college) }
      let(:vacancy) do
        create(:draft_vacancy, :secondary, :apply_via_website,
               school_visits: true,
               organisations: [organisation],
               completed_steps: all_steps.map(&:to_s) - ["review"],
               job_address_town: "Brighton",
               job_address_postcode: "BN1 1AA",
               job_address_line1: nil)
      end

      it "returns confirm_job_address as the next invalid step" do
        expect(sequence.next_invalid_step).to eq(:confirm_job_address)
      end
    end
  end
end
