require "rails_helper"

RSpec.describe Publishers::Vacancies::VacancyStepProcess do
  subject { described_class.new(current_step, vacancy: vacancy, organisation: organisation, session: session) }

  let(:current_step) { :job_details }

  let(:vacancy) { build_stubbed(:vacancy, :draft, :teacher) }
  let(:organisation) { build_stubbed(:school) }
  let(:session) { {} }

  describe "#step_groups" do
    context "when signed in as a school" do
      let(:all_possible_step_groups) do
        %i[
          job_role job_location job_details working_patterns pay_package important_dates
          applying_for_the_job documents job_summary review
        ]
      end
      let(:organisation) { create(:school) }
      let(:vacancy) do
        create(:vacancy,
               :draft,
               :teacher,
               organisations: [organisation])
      end

      it "has the expected step groups" do
        expect(subject.step_groups.keys).to eq(all_possible_step_groups.excluding(:job_location))
      end
    end

    context "when not signed in as a school" do
      let(:all_possible_step_groups) do
        %i[
          job_role job_location job_details working_patterns pay_package important_dates
          applying_for_the_job documents job_summary review
        ]
      end
      let(:organisation) { create(:trust) }
      let(:vacancy) do
        create(:vacancy,
               :draft,
               :teacher,
               organisations: [organisation])
      end

      it "has the expected step groups" do
        expect(subject.step_groups.keys).to eq(all_possible_step_groups)
      end
    end
  end

  describe "#steps" do
    let(:all_possible_steps) do
      %i[
        job_role job_role_details job_location education_phases job_details working_patterns
        pay_package important_dates applying_for_the_job applying_for_the_job_details documents job_summary review
      ]
    end

    context "when the job is for a teaching role" do
      let(:vacancy) { build_stubbed(:vacancy, :teacher) }

      it "does not skip the `job_roles_details` step" do
        expect(subject.steps).to include(:job_role_details)
      end
    end

    context "when the job is for any other role" do
      Vacancy.job_roles.each_key do |job_role|
        let(:vacancy) { build_stubbed(:vacancy, job_role: job_role) }

        it "skips the `job_roles_details` step" do
          expect(subject.steps).to_not include(:job_role_details)
        end
      end
    end

    context "when signed in as a school" do
      let(:organisation) { create(:school) }
      let(:vacancy) do
        create(:vacancy,
               :draft,
               :teacher,
               organisations: [organisation],
               phases: %w[primary])
      end

      it "returns the expected steps" do
        expect(subject.steps).to eq(all_possible_steps.excluding(:job_location, :education_phases))
      end
    end

    context "when signed in as a MAT" do
      let(:organisation) { build_stubbed(:trust) }

      context "when the vacancy is at a single school" do
        let(:school) { create(:school) }
        let(:vacancy) do
          create(:vacancy,
                 :draft,
                 :teacher,
                 organisations: [school],
                 phases: %w[primary])
        end

        it "returns the expected steps" do
          expect(subject.steps).to eq(all_possible_steps.excluding(:education_phases))
        end
      end

      context "when the vacancy is at the central office" do
        let(:trust) { create(:trust) }
        let(:vacancy) { build_stubbed(:vacancy, :teacher, organisations: [trust]) }

        it "includes the `education_phases` step" do
          expect(subject.steps).to include(:education_phases)
        end
      end
    end

    context "when signed in as an LA" do
      let(:organisation) { build_stubbed(:local_authority) }

      it "returns the expected steps" do
        expect(subject.steps).to eq(all_possible_steps.excluding(:applying_for_the_job))
      end

      context "when the vacancy is at multiple schools" do
        let(:vacancy) { create(:vacancy, phases: %w[primary], organisations: [school, school2]) }

        context "when the schools have a phase" do
          let(:school) { create(:school, :secondary) }
          let(:school2) { create(:school, phase: :not_applicable) }

          it "skips the `education_phases` step" do
            expect(subject.steps).not_to include(:education_phases)
          end
        end

        context "when the schools have no phase" do
          let(:school) { create(:school, phase: :not_applicable) }
          let(:school2) { create(:school, phase: :not_applicable) }

          it "includes the `education_phases` step" do
            expect(subject.steps).to include(:education_phases)
          end
        end
      end
    end

    context "when vacancy is published" do
      let(:vacancy) { build_stubbed(:vacancy, :published, :teacher) }

      it "returns the expected steps" do
        expect(subject.steps).to eq(all_possible_steps.excluding(:job_location, :applying_for_the_job))
      end
    end
  end
end
