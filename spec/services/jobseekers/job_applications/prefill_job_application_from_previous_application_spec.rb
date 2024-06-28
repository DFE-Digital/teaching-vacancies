require "rails_helper"

RSpec.describe Jobseekers::JobApplications::PrefillJobApplicationFromPreviousApplication do
  let(:jobseeker) { create(:jobseeker) }
  let(:new_vacancy) { create(:vacancy) }
  let(:new_job_application) { jobseeker.job_applications.create(vacancy: new_vacancy) }

  subject { described_class.new(jobseeker, new_vacancy, new_job_application).call }

  describe "#job_application" do
    context "when jobseeker has a recent job application" do
      let(:old_vacancy) { create(:vacancy) }
      let!(:recent_job_application) { create(:job_application, :status_submitted, submitted_at: 1.day.ago, jobseeker: jobseeker, vacancy: old_vacancy) }
      let!(:older_job_application) { create(:job_application, :status_submitted, submitted_at: 1.week.ago, jobseeker: jobseeker, vacancy: old_vacancy) }
      let!(:draft_job_application) { create(:job_application, jobseeker: jobseeker, vacancy: old_vacancy) }

      it "creates a new draft job application for the new vacancy" do
        expect { subject }.to change { jobseeker.job_applications.draft.count }.by(1)
        expect(subject.vacancy).to eq(new_vacancy)
      end

      context "when all steps from the most recent application are relevant to the new application" do
        let(:attributes_to_copy) do
          %i[ first_name last_name previous_names street_address city country postcode phone_number teacher_reference_number
              national_insurance_number qualified_teacher_status qualified_teacher_status_year qualified_teacher_status_details
              statutory_induction_complete support_needed support_needed_details]
        end

        it "copies personal info from the recent job application" do
          expect(subject.slice(attributes_to_copy)).to eq(recent_job_application.slice(attributes_to_copy))
        end

        it "copies completed steps except for declarations and equal opportunities and also adds them to imported steps" do
          expect(subject.completed_steps)
            .to eq(%w[personal_details professional_status personal_statement references ask_for_support qualifications employment_history training_and_cpds])
          expect(subject.imported_steps)
            .to eq(%w[personal_details professional_status personal_statement references ask_for_support qualifications employment_history training_and_cpds])
        end

        it "sets in progress steps as empty" do
          expect(subject.in_progress_steps)
            .to eq(%w[])
        end
      end

      context "when there are steps in the most recent application that are not relevant to the new application" do
        let(:vacancy_for_teacher) { create(:vacancy, job_roles: ["teacher"]) }
        let(:vacancy_for_teaching_assistant) { create(:vacancy, job_roles: ["teaching_assistant"]) }
        let!(:most_recent_job_application) { create(:job_application, :status_submitted, submitted_at: 1.hour.ago, jobseeker: jobseeker, vacancy: vacancy_for_teacher) }
        let(:attributes_to_not_copy) { %i[qualified_teacher_status qualified_teacher_status_year qualified_teacher_status_details statutory_induction_complete] }
        let(:completed_step_to_not_copy) { %i[professional_status] }
        let(:new_job_application) { jobseeker.job_applications.create(vacancy: vacancy_for_teaching_assistant) }

        it "only copies the relevant personal info from the recent job application" do
          expect(subject.slice(attributes_to_not_copy)).to_not eq(most_recent_job_application.slice(attributes_to_not_copy))
        end

        it "only copies the relevant completed steps" do
          expect(subject.completed_steps).to_not include(completed_step_to_not_copy)
        end
      end

      it "copies qualifications from the recent job application" do
        attributes_to_copy = %i[category finished_studying finished_studying_details grade institution name subject year]

        expect(subject.qualifications.map { |qualification| qualification.slice(*attributes_to_copy) })
          .to eq(recent_job_application.qualifications.map { |qualification| qualification.slice(*attributes_to_copy) })
      end

      it "sets qualifications section completed to true" do
        expect(subject.qualifications_section_completed).to eq(true)
      end

      it "copies employments from the recent job application" do
        attributes_to_copy = %i[organisation job_title subjects current_role main_duties started_on ended_on]

        expect(subject.employments.map { |employment| employment.slice(*attributes_to_copy) })
          .to eq(recent_job_application.employments.map { |employment| employment.slice(*attributes_to_copy) })
      end

      it "sets employment history section completed to true" do
        expect(subject.employment_history_section_completed).to eq(true)
      end

      it "copies references from the recent job application" do
        attributes_to_copy = %i[name job_title organisation relationship email phone_number]

        expect(subject.references.map { |reference| reference.slice(*attributes_to_copy) })
          .to eq(recent_job_application.references.map { |reference| reference.slice(*attributes_to_copy) })
      end

      it "copies training and cpds from the recent job application" do
        attributes_to_copy = %i[name provider grade year_awarded]

        expect(subject.training_and_cpds.map { |training| training.slice(*attributes_to_copy) })
          .to eq(recent_job_application.training_and_cpds.map { |training| training.slice(*attributes_to_copy) })

        expect(subject.training_and_cpds_section_completed).to eq(true)
      end

      it "does not copy declarations attributes from the recent job application" do
        expect(subject.close_relationships).to be_blank
        expect(subject.close_relationships_details).to be_blank
      end

      it "does not copy equal opportunities attributes from the recent job application" do
        expect(subject.disability).to be_blank
        expect(subject.gender).to be_blank
        expect(subject.gender_description).to be_blank
        expect(subject.orientation).to be_blank
        expect(subject.orientation_description).to be_blank
        expect(subject.ethnicity).to be_blank
        expect(subject.ethnicity_description).to be_blank
        expect(subject.religion).to be_blank
        expect(subject.religion_description).to be_blank
      end
    end
  end
end
