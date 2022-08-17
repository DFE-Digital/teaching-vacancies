require "rails_helper"

RSpec.describe Publishers::Vacancies::VacancyStepProcess do
  subject { described_class.new(current_step, vacancy: vacancy, organisation: organisation) }

  let(:current_step) { :job_role }

  let(:vacancy) { build_stubbed(:vacancy, :draft, :teacher) }
  let(:organisation) { build_stubbed(:school) }

  describe "#step_groups" do
    let(:all_possible_step_groups) { %i[job_details important_dates application_process about_the_role review] }
    let(:vacancy) { create(:vacancy, :draft, :teacher, organisations: [organisation]) }

    it "has the expected step groups" do
      expect(subject.step_groups.keys).to eq(all_possible_step_groups)
    end
  end

  describe "#steps" do
    context "job_details steps" do
      it "has the required steps" do
        expect(subject.steps).to include(:job_role, :job_title, :contract_type, :working_patterns, :pay_package)
      end

      context "when the organisation is a school" do
        it "has the expected steps" do
          expect(subject.steps).to_not include(:job_location)
        end
      end

      context "when the organisation is a school group" do
        let(:organisation) { build_stubbed(:school_group) }

        it "has the expected steps" do
          expect(subject.steps).to include(:job_location)
        end
      end

      context "when the vacancy allows phases to be set" do
        it "has the expected steps" do
          expect(subject.steps).to include(:education_phases)
        end
      end

      context "when the vacancy does not allow phases to be set" do
        before { allow(vacancy).to receive(:allow_phase_to_be_set?).and_return(false) }

        it "has the expected steps" do
          expect(subject.steps).not_to include(:education_phases)
        end
      end

      context "when the vacancy allows key stages" do
        before { allow(vacancy).to receive(:allow_key_stages?).and_return(true) }

        it "has the expected steps" do
          expect(subject.steps).to include(:key_stages)
        end
      end

      context "when the vacancy does not allow key stages" do
        it "has the expected steps" do
          expect(subject.steps).not_to include(:key_stages)
        end
      end

      context "when the vacancy allows subjects" do
        before { allow(vacancy).to receive(:allow_subjects?).and_return(true) }

        it "has the expected steps" do
          expect(subject.steps).to include(:subjects)
        end
      end

      context "when the vacancy does not allow subjects" do
        it "has the expected steps" do
          expect(subject.steps).not_to include(:subjects)
        end
      end
    end

    context "important_dates_steps" do
      it "has the required steps" do
        expect(subject.steps).to include(:important_dates, :start_date)
      end
    end

    context "application_process_steps" do
      it "has the required steps" do
        expect(subject.steps).to include(:school_visits, :contact_details)
      end

      context "when the organisation is a school" do
        it "has the expected steps" do
          expect(subject.steps).to include(:applying_for_the_job)
        end
      end

      context "when the organisation is a trust" do
        let(:organisation) { build_stubbed(:trust) }

        it "has the expected steps" do
          expect(subject.steps).to include(:applying_for_the_job)
        end
      end

      context "when the organisation is a local authority" do
        before { allow(vacancy).to receive(:enable_job_applications).and_return(false) }

        let(:organisation) { build_stubbed(:local_authority) }

        it "has the expected steps" do
          expect(subject.steps).not_to include(:applying_for_the_job)
          expect(subject.steps).to include(:how_to_receive_applications)
        end
      end

      context "when the vacancy is published" do
        let(:vacancy) { build_stubbed(:vacancy, :published, :teacher) }

        context "when the vacancy allows job applications" do
          before { allow(vacancy).to receive(:enable_job_applications).and_return(true) }

          it "has the expected steps" do
            expect(subject.steps).not_to include(:applying_for_the_job, :how_to_receive_applications)
          end
        end

        context "when the vacancy does not allow job applications" do
          before { allow(vacancy).to receive(:enable_job_applications).and_return(false) }

          it "has the expected steps" do
            expect(subject.steps).not_to include(:applying_for_the_job)
            expect(subject.steps).to include(:how_to_receive_applications)
          end
        end
      end

      context "when the vacancy allows job applications" do
        before { allow(vacancy).to receive(:enable_job_applications).and_return(true) }

        it "has the expected steps" do
          expect(subject.steps).not_to include(:how_to_receive_applications)
          expect(subject.steps).not_to include(:application_link, :application_form)
        end
      end

      context "when the vacancy does not allow job applications" do
        before { allow(vacancy).to receive(:enable_job_applications).and_return(false) }

        it "has the expected steps" do
          expect(subject.steps).to include(:how_to_receive_applications)
        end

        context "when applications are received by email" do
          before { allow(vacancy).to receive(:receive_applications).and_return("email") }

          it "has the expected steps" do
            expect(subject.steps).to include(:application_form)
          end
        end

        context "when applications are received on a website" do
          before { allow(vacancy).to receive(:receive_applications).and_return("website") }

          it "has the expected steps" do
            expect(subject.steps).to include(:application_link)
          end
        end
      end
    end

    context "about_the_role_steps" do
      it "has the required steps" do
        expect(subject.steps).to include(:about_the_role, :include_additional_documents)
      end

      context "when include_additional_documents is true" do
        before { allow(vacancy).to receive(:include_additional_documents).and_return(true) }

        it "has the expected steps" do
          expect(subject.steps).to include(:documents)
        end
      end

      context "when include_additional_documents is false" do
        before { allow(vacancy).to receive(:include_additional_documents).and_return(false) }

        it "has the expected steps" do
          expect(subject.steps).not_to include(:documents)
        end
      end
    end
  end
end
