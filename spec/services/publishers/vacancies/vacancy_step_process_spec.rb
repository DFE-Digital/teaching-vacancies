require "rails_helper"

RSpec.describe Publishers::Vacancies::VacancyStepProcess do
  subject { described_class.new(current_step, vacancy: vacancy, organisation: organisation, session: session) }

  let(:current_step) { :job_details }

  let(:vacancy) { build_stubbed(:vacancy, job_roles: %w[teacher]) }
  let(:organisation) { build_stubbed(:school) }
  let(:session) { {} }

  describe "#step_groups" do
    let(:all_possible_step_groups) do
      %i[
        job_role job_location job_details working_patterns pay_package important_dates documents
        applying_for_the_job job_summary review
      ]
    end

    context "for a school" do
      let(:organisation) { build_stubbed(:school) }

      it "has the expected step groups" do
        expect(subject.step_groups.keys).to eq(all_possible_step_groups - %i[job_location])
      end
    end

    context "for a MAT" do
      let(:organisation) { build_stubbed(:trust) }

      it "has the expected step groups" do
        expect(subject.step_groups.keys).to eq(all_possible_step_groups)
      end
    end

    context "for an LA" do
      let(:organisation) { build_stubbed(:local_authority) }

      it "has the expected step groups" do
        expect(subject.step_groups.keys).to eq(all_possible_step_groups)
      end
    end
  end

  describe "#steps" do
    let(:all_possible_steps) do
      %i[
        job_role job_role_details job_location schools job_details working_patterns pay_package
        important_dates documents applying_for_the_job job_summary review
      ]
    end

    context "for SENDCo vacancies" do
      let(:vacancy) { build_stubbed(:vacancy, job_roles: %w[sendco]) }

      it "skips the `job_roles_details` step" do
        expect(subject.steps).not_to include(:job_role_details)
      end
    end

    context "for a school" do
      let(:organisation) { build_stubbed(:school) }

      it "returns the expected steps" do
        expect(subject.steps).to eq(all_possible_steps - %i[job_location schools])
      end
    end

    context "for a MAT" do
      let(:organisation) { build_stubbed(:trust) }

      it "returns the expected steps" do
        expect(subject.steps).to eq(all_possible_steps)
      end

      context "when the vacancy is at central office" do
        let(:vacancy) { build_stubbed(:vacancy, job_roles: %w[teacher], job_location: "central_office") }

        it "skips the `schools` step" do
          expect(subject.steps).to eq(all_possible_steps - %i[schools])
        end
      end

      context "when the job location has changed from central_office in the session" do
        let(:vacancy) { build_stubbed(:vacancy, job_roles: %w[teacher], job_location: "central_office") }
        let(:session) { { job_location: "at_multiple_schools" } }

        it "includes the `schools` step" do
          expect(subject.steps).to eq(all_possible_steps)
        end
      end

      context "when the job location has changed to central_office in the session" do
        let(:vacancy) { build_stubbed(:vacancy, job_roles: %w[teacher], job_location: "at_multiple_schools") }
        let(:session) { { job_location: "central_office" } }

        it "skips the `schools` step" do
          expect(subject.steps).to eq(all_possible_steps - %i[schools])
        end
      end
    end

    context "for an LA" do
      let(:organisation) { build_stubbed(:local_authority) }

      it "returns the expected steps" do
        expect(subject.steps).to eq(all_possible_steps)
      end
    end
  end
end
