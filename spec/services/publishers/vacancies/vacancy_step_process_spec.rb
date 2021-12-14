require "rails_helper"

RSpec.describe Publishers::Vacancies::VacancyStepProcess do
  subject { described_class.new(current_step, vacancy: vacancy, organisation: organisation, session: session) }

  let(:current_step) { :job_details }

  let(:vacancy) { build_stubbed(:vacancy, :draft, job_roles: %w[teacher]) }
  let(:organisation) { build_stubbed(:school) }
  let(:session) { {} }

  describe "#step_groups" do
    let(:all_possible_step_groups) do
      %i[
        job_role job_location job_details working_patterns pay_package important_dates documents
        applying_for_the_job job_summary review
      ]
    end

    context "when signed in as a school" do
      let(:organisation) { build_stubbed(:school) }

      it "has the expected step groups" do
        expect(subject.step_groups.keys).to eq(all_possible_step_groups - %i[job_location])
      end
    end

    context "when signed in as a MAT" do
      let(:organisation) { build_stubbed(:trust) }

      it "has the expected step groups" do
        expect(subject.step_groups.keys).to eq(all_possible_step_groups)
      end
    end

    context "when signed in as an LA" do
      let(:organisation) { build_stubbed(:local_authority) }

      it "has the expected step groups" do
        expect(subject.step_groups.keys).to eq(all_possible_step_groups)
      end
    end
  end

  describe "#steps" do
    let(:all_possible_steps) do
      %i[
        job_role job_role_details job_location schools education_phases job_details working_patterns
        pay_package important_dates documents applying_for_the_job applying_for_the_job_details job_summary review
      ]
    end

    context "with SENDCo vacancies" do
      let(:vacancy) { build_stubbed(:vacancy, job_roles: %w[sendco]) }

      it "skips the `job_roles_details` step" do
        expect(subject.steps).not_to include(:job_role_details)
      end
    end

    context "when signed in as a school" do
      let(:organisation) { create(:school) }
      let(:vacancy) do
        create(:vacancy,
               :draft,
               job_roles: %w[teacher],
               organisations: [organisation])
      end

      it "returns the expected steps" do
        expect(subject.steps).to eq(all_possible_steps - %i[job_location schools education_phases])
      end
    end

    context "when signed in as a MAT" do
      let(:organisation) { build_stubbed(:trust) }

      context "when the vacancy is at a single school" do
        let(:school) { create(:school) }
        let(:vacancy) do
          create(:vacancy,
                 :draft,
                 job_roles: %w[teacher],
                 organisations: [school])
        end

        it "returns the expected steps" do
          expect(subject.steps).to eq(all_possible_steps.excluding(:education_phases))
        end

        context "when the school is all-through" do
          let(:school) { create(:school, :all_through) }

          it "includes the `education_phases` step" do
            expect(subject.steps).to include(:education_phases)
          end
        end
      end

      context "when the vacancy is at the central office" do
        let(:vacancy) { build_stubbed(:vacancy, job_roles: %w[teacher], job_location: "central_office") }

        it "skips the `schools` step" do
          expect(subject.steps).not_to include(:schools)
        end

        it "includes the `education_phases` step" do
          expect(subject.steps).to include(:education_phases)
        end
      end

      context "when the job location has changed from central_office in the session" do
        let(:vacancy) { build_stubbed(:vacancy, job_roles: %w[teacher], job_location: "central_office") }
        let(:session) { { job_location: "at_multiple_schools" } }

        it "includes the `schools` step" do
          expect(subject.steps).to include(:schools)
        end
      end

      context "when the job location has changed to central_office in the session" do
        let(:vacancy) { build_stubbed(:vacancy, :draft, job_roles: %w[teacher], job_location: "at_multiple_schools") }
        let(:session) { { job_location: "central_office" } }

        it "skips the `schools` step" do
          expect(subject.steps).to eq(all_possible_steps - %i[schools])
        end
      end
    end

    context "when signed in as an LA" do
      let(:organisation) { build_stubbed(:local_authority) }

      it "returns the expected steps" do
        expect(subject.steps).to eq(all_possible_steps)
      end

      context "when the vacancy is at multiple schools" do
        let(:school) { create(:school, :secondary) }
        let(:vacancy) { create(:vacancy, organisations: [school, school2]) }

        context "when the schools have the same phase" do
          let(:school2) { create(:school, :secondary) }

          it "skips the `education_phases` step" do
            expect(subject.steps).not_to include(:education_phases)
          end
        end

        context "when the schools have different phases" do
          let(:school2) { create(:school, :primary) }

          it "includes the `education_phases` step" do
            expect(subject.steps).to include(:education_phases)
          end

          context "when the vacancy has a phase already" do
            let(:vacancy) { create(:vacancy, phase: "secondary", organisations: [school, school2]) }

            it "still includes the `education_phases` step" do
              expect(subject.steps).to include(:education_phases)
            end
          end
        end
      end
    end
  end
end
