require "rails_helper"

RSpec.describe JobApplication do
  it { is_expected.to belong_to(:jobseeker) }
  it { is_expected.to belong_to(:vacancy) }
  it { is_expected.to have_many(:employments) }
  it { is_expected.to have_many(:referees) }

  describe "before save hook" do
    let(:job_application) { create(:job_application) }

    it "enqueue equal opportunities report update job" do
      expect { job_application.submitted! }
        .to have_enqueued_job(EqualOpportunitiesReportUpdateJob).with(job_application.id)
    end
  end

  describe ".fill_in_report_and_reset_attributes!" do
    let(:job_application) do
      create(
        :job_application,
        :status_submitted,
        disability: "yes",
        gender: "other",
        gender_description: "lorem gender",
        orientation: "gay_or_lesbian",
        orientation_description: "",
        ethnicity: "asian",
        ethnicity_description: "",
        religion: "other",
        religion_description: "lorem religion",
        age: "prefer_not_to_say",
      )
    end
    let(:report) { job_application.vacancy.equal_opportunities_report }

    before do
      job_application.fill_in_report_and_reset_attributes!
    end

    it "fills in the equal opportunities report" do
      expect(report.total_submissions).to eq(1)

      expect(report.disability_no).to eq(0)
      expect(report.disability_prefer_not_to_say).to eq(0)
      expect(report.disability_yes).to eq(1)

      expect(report.gender_man).to eq(0)
      expect(report.gender_other).to eq(1)
      expect(report.gender_prefer_not_to_say).to eq(0)
      expect(report.gender_woman).to eq(0)
      expect(report.gender_other_descriptions).to contain_exactly("lorem gender")

      expect(report.orientation_bisexual).to eq(0)
      expect(report.orientation_gay_or_lesbian).to eq(1)
      expect(report.orientation_heterosexual).to eq(0)
      expect(report.orientation_other).to eq(0)
      expect(report.orientation_prefer_not_to_say).to eq(0)
      expect(report.orientation_other_descriptions).to be_empty

      expect(report.ethnicity_asian).to eq(1)
      expect(report.ethnicity_black).to eq(0)
      expect(report.ethnicity_mixed).to eq(0)
      expect(report.ethnicity_other).to eq(0)
      expect(report.ethnicity_prefer_not_to_say).to eq(0)
      expect(report.ethnicity_white).to eq(0)
      expect(report.ethnicity_other_descriptions).to be_empty

      expect(report.religion_buddhist).to eq(0)
      expect(report.religion_christian).to eq(0)
      expect(report.religion_hindu).to eq(0)
      expect(report.religion_jewish).to eq(0)
      expect(report.religion_muslim).to eq(0)
      expect(report.religion_none).to eq(0)
      expect(report.religion_other).to eq(1)
      expect(report.religion_prefer_not_to_say).to eq(0)
      expect(report.religion_sikh).to eq(0)
      expect(report.religion_other_descriptions).to contain_exactly("lorem religion")

      expect(report.age_under_twenty_five).to eq(0)
      expect(report.age_twenty_five_to_twenty_nine).to eq(0)
      expect(report.age_prefer_not_to_say).to eq(1)
      expect(report.age_thirty_to_thirty_nine).to eq(0)
      expect(report.age_forty_to_forty_nine).to eq(0)
      expect(report.age_fifty_to_fifty_nine).to eq(0)
      expect(report.age_sixty_and_over).to eq(0)
    end

    it "resets the job application equal opportunities data" do
      job_application.reload
      %i[
        disability
        gender
        gender_description
        orientation
        orientation_description
        ethnicity
        ethnicity_description
        religion
        religion_description
        age
      ].each do |field|
        expect(job_application[field]).to eq("")
      end
    end
  end

  describe "#has_noticed_notifications" do
    subject { create(:job_application) }

    before do
      Publishers::JobApplicationReceivedNotifier.with(vacancy: subject.vacancy, job_application: subject)
                                                    .deliver(subject.vacancy.publisher)
      expect(Noticed::Notification.count).to eq 1
      subject.destroy
    end

    it "removes the notification when destroyed" do
      expect(Noticed::Notification.count).to eq 0
    end
  end

  describe "#next_statuses" do
    subject { described_class.next_statuses(from_status) }

    context "when from status is nil" do
      let(:from_status) { nil }

      it { is_expected.to match_array(%w[draft submitted reviewed shortlisted unsuccessful withdrawn interviewing offered declined unsuccessful_interview]) }
    end

    context "when from status is draft" do
      let(:from_status) { "draft" }

      it { is_expected.to match_array(%w[submitted]) }
    end

    context "when from status is submitted" do
      let(:from_status) { "submitted" }

      it { is_expected.to match_array(%w[unsuccessful shortlisted interviewing offered withdrawn]) }
    end

    context "when from status is shortlisted" do
      let(:from_status) { "shortlisted" }

      it { is_expected.to match_array(%w[unsuccessful interviewing offered withdrawn]) }
    end

    context "when from status is interviewing" do
      let(:from_status) { "interviewing" }

      it { is_expected.to match_array(%w[unsuccessful_interview offered withdrawn]) }
    end

    context "when from status is offered" do
      let(:from_status) { "offered" }

      it { is_expected.to match_array(%w[declined withdrawn]) }
    end

    context "when from status is any other status" do
      let(:from_status) { "unsuccessful" }

      it { is_expected.to match_array([]) }
    end
  end

  describe "basic state machine" do
    before do
      job_application.status = status
      job_application.valid?
    end

    context "with invalid status transition pre submission" do
      let(:job_application) { create(:job_application, :status_draft) }
      let(:status) { "withdrawn" }

      it { expect(job_application.errors.details).to include(status: [{ error: "Invalid status transition from: draft to: withdrawn" }]) }
    end

    context "with invalid status transition post submission" do
      let(:job_application) { create(:job_application, :status_interviewing) }
      let(:status) { "submitted" }

      it { expect(job_application.errors.details).to include(status: [{ error: "Invalid status transition from: interviewing to: submitted" }]) }
    end

    context "with valid status transition post submission" do
      let(:job_application) { create(:job_application, :status_interviewing) }
      let(:status) { "unsuccessful_interview" }

      it { expect(job_application.errors.details).not_to include(status: [{ error: "Invalid status transition from: interviewing to: unsuccessful_interview" }]) }
    end
  end

  describe "terminal_status?" do
    subject { build_stubbed(:job_application, :"status_#{status}").terminal_status? }

    context "when status is withdrawn" do
      let(:status) { "withdrawn" }

      it { is_expected.to be true }
    end

    context "when status is declined" do
      let(:status) { "declined" }

      it { is_expected.to be true }
    end

    context "when status is unsuccessful_interview" do
      let(:status) { "unsuccessful_interview" }

      it { is_expected.to be true }
    end

    described_class.statuses.except(*%w[draft] + described_class::TERMINAL_STATUSES).each_key do |status|
      context "when status is #{status}" do
        let(:status) { status }

        it { is_expected.to be false }
      end
    end
  end

  describe "#name" do
    subject { build_stubbed(:job_application, first_name: "Brilliant", last_name: "Name") }

    it "returns the applicant full name" do
      expect(subject.name).to eq("Brilliant Name")
    end
  end

  describe "#allow_edit?" do
    let(:job_application) { build(:job_application) }

    subject { job_application.allow_edit? }

    context "when draft" do
      it { is_expected.to be true }

      context "when vacancy is expired" do
        let(:job_application) { build(:job_application, vacancy: build(:vacancy, :expired)) }

        it { is_expected.to be false }
      end
    end

    described_class.statuses.except("draft").each do |status, s|
      context "when application is in #{status} status" do
        let(:job_application) { build(:job_application, status: s) }

        it { is_expected.to be false }
      end
    end
  end

  context "when saving change to status" do
    subject { create(:job_application) }

    it "updates status timestamp" do
      freeze_time do
        expect { subject.submitted! }.to change { subject.submitted_at }.from(nil).to(Time.current)
      end
    end
  end

  context "when setting support needed to 'no'" do
    subject { create(:job_application) }

    before { subject.update(is_support_needed: false, support_needed_details: "details in need of resetting") }

    it "resets support needed details" do
      expect(subject.support_needed_details).to be_blank
      expect(subject.is_support_needed).to be(false)
    end
  end

  describe "#submit!" do
    subject { job_application.submit! }

    let(:job_application) { create(:job_application) }

    it "updates status" do
      expect { subject }.to change { job_application.reload.status }.from("draft").to("submitted")
    end

    it "delivers `Publishers::JobApplicationReceivedNotifier` notification" do
      expect { subject }
        .to have_delivered_notification("Publishers::JobApplicationReceivedNotifier")
        .with_recipient(job_application.vacancy.publisher)
        .and_params(vacancy: job_application.vacancy, job_application: job_application)
    end

    it "delivers `application_submitted` email" do
      expect { subject }
        .to have_enqueued_email(Jobseekers::JobApplicationMailer, :application_submitted)
        .with(job_application)
    end
  end
end
