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
        create(:job_application, :status_draft, jobseeker:, first_name: "karl", last_name: "karlssen", phone_number: "01234567899", right_to_work_in_uk: "yes")
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

  describe "#save" do
    let(:profile) { create(:jobseeker_profile) }

    before do
      profile.update!(has_teacher_reference_number: has_teacher_reference_number, teacher_reference_number: "1234567")
    end

    context "without a TRN" do
      let(:has_teacher_reference_number) { "no" }

      it "blanks TRN" do
        expect(profile.teacher_reference_number).to be_nil
      end
    end

    context "with a TRN" do
      let(:has_teacher_reference_number) { "yes" }

      it "keeps the TRN" do
        expect(profile.teacher_reference_number).to eq("1234567")
      end
    end
  end

  describe "#replace_qualifications!" do
    let(:old_qualification) { create(:qualification) }
    let(:new_qualifications) { create_list(:qualification, 2) }
    let(:profile) { create(:jobseeker_profile, qualifications: [old_qualification]) }

    it "replaces the qualifications" do
      profile.replace_qualifications!(new_qualifications)
      expect(profile.reload.qualifications).to match_array(new_qualifications)
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

  describe "#replace_employments!" do
    let(:old_employment) { build(:employment) }
    let(:new_employments) { build_list(:employment, 2) }
    let!(:profile) { create(:jobseeker_profile, employments: [old_employment]) }
    let(:excluded_attrs) { %i[job_application_id jobseeker_profile_id created_at id updated_at] }

    before do
      create(:job_application, create_details: false, employments: new_employments)
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
end
