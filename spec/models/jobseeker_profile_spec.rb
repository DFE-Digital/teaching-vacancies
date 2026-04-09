require "rails_helper"

RSpec.describe JobseekerProfile, type: :model do
  context "with about_you context" do
    describe "about_you" do
      subject { build(:jobseeker_profile, about_you_richtext: about_you_content).save(context: :about_you) }

      context "with 1500 words" do
        let(:about_you_content) { Faker::Lorem.sentence(word_count: 1500) }

        it { is_expected.to be(true) }
      end

      context "with 1501 words" do
        let(:about_you_content) { Faker::Lorem.sentence(word_count: 1501) }

        it { is_expected.to be(false) }
      end

      context "when blank" do
        let(:about_you_content) { "" }

        it { is_expected.to be(false) }
      end
    end
  end

  describe ".prepare_associations" do
    context "when the record is already persisted" do
      let(:profile) { create(:jobseeker_profile) }

      it "does not save the record again" do
        expect(profile).not_to receive(:save!)

        described_class.prepare_associations(profile)
      end

      it "assigns job_preferences" do
        described_class.prepare_associations(profile)

        expect(profile.job_preferences).to be_present
      end
    end

    context "when the record is new (not persisted)" do
      let(:jobseeker) { create(:jobseeker) }
      let(:profile) { build(:jobseeker_profile, jobseeker: jobseeker) }

      it "saves the record before creating associations" do
        expect(profile).not_to be_persisted

        described_class.prepare_associations(profile)

        expect(profile).to be_persisted
      end

      it "assigns job_preferences" do
        described_class.prepare_associations(profile)

        expect(profile.job_preferences).to be_present
      end
    end
  end

  describe ".prepare(jobseeker:)" do
    subject(:profile) { described_class.prepare(jobseeker:) }
    let(:jobseeker) { create(:jobseeker) }

    context "when a profile already exists for that jobseeker" do
      let!(:existing_profile) { create(:jobseeker_profile, jobseeker:) }

      it "returns the existing profile" do
        expect(profile).to eq(existing_profile)
      end
    end

    context "when the jobseeker has no previous application" do
      it "still creates a job preferences record" do
        expect(profile.job_preferences).to be_present
      end

      it "correctly associates job_preferences with the profile" do
        expect(profile.job_preferences.jobseeker_profile_id).to eq(profile.id)
      end
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

  describe "#current_or_most_recent_employment" do
    let!(:profile) { create(:jobseeker_profile) }

    context "when there are no employments" do
      it "returns nil" do
        expect(profile.current_or_most_recent_employment).to be_nil
      end
    end

    context "when there are employments" do
      let!(:recent_employment) { create(:profile_employment, jobseeker_profile: profile, started_on: 1.year.ago, ended_on: 6.months.ago) }

      before do
        create(:profile_employment, jobseeker_profile: profile, started_on: 2.years.ago, ended_on: 1.year.ago)
      end

      it "returns the most recent employment based on started_on date" do
        expect(profile.current_or_most_recent_employment).to eq(recent_employment)
      end
    end

    context "when there are employment breaks" do
      let!(:employment) { create(:profile_employment, jobseeker_profile: profile, started_on: 1.year.ago, ended_on: 6.months.ago) }

      before do
        create(:profile_employment, :break, jobseeker_profile: profile, started_on: 6.months.ago, ended_on: 3.months.ago)
      end

      it "returns only job employments, not breaks" do
        expect(profile.current_or_most_recent_employment).to eq(employment)
      end
    end

    context "when there is a current employment" do
      let!(:current_employment) { create(:profile_employment, jobseeker_profile: profile, started_on: 6.months.ago, ended_on: nil, is_current_role: true) }

      before do
        create(:profile_employment, jobseeker_profile: profile, started_on: 1.month.ago, ended_on: 2.weeks.ago)
      end

      it "returns the current employment regardless of started_on date" do
        expect(profile.current_or_most_recent_employment).to eq(current_employment)
      end
    end
  end

  describe "#activable?" do
    subject { profile.activable? }

    let(:personal_details) { build_stubbed(:personal_details) }
    let(:job_preferences) { build_stubbed(:job_preferences) }
    let(:qualifications) { build_stubbed_list(:qualification, 1) }
    let(:employments) { build_stubbed_list(:profile_employment, 1, :current_role) }

    let(:profile) do
      build_stubbed(:jobseeker_profile,
                    personal_details: personal_details,
                    qualifications: qualifications,
                    job_preferences: job_preferences,
                    employments: employments)
    end

    context "with full requirements" do
      it { is_expected.to be true }
    end

    context "with employment_gaps" do
      let(:employments) { build_stubbed_list(:profile_employment, 1) }

      it { is_expected.to be false }
    end

    context "without qualifications" do
      let(:qualifications) { [] }

      it { is_expected.to be false }
    end

    context "without personal details" do
      let(:personal_details) { nil }

      it { is_expected.to be false }
    end

    context "without job preferences" do
      let(:job_preferences) { nil }

      it { is_expected.to be false }
    end

    context "with incomplete job_preferences" do
      let(:job_preferences) { build_stubbed(:job_preferences, :incomplete) }

      it { is_expected.to be false }
    end
  end
end
