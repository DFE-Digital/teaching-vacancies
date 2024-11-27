require "rails_helper"

RSpec.describe SendDailyAlertEmailJob do
  subject(:job) { described_class.perform_later }

  let(:mail) { double(:mail) }

  describe "#perform" do
    context "with vacancies" do
      before do
        create(:vacancy, :published_slugged, contact_number: "1", ect_status: :ect_unsuitable, job_roles: %w[teacher], subjects: %w[English], phases: %w[secondary], working_patterns: %w[full_time], created_at: 1.day.ago + 1.minute)
        create(:vacancy, :published_slugged, contact_number: "2", job_roles: %w[it_support], subjects: %w[English], phases: %w[secondary], working_patterns: %w[full_time], created_at: 1.day.ago + 2.minutes)
        create(:vacancy, :published_slugged, contact_number: "3", visa_sponsorship_available: true, job_roles: %w[headteacher], subjects: %w[English], phases: %w[secondary], working_patterns: %w[full_time], created_at: 1.day.ago + 3.minutes)
        create(:vacancy, :published_slugged, contact_number: "4", ect_status: :ect_suitable, job_roles: %w[headteacher teacher], subjects: %w[English], phases: %w[secondary], working_patterns: %w[full_time], created_at: 1.day.ago + 4.minutes)
        create(:vacancy, :published_slugged, contact_number: "5", job_roles: %w[headteacher], subjects: %w[French], phases: %w[secondary], working_patterns: %w[full_time], created_at: 1.day.ago + 5.minutes)
        create(:vacancy, :published_slugged, contact_number: "6", job_roles: %w[headteacher], phases: %w[primary], working_patterns: %w[full_time], created_at: 1.day.ago + 6.minutes)
        create(:vacancy, :published_slugged, contact_number: "7", job_roles: %w[headteacher], phases: %w[secondary], working_patterns: %w[part_time], created_at: 1.day.ago + 7.minutes)
        create(:vacancy, :published_slugged, contact_number: "8", organisations: [new_org], job_roles: %w[headteacher], phases: %w[secondary], working_patterns: %w[full_time], created_at: 1.day.ago + 8.minutes)
        create(:vacancy, :published_slugged, contact_number: "9", job_title: "This is a nice job", job_roles: %w[headteacher], phases: %w[secondary], working_patterns: %w[full_time], created_at: 1.day.ago + 9.minutes)
      end

      let(:new_org) { create(:school) }
      let(:teacher_vacancy) { Vacancy.find_by!(contact_number: "1") }
      let(:support_vacancy) { Vacancy.find_by!(contact_number: "2") }
      let(:visa_job) { Vacancy.find_by!(contact_number: "3") }
      let(:ect_job) { Vacancy.find_by!(contact_number: "4") }
      let(:french_job) { Vacancy.find_by!(contact_number: "5") }
      let(:primary_job) { Vacancy.find_by!(contact_number: "6") }
      let(:part_time_job) { Vacancy.find_by!(contact_number: "7") }
      let(:new_org_job) { Vacancy.find_by!(contact_number: "8") }
      let(:nice_job) { Vacancy.find_by!(contact_number: "9") }

      let(:vacancies) { [teacher_vacancy, support_vacancy, visa_job, ect_job, french_job, primary_job, part_time_job, new_org_job, nice_job] }

      context "with keyword" do
        let(:subscription) { create(:subscription, keyword: "nice", frequency: :daily) }

        it "only finds the nice job" do
          expect(Jobseekers::AlertMailer).to receive(:alert).with(subscription.id, [nice_job].pluck(:id)) { mail }
          expect(mail).to receive(:deliver_later) { ActionMailer::MailDeliveryJob.new }
          perform_enqueued_jobs { job }
        end
      end

      context "with teaching job roles" do
        let(:subscription) { create(:subscription, teaching_job_roles: %w[teacher], frequency: :daily) }

        it "only finds the teaching job" do
          expect(Jobseekers::AlertMailer).to receive(:alert).with(subscription.id, [teacher_vacancy, ect_job].pluck(:id)) { mail }
          expect(mail).to receive(:deliver_later) { ActionMailer::MailDeliveryJob.new }
          perform_enqueued_jobs { job }
        end
      end

      context "with support job roles" do
        let(:subscription) { create(:subscription, support_job_roles: %w[it_support], frequency: :daily) }

        it "only finds the support job" do
          expect(Jobseekers::AlertMailer).to receive(:alert).with(subscription.id, [support_vacancy].pluck(:id)) { mail }
          expect(mail).to receive(:deliver_later) { ActionMailer::MailDeliveryJob.new }
          perform_enqueued_jobs { job }
        end
      end

      context "with visa sponsorship" do
        let(:subscription) { create(:subscription, :visa_sponsorship_required, frequency: :daily) }

        it "only finds the visa job" do
          expect(Jobseekers::AlertMailer).to receive(:alert).with(subscription.id, [visa_job].pluck(:id)) { mail }
          expect(mail).to receive(:deliver_later) { ActionMailer::MailDeliveryJob.new }
          perform_enqueued_jobs { job }
        end
      end

      context "with ECT" do
        let(:subscription) { create(:subscription, :ect_suitable, frequency: :daily) }

        it "only finds the ECT job" do
          expect(Jobseekers::AlertMailer).to receive(:alert).with(subscription.id, [ect_job].pluck(:id)) { mail }
          expect(mail).to receive(:deliver_later) { ActionMailer::MailDeliveryJob.new }
          perform_enqueued_jobs { job }
        end
      end

      context "with subjects filter" do
        let(:subscription) { create(:subscription, subjects: %w[French], frequency: :daily) }

        it "only finds the Maths job" do
          expect(Jobseekers::AlertMailer).to receive(:alert).with(subscription.id, [french_job].pluck(:id)) { mail }
          expect(mail).to receive(:deliver_later) { ActionMailer::MailDeliveryJob.new }
          perform_enqueued_jobs { job }
        end
      end

      context "with phases filter" do
        let(:subscription) { create(:subscription, phases: %w[primary], frequency: :daily) }

        it "only finds the primary school job" do
          expect(Jobseekers::AlertMailer).to receive(:alert).with(subscription.id, [primary_job].pluck(:id)) { mail }
          expect(mail).to receive(:deliver_later) { ActionMailer::MailDeliveryJob.new }
          perform_enqueued_jobs { job }
        end
      end

      context "with working patterns filter" do
        let(:subscription) { create(:subscription, working_patterns: %w[part_time], frequency: :daily) }

        it "only finds the part_time job" do
          expect(Jobseekers::AlertMailer).to receive(:alert).with(subscription.id, [part_time_job].pluck(:id)) { mail }
          expect(mail).to receive(:deliver_later) { ActionMailer::MailDeliveryJob.new }
          perform_enqueued_jobs { job }
        end
      end

      context "with organisation filter" do
        let(:subscription) { create(:subscription, organisation_slug: new_org.slug, frequency: :daily) }

        it "only finds the new_publisher job" do
          expect(Jobseekers::AlertMailer).to receive(:alert).with(subscription.id, [new_org_job].pluck(:id)) { mail }
          expect(mail).to receive(:deliver_later) { ActionMailer::MailDeliveryJob.new }
          perform_enqueued_jobs { job }
        end
      end

      context "with no subscription criteria" do
        let(:subscription) { create(:subscription, frequency: :daily) }

        it "sends an email" do
          expect(Jobseekers::AlertMailer).to receive(:alert).with(subscription.id, vacancies.pluck(:id)) { mail }
          expect(mail).to receive(:deliver_later) { ActionMailer::MailDeliveryJob.new }
          perform_enqueued_jobs { job }
        end

        context "when a run exists" do
          let!(:run) { subscription.alert_runs.create(run_on: Date.current) }

          it "does not send another email" do
            expect(Jobseekers::AlertMailer).to_not receive(:alert)
            perform_enqueued_jobs { job }
          end
        end
      end
    end

    context "with no vacancies" do
      let(:subscription) { create(:subscription, frequency: :daily) }

      it "does not send an email or create a run" do
        expect(Jobseekers::AlertMailer).to_not receive(:alert)
        perform_enqueued_jobs { job }
        expect(subscription.alert_runs.count).to eq(0)
      end
    end
  end

  describe "#subscriptions" do
    let(:job) { described_class.new }

    it "gets active daily subscriptions" do
      expect(Subscription).to receive_message_chain(:active, :daily).and_return(
        Subscription.where(active: true).where(frequency: :daily),
      )
      job.subscriptions
    end
  end
end
