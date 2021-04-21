require "rails_helper"

RSpec.shared_examples "puts the qualifications in separate groups" do
  it "puts the qualifications in separate groups" do
    expect(subject.qualification_groups.count).to eq(qualifications.count)
  end
end

RSpec.describe JobApplication do
  it { is_expected.to belong_to(:jobseeker) }
  it { is_expected.to belong_to(:vacancy) }
  it { is_expected.to have_many(:employments) }
  it { is_expected.to have_many(:references) }

  context "when saving change to status" do
    subject { create(:job_application) }

    it "updates status timestamp" do
      freeze_time do
        expect { subject.submitted! }.to change { subject.submitted_at }.from(3.days.ago).to(Time.current)
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

  describe "#qualification_groups" do
    let(:stubbed_time) { Time.utc(2021, 2, 1, 12, 0, 0) }
    let(:institution) { "Happy Rainbows School" }
    let(:name) { "Ordinary Wizarding Level" }
    let(:year) { 2000 }
    let!(:qualifications) do
      Array.new(3) do |index|
        count = index + 1
        build_stubbed(:qualification,
                      created_at: stubbed_time - count.seconds,
                      category: "other_secondary",
                      institution: institution || "Institution #{count}",
                      name: name || "Qualification name #{count}",
                      year: year || 2000 + count)
      end
    end

    before { allow(subject).to receive(:qualifications).and_return(qualifications) }

    context "when the qualifications do not share a name" do
      let(:name) { nil }

      it_behaves_like "puts the qualifications in separate groups"

      it "orders the groups by the created_at timestamp of the oldest qualification in each group" do
        expect(subject.qualification_groups.first.first.created_at).to eq(stubbed_time - qualifications.count)
        expect(subject.qualification_groups.second.first.created_at).to eq(stubbed_time - (qualifications.count - 1))
        expect(subject.qualification_groups.third.first.created_at).to eq(stubbed_time - (qualifications.count - 2))
      end
    end

    context "when the qualifications do not share an institution" do
      let(:institution) { nil }

      it_behaves_like "puts the qualifications in separate groups"
    end

    context "when the qualifications do not share a year" do
      let(:year) { nil }

      it_behaves_like "puts the qualifications in separate groups"
    end

    context "when some qualifications share a year, institution, and name" do
      let(:institution) { nil }
      let(:name) { nil }
      let(:year) { nil }
      let(:qualifications_to_be_grouped) do
        Array.new(2) do
          build_stubbed(:qualification,
                        created_at: stubbed_time - 100.days,
                        category: "other_secondary",
                        institution: "Dreary Grey School",
                        name: "O Level",
                        year: 1970)
        end
      end

      before { allow(subject).to receive(:qualifications).and_return(qualifications + qualifications_to_be_grouped) }

      it "groups the qualifications correctly and in order of the created_at timestamp of the oldest qualification in each group" do
        expect(subject.qualification_groups.first).to match_array(qualifications_to_be_grouped)
        expect(subject.qualification_groups.second.first.created_at).to eq(stubbed_time - qualifications.count)
        expect(subject.qualification_groups.third.first.created_at).to eq(stubbed_time - (qualifications.count - 1))
        expect(subject.qualification_groups.last.first.created_at).to eq(stubbed_time - (qualifications.count - 2))
      end
    end
  end
end
