require "rails_helper"

RSpec.describe Publishers::VacancyFormSequence do
  subject(:sequence) do
    described_class.new(
      vacancy: vacancy,
      organisation: organisation,
      step_process: step_process,
    )
  end

  let(:vacancy) { create(:draft_vacancy, :secondary, :no_tv_applications, school_visits: nil, organisations: [organisation]) }
  let(:organisation) { create(:school) }
  let(:step_process) { double(:step_process, steps: all_steps, current_step: current_step) }
  let(:current_step) { :review }
  let(:all_steps) do
    %i[
      job_location
      job_role
      education_phases
      job_title
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

    context "when the vacancy has been published" do
      let(:vacancy) { create(:vacancy, :secondary, organisations: [organisation]) }

      context "when the current step has dependent steps" do
        let(:current_step) { :job_location }
        let(:validated_forms) { sequence.validate_all_steps }

        context "when the dependent steps are invalid" do
          let(:vacancy) { create(:vacancy, phases: nil, key_stages: nil, organisations: [organisation]) }

          before { allow(vacancy).to receive(:allow_key_stages?).and_return(true) }

          it "returns a hash containing invalid forms for each dependent step" do
            validated_forms.each_value { |form| expect(form).to be_invalid }
          end
        end

        context "when the dependent steps are valid" do
          let(:vacancy) { create(:vacancy, :secondary, organisations: [organisation]) }

          it "returns a hash containing valid forms for each dependent step" do
            validated_forms.each_value { |form| expect(form).to be_valid }
          end
        end
      end

      context "when the current step does not have dependent steps" do
        let(:current_step) { :job_title }

        it "returns an empty hash" do
          expect(sequence.validate_all_steps).to eq({})
        end
      end
    end
  end

  describe "#all_steps_valid?" do
    it "is true if all steps are valid" do
      expect(sequence).not_to be_all_steps_valid
      vacancy.update(school_visits: true)
      expect(sequence).to be_all_steps_valid
    end

    context "when the vacancy has been published" do
      let(:vacancy) { create(:vacancy, :secondary, organisations: [organisation]) }

      context "when the current step has dependent steps" do
        let(:current_step) { :job_location }

        context "when the dependent steps are invalid" do
          let(:vacancy) { create(:vacancy, phases: nil, key_stages: nil, organisations: [organisation]) }

          it "returns false" do
            expect(sequence.all_steps_valid?).to be false
          end
        end

        context "when the dependent steps are valid" do
          let(:vacancy) { create(:vacancy, :secondary, organisations: [organisation]) }

          it "returns true" do
            expect(sequence.all_steps_valid?).to be true
          end
        end
      end

      context "when the current step does not have dependent steps" do
        let(:current_step) { :job_title }

        it "returns true" do
          expect(sequence.all_steps_valid?).to be true
        end
      end

      describe "steps with conditional dependencies" do
        describe "applying_for_the_job" do
          let(:current_step) { :applying_for_the_job }
          let(:enable_job_applications) { nil }
          let(:vacancy) { build_stubbed(:vacancy, enable_job_applications:, organisations: [organisation]) }

          context "when enable_job_applications is false" do
            let(:enable_job_applications) { false }

            it "validates how_to_receive_applications" do
              expect(sequence.all_steps_valid?).to be false
            end
          end

          context "when enable_job_applications is true" do
            let(:enable_job_applications) { true }

            it "does not validate how_to_receive_applications" do
              expect(sequence.all_steps_valid?).to be true
            end
          end
        end

        describe "contact_details" do
          let(:current_step) { :contact_details }
          let(:vacancy) { build_stubbed(:vacancy, organisations: [organisation]) }

          before do
            allow(vacancy).to receive(:contact_email_belongs_to_a_publisher?).and_return(belongs_to_publisher)
          end

          context "when contact_email belongs to a registered publisher" do
            let(:belongs_to_publisher) { true }

            it "does not validate confirm_contact_details" do
              expect(sequence.all_steps_valid?).to be true
            end
          end

          context "when contact_email does not belong to a registered publisher" do
            let(:belongs_to_publisher) { false }

            it "validates confirm_contact_details" do
              expect(sequence.all_steps_valid?).to be false
            end
          end
        end
      end
    end
  end

  describe "#next_invalid_step" do
    it "returns the next invalid step" do
      expect(sequence.next_invalid_step).to eq(:school_visits)
    end

    context "when the next incomplete step is subjects" do
      let(:vacancy) { create(:vacancy, :secondary, completed_steps: %w[job_location job_role education_phases job_title key_stages]) }

      before { allow(vacancy).to receive(:allow_key_stages?).and_return(true) }

      it "returns subjects" do
        expect(sequence.next_invalid_step).to be(:subjects)
      end
    end

    context "when the vacancy has been published" do
      let(:current_step) { :job_location }
      let(:vacancy) { create(:vacancy, phases: nil, organisations: [organisation]) }

      context "when a dependent step is invalid" do
        it "returns the first invalid dependent step" do
          expect(sequence.next_invalid_step).to eq(:education_phases)
        end
      end
    end
  end
end
