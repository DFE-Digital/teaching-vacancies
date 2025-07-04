require "rails_helper"

RSpec.describe JobseekerProfile, type: :model do
  describe ".prepare(jobseeker:)" do
    subject(:profile) { described_class.prepare(jobseeker:) }
    let(:jobseeker) { create(:jobseeker) }

    context "when a profile already exists for that jobseeker" do
      let!(:existing_profile) { create(:jobseeker_profile, jobseeker:) }

      it "returns the existing profile" do
        expect(profile).to eq(existing_profile)
      end
    end

    context "when the jobseeker has a previously submitted application" do
      let(:first_name) { "Bill" }
      let(:last_name) { "Smith" }
      let!(:previous_application) { create(:job_application, :status_submitted, jobseeker:, first_name:, last_name:) }

      it "uses the details from the previous application" do
        expect(profile.employments.map(&:job_title).sort).to eq(previous_application.employments.map(&:job_title).sort)
        expect(profile.qualifications.map(&:institution).sort).to eq(previous_application.qualifications.map(&:institution).sort)
        expect(profile.qualified_teacher_status_year).to eq(previous_application.qualified_teacher_status_year)
        expect(profile.qualified_teacher_status).to eq(previous_application.qualified_teacher_status)
        expect(profile.personal_details.first_name).to eq(first_name)
        expect(profile.personal_details.last_name).to eq(last_name)
      end

      it "creates a job preferences record" do
        expect(profile.job_preferences).to be_present
        expect(profile.job_preferences).to be_persisted
      end
    end

    context "when the jobseeker has a previous draft application" do
      before do
        create(:job_application, :status_draft, jobseeker:, first_name: "karl", last_name: "karlssen", phone_number: "01234567899", has_right_to_work_in_uk: true)
      end

      it "does not use the details from the draft application" do
        expect(profile.employments).to be_empty
        expect(profile.qualifications).to be_empty
        expect(profile.qualified_teacher_status_year).to be_nil
        expect(profile.qualified_teacher_status).to be_nil
        expect(profile.personal_details.first_name).to be_nil
        expect(profile.personal_details.last_name).to be_nil
        expect(profile.personal_details.phone_number).to be_nil
      end

      it "creates a job preferences record" do
        expect(profile.job_preferences).to be_present
        expect(profile.job_preferences).to be_persisted
      end
    end

    context "when the jobseeker has no previous application" do
      it "does not use the details from the previous application" do
        expect(profile.employments).to be_empty
        expect(profile.qualifications).to be_empty
        expect(profile.qualified_teacher_status_year).to be_nil
        expect(profile.qualified_teacher_status).to be_nil
      end

      it "still creates a personal details record" do
        expect(profile.personal_details).to be_present
      end

      it "still creates a job preferences record" do
        expect(profile.job_preferences).to be_present
      end
    end
  end

  def qualification_attributes(qualification)
    qualification.attributes.symbolize_keys.except(:created_at, :updated_at, :id, :finished_studying_details_ciphertext, :job_application_id, :jobseeker_profile_id)
  end

  describe "#replace_qualifications!" do
    let!(:old_qualification) { build(:qualification, job_application_id: nil) }
    let(:new_qualifications) { create_list(:qualification, 2) }
    let(:profile) { create(:jobseeker_profile, qualifications: [old_qualification]) }

    it "replaces the qualifications" do
      profile.replace_qualifications!(new_qualifications)
      expect(profile.reload.qualifications.map { |q| qualification_attributes(q) })
        .to match_array(new_qualifications.map { |q| qualification_attributes(q) })
    end

    it "deletes the original profile qualifications" do
      profile.replace_qualifications!(new_qualifications)
      expect { old_qualification.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "does not delete qualifications unrelated to the profile" do
      unrelated_qualification = create(:qualification)
      profile.replace_qualifications!(new_qualifications)
      expect { unrelated_qualification.reload }.not_to raise_error
    end
  end

  describe "#save" do
    let(:profile) { create(:jobseeker_profile, is_statutory_induction_complete: is_statutory_induction_complete, statutory_induction_complete_details: "some info") }

    context "when statutory_induction_complete is true" do
      let(:is_statutory_induction_complete) { true }

      it "sets statutory_induction_complete_details to nil" do
        expect(profile.statutory_induction_complete_details).to be_nil
      end
    end

    context "when statutory_induction_complete is false" do
      let(:is_statutory_induction_complete) { false }

      it "does not modify statutory_induction_complete_details" do
        expect(profile.statutory_induction_complete_details).to eq "some info"
      end
    end
  end

  describe "#replace_employments!" do
    let(:old_employment) { build(:employment, job_application: nil) }
    let(:new_employments) { build_list(:employment, 2) }
    let!(:profile) { create(:jobseeker_profile, employments: [old_employment]) }
    let(:excluded_attrs) { %i[job_application_id jobseeker_profile_id created_at id updated_at] }

    before do
      create(:job_application, employments: new_employments)
    end

    it "replaces the employments" do
      expect {
        profile.replace_employments!(new_employments)
      }.to change(Employment, :count).by(1)

      expect(profile.reload.employments.map { |z| z.attributes.symbolize_keys.except(*excluded_attrs).reject { |k, _v| k.to_s.ends_with?("_ciphertext") } })
        .to match_array(new_employments.map { |x| x.attributes.symbolize_keys.except(*excluded_attrs).reject { |k, _v| k.to_s.ends_with?("_ciphertext") } })

      expect(profile.employments.map(&:job_application).uniq).to eq([nil])
    end

    it "deletes the original profile employments" do
      profile.replace_employments!(new_employments)
      expect { old_employment.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "does not delete employments unrelated to the profile" do
      unrelated_employment = create(:employment)
      profile.replace_employments!(new_employments)
      expect { unrelated_employment.reload }.not_to raise_error
    end
  end

  describe "#current_or_most_recent_employment" do
    let!(:profile) { create(:jobseeker_profile) }

    context "when there are no employments" do
      it "returns nil" do
        expect(profile.current_or_most_recent_employment).to be_nil
      end
    end

    context "when there are employments" do
      let!(:older_employment) { create(:employment, jobseeker_profile: profile, started_on: 2.years.ago, ended_on: 1.year.ago) }
      let!(:recent_employment) { create(:employment, jobseeker_profile: profile, started_on: 1.year.ago, ended_on: 6.months.ago) }

      it "returns the most recent employment based on started_on date" do
        expect(profile.current_or_most_recent_employment).to eq(recent_employment)
      end
    end

    context "when there are employment breaks" do
      let!(:employment) { create(:employment, jobseeker_profile: profile, started_on: 1.year.ago, ended_on: 6.months.ago) }
      let!(:employment_break) { create(:employment, :break, jobseeker_profile: profile, started_on: 6.months.ago, ended_on: 3.months.ago) }

      it "returns only job employments, not breaks" do
        expect(profile.current_or_most_recent_employment).to eq(employment)
      end
    end
  end
end
