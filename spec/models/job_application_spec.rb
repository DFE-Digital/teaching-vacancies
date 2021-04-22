require "rails_helper"

RSpec.describe JobApplication do
  it { is_expected.to belong_to(:jobseeker) }
  it { is_expected.to belong_to(:vacancy) }
  it { is_expected.to have_many(:employments) }
  it { is_expected.to have_many(:references) }

  context "when saving change to status" do
    subject { create(:job_application) }

    it "updates status timestamp" do
      freeze_time do
        expect { subject.submitted! }.to change { subject.submitted_at }.from(4.days.ago).to(Time.current)
      end
    end
  end

  context "when submitted" do
    subject do
      build(:job_application, vacancy: vacancy, disability: "no", gender: "man", gender_description: "",
                              ethnicity: "black", ethnicity_description: "", orientation: "other",
                              orientation_description: "extravagant", religion: "other", religion_description: "agnostic")
    end

    let(:vacancy) { create(:vacancy) }
    let(:equal_opportunities_report) { vacancy.equal_opportunities_report }

    before { subject.submitted! }

    it "creates a report" do
      expect(equal_opportunities_report.total_submissions).to be 1
    end

    it "sets the correct counters on the report" do
      expect(equal_opportunities_report.disability_no).to be 1
      expect(equal_opportunities_report.disability_prefer_not_to_say).to be 0
      expect(equal_opportunities_report.disability_yes).to be 0
      expect(equal_opportunities_report.gender_man).to be 1
      expect(equal_opportunities_report.gender_other).to be 0
      expect(equal_opportunities_report.gender_prefer_not_to_say).to be 0
      expect(equal_opportunities_report.gender_woman).to be 0
      expect(equal_opportunities_report.orientation_bisexual).to be 0
      expect(equal_opportunities_report.orientation_gay_or_lesbian).to be 0
      expect(equal_opportunities_report.orientation_heterosexual).to be 0
      expect(equal_opportunities_report.orientation_other).to be 1
      expect(equal_opportunities_report.orientation_prefer_not_to_say).to be 0
      expect(equal_opportunities_report.ethnicity_asian).to be 0
      expect(equal_opportunities_report.ethnicity_black).to be 1
      expect(equal_opportunities_report.ethnicity_mixed).to be 0
      expect(equal_opportunities_report.ethnicity_other).to be 0
      expect(equal_opportunities_report.ethnicity_prefer_not_to_say).to be 0
      expect(equal_opportunities_report.ethnicity_white).to be 0
      expect(equal_opportunities_report.religion_buddhist).to be 0
      expect(equal_opportunities_report.religion_christian).to be 0
      expect(equal_opportunities_report.religion_hindu).to be 0
      expect(equal_opportunities_report.religion_jewish).to be 0
      expect(equal_opportunities_report.religion_muslim).to be 0
      expect(equal_opportunities_report.religion_none).to be 0
      expect(equal_opportunities_report.religion_other).to be 1
      expect(equal_opportunities_report.religion_prefer_not_to_say).to be 0
      expect(equal_opportunities_report.religion_sikh).to be 0
    end

    it "sets the correct string array attributes on the report" do
      expect(equal_opportunities_report.orientation_other_descriptions).to eq ["extravagant"]
      expect(equal_opportunities_report.religion_other_descriptions).to eq ["agnostic"]
    end

    it "resets equal opportunity attributes" do
      expect(subject.disability).to eq ""
      expect(subject.gender).to eq ""
      expect(subject.gender_description).to eq ""
      expect(subject.orientation).to eq ""
      expect(subject.orientation_description).to eq ""
      expect(subject.ethnicity).to eq ""
      expect(subject.ethnicity_description).to eq ""
      expect(subject.religion).to eq ""
      expect(subject.religion_description).to eq ""
    end
  end

  describe "#submit!" do
    subject { job_application.submit! }

    let(:job_application) { create(:job_application) }

    it "updates status" do
      expect { subject }.to change { job_application.reload.status }.from("draft").to("submitted")
    end

    it "delivers `Publishers::JobApplicationReceivedNotification` notification" do
      expect { subject }
        .to have_delivered_notification("Publishers::JobApplicationReceivedNotification")
        .with_recipient(job_application.vacancy.publisher)
        .and_params(vacancy: job_application.vacancy, job_application: job_application)
    end

    it "delivers `application_submitted` email" do
      expect { subject }
        .to have_enqueued_email(Jobseekers::JobApplicationMailer, :application_submitted)
        .with(hash_including(args: [job_application]))
    end
  end
end
