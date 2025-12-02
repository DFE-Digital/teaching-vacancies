require "rails_helper"

RSpec.describe Jobseekers::JobApplications::PrefillJobApplicationFromPreviousApplication do
  let(:jobseeker) { create(:jobseeker) }
  let(:new_vacancy) { create(:vacancy) }
  let(:new_job_application) { jobseeker.job_applications.create(vacancy: new_vacancy) }

  subject { described_class.new(jobseeker, new_job_application).call }

  describe "#job_application" do
    context "when jobseeker has a recent job application" do
      let(:old_vacancy) { create(:vacancy) }
      let!(:recent_job_application) { create(:job_application, :status_submitted, submitted_at: 1.day.ago, jobseeker: jobseeker, vacancy: old_vacancy, notify_before_contact_referers: true) }
      let!(:older_job_application) { create(:job_application, :status_submitted, submitted_at: 1.week.ago, jobseeker: jobseeker, vacancy: old_vacancy) }
      let!(:draft_job_application) { create(:job_application, jobseeker: jobseeker, vacancy: old_vacancy) }

      it "creates a new draft job application for the new vacancy" do
        expect { subject }.to change { jobseeker.job_applications.draft.count }.by(1)
        expect(subject.vacancy).to eq(new_vacancy)
      end

      context "when all steps from the most recent application are relevant to the new application" do
        let(:attributes_to_copy) do
          %i[first_name last_name previous_names street_address city country postcode phone_number
             national_insurance_number qualified_teacher_status qualified_teacher_status_year qualified_teacher_status_details
             is_statutory_induction_complete is_support_needed support_needed_details notify_before_contact_referers]
        end

        it "copies personal info from the recent job application" do
          expect(subject.slice(attributes_to_copy)).to eq(recent_job_application.slice(attributes_to_copy))
        end

        context "when the application is from before we added gap validation for employment history section" do
          before do
            # ensure both submitted job applications were submitted before we started validating employment history gaps
            recent_job_application.update(submitted_at: Date.new(2024, 4, 2))
            older_job_application.update(submitted_at: Date.new(2024, 4, 2))
          end

          it "copies completed steps except for declarations and equal opportunities and employment_history and also adds them to imported steps" do
            expect(subject.completed_steps)
              .to eq(%w[personal_details referees ask_for_support qualifications training_and_cpds professional_body_memberships professional_status])
            expect(subject.imported_steps)
              .to eq(%w[personal_details referees ask_for_support qualifications training_and_cpds professional_body_memberships professional_status])
          end

          it "add employment_history to the in progress steps " do
            expect(subject.in_progress_steps)
              .to eq(%w[personal_statement employment_history])
          end
        end

        context "when the application is from after we added gap validation for employment history section" do
          it "copies completed steps except for declarations and equal opportunities and also adds them to imported steps" do
            expect(subject.completed_steps)
              .to eq(%w[personal_details referees ask_for_support qualifications training_and_cpds professional_body_memberships employment_history professional_status])
            expect(subject.imported_steps)
              .to eq(%w[personal_details referees ask_for_support qualifications training_and_cpds professional_body_memberships employment_history professional_status])
          end

          it "does not add employment_history to the in progress steps" do
            expect(subject.in_progress_steps)
              .to eq(%w[personal_statement])
          end
        end

        context "when the previous application did not ask about professional_status" do
          let(:old_vacancy) { create(:vacancy, job_roles: ["it_support"]) }

          it "it includes professional_status in in_progress steps" do
            expect(subject.completed_steps.include?("professional_status")).to eq false
            expect(subject.imported_steps.include?("professional_status")).to eq false
            expect(subject.in_progress_steps.include?("professional_status")).to eq true
          end
        end
      end

      context "when there are steps in the most recent application that are not relevant to the new application" do
        let(:vacancy_for_teacher) { create(:vacancy, job_roles: ["teacher"]) }
        let(:vacancy_for_teaching_assistant) { create(:vacancy, job_roles: ["teaching_assistant"]) }
        let!(:most_recent_job_application) { create(:job_application, :status_submitted, submitted_at: 1.hour.ago, jobseeker: jobseeker, vacancy: vacancy_for_teacher) }
        let(:completed_step_to_not_copy) { %i[professional_status] }
        let(:new_job_application) { jobseeker.job_applications.create(vacancy: vacancy_for_teaching_assistant) }

        it "only copies the relevant completed steps" do
          expect(subject.completed_steps).to_not include(completed_step_to_not_copy)
        end
      end

      it "copies qualifications from the recent job application" do
        attributes_to_copy = %i[category finished_studying finished_studying_details grade institution name subject year]

        expect(subject.qualifications.map { |qualification| qualification.slice(*attributes_to_copy) })
          .to match_array(recent_job_application.qualifications.map { |qualification| qualification.slice(*attributes_to_copy) })
      end

      it "sets qualifications section completed to true" do
        expect(subject.completed_steps).to(include("qualifications"))
      end

      it "copies employments from the recent job application" do
        attributes_to_copy = %i[organisation job_title subjects is_current_role main_duties started_on ended_on]

        expect(subject.employments.map { |employment| employment.slice(*attributes_to_copy) })
          .to eq(recent_job_application.employments.map { |employment| employment.slice(*attributes_to_copy) })
      end

      context "when the application is from before we added gap validation for employment history section" do
        before do
          # ensure both submitted job applications were submitted before we started validating employment history gaps
          recent_job_application.update(submitted_at: Date.new(2024, 4, 2))
          older_job_application.update(submitted_at: Date.new(2024, 4, 2))
        end

        it "sets employment history section completed to false" do
          expect(subject.in_progress_steps).to(include("employment_history"))
        end
      end

      context "when the application is from after we added gap validation for employment history section" do
        it "sets employment history section completed to true" do
          expect(subject.completed_steps).to(include("employment_history"))
        end
      end

      it "copies references from the recent job application" do
        attributes_to_copy = %i[name job_title organisation relationship email phone_number]

        expect(subject.referees.map { |referee| referee.slice(*attributes_to_copy) })
          .to eq(recent_job_application.referees.map { |referee| referee.slice(*attributes_to_copy) })
      end

      it "copies training and cpds from the recent job application" do
        attributes_to_copy = %i[name provider grade year_awarded]

        expect(subject.training_and_cpds.map { |training| training.slice(*attributes_to_copy) })
          .to eq(recent_job_application.training_and_cpds.map { |training| training.slice(*attributes_to_copy) })

        expect(subject.completed_steps).to include("training_and_cpds")
      end

      it "does not copy declarations attributes from the recent job application" do
        expect(subject.has_close_relationships).to be_nil
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

      context "when previous application has a baptism certificate" do
        let(:vacancy_for_faith_school) { create(:vacancy, :catholic) }
        let(:new_job_application) { jobseeker.job_applications.create(vacancy: vacancy_for_faith_school) }
        let(:recent_job_application) { create(:job_application, :status_submitted, submitted_at: 1.day.ago, jobseeker: jobseeker, vacancy: vacancy_for_faith_school) }

        before do
          recent_job_application.baptism_certificate.attach(
            io: Rails.root.join("spec/fixtures/files/blank_baptism_cert.pdf").open,
            filename: "baptism_cert.pdf",
            content_type: "application/pdf",
          )
        end

        it "copies the baptism certificate attachment" do
          expect(subject.baptism_certificate).to be_attached
          expect(subject.baptism_certificate.filename.to_s).to eq("baptism_cert.pdf")
          expect(subject.baptism_certificate.content_type).to eq("application/pdf")
        end

        it "copies content" do
          expect(subject.content.to_plain_text).to eq(recent_job_application.content.to_plain_text)
        end

        it "copies other personal details" do
          expect(subject.first_name).to eq(recent_job_application.first_name)
          expect(subject.last_name).to eq(recent_job_application.last_name)
        end
      end

      context "when previous application is for a faith school but has no baptism certificate" do
        let(:vacancy_for_faith_school) { create(:vacancy, :catholic) }
        let(:new_job_application) { jobseeker.job_applications.create(vacancy: vacancy_for_faith_school) }
        let(:recent_job_application) { create(:job_application, :status_submitted, submitted_at: 1.day.ago, jobseeker: jobseeker, vacancy: vacancy_for_faith_school) }

        it "still copies personal details without error" do
          expect(subject.baptism_certificate).not_to be_attached
          expect(subject.first_name).to eq(recent_job_application.first_name)
          expect(subject.last_name).to eq(recent_job_application.last_name)
        end

        it "copies content" do
          expect(subject.content.to_plain_text).to eq(recent_job_application.content.to_plain_text)
        end
      end
    end
  end
end
